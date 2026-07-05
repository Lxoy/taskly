using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Text;
using taskly.Data;
using taskly.Data.Enums;
using taskly.Data.Models;
using taskly.Services.Interfaces;

namespace taskly.Services.Jobs
{
    public class ReminderNotificationJob
    {
        private readonly ApplicationDbContext _dbContext;
        private readonly IFirebasePushService _firebasePushService;

        public ReminderNotificationJob(
            ApplicationDbContext dbContext,
            IFirebasePushService firebasePushService)
        {
            _dbContext = dbContext;
            _firebasePushService = firebasePushService;
        }

        public async Task RunAsync()
        {
            await GenerateRemindersAsync();
            await SendPendingRemindersAsync();
        }

        private async Task GenerateRemindersAsync()
        {
            var now = DateTime.UtcNow;
            var windowEnd = now.AddHours(25);

            var entries = await _dbContext.Entries
                .Where(e =>
                    e.IsActive &&
                    e.ScheduledDate < windowEnd &&
                    (e.RecurrenceEndDate == null || e.RecurrenceEndDate >= now))
                .ToListAsync();

            var entryIds = entries.Select(e => e.Id).ToList();

            var anomalies = await _dbContext.EntryAnomalies
                .Where(a =>
                    a.IsActive &&
                    entryIds.Contains(a.EntryId) &&
                    (
                        (a.OccurrenceDate >= now && a.OccurrenceDate < windowEnd) ||
                        (a.NewOccurrenceDate.HasValue &&
                         a.NewOccurrenceDate.Value >= now &&
                         a.NewOccurrenceDate.Value < windowEnd)
                    ))
                .ToListAsync();

            var anomaliesByOriginalDate = anomalies
                .GroupBy(a => new { a.EntryId, a.OccurrenceDate })
                .ToDictionary(g => g.Key, g => g.First());

            foreach (var entry in entries)
            {
                var dates = CalculateDatesInRange(entry, now, windowEnd);

                foreach (var occurrenceDate in dates)
                {
                    var finalOccurrenceDate = occurrenceDate;

                    var key = new
                    {
                        EntryId = entry.Id,
                        OccurrenceDate = occurrenceDate
                    };

                    if (anomaliesByOriginalDate.TryGetValue(key, out var anomaly))
                    {
                        if (anomaly.IsDeleted)
                            continue;

                        finalOccurrenceDate = anomaly.NewOccurrenceDate ?? occurrenceDate;
                    }

                    var minutesUntilOccurrence =
                        (finalOccurrenceDate - now).TotalMinutes;

                    if (minutesUntilOccurrence <= 0)
                        continue;

                    var exists = await _dbContext.Reminders.AnyAsync(r =>
                        r.IsActive &&
                        r.EntryId == entry.Id &&
                        r.OccurrenceDate == finalOccurrenceDate);

                    if (exists)
                        continue;

                    var remindAt = finalOccurrenceDate.AddHours(-1);

                    if (remindAt < now)
                        remindAt = now;

                    _dbContext.Reminders.Add(new Reminder
                    {
                        UserId = entry.UserId,
                        EntryId = entry.Id,
                        OccurrenceDate = finalOccurrenceDate,
                        RemindAt = remindAt,
                        Status = ReminderStatus.Pending,
                        IsActive = true
                    });
                }
            }

            await _dbContext.SaveChangesAsync();
        }

        private async Task SendPendingRemindersAsync()
        {
            var now = DateTime.UtcNow;

            var reminders = await _dbContext.Reminders
                .Include(r => r.Entry)
                .Where(r =>
                    r.IsActive &&
                    r.Status == ReminderStatus.Pending &&
                    r.RemindAt <= now)
                .Take(100)
                .ToListAsync();

            foreach (var reminder in reminders)
            {
                try
                {
                    var tokens = await _dbContext.UserNotificationTokens
                        .Where(t =>
                            t.UserId == reminder.UserId &&
                            t.IsActive)
                        .Select(t => t.Token)
                        .ToListAsync();

                    foreach (var token in tokens)
                    {
                        var minutesLeft =Math.Max(0,(int)(reminder.OccurrenceDate - DateTime.UtcNow).TotalMinutes);

                        var title = reminder.Entry.Title;

                        var body = minutesLeft switch
                        {
                            <= 1 => "It's time.",
                            < 60 => $"Starts in {minutesLeft} minutes.",
                            _ => "Starts in less than an hour."
                        };

                        await _firebasePushService.SendAsync(
                            token,
                            title,
                            body
                        );
                    }

                    reminder.Status = ReminderStatus.Sent;
                    reminder.SentAt = DateTime.UtcNow;
                    reminder.ModifiedAt = DateTime.UtcNow;
                }
                catch (Exception ex)
                {
                    reminder.Status = ReminderStatus.Failed;
                    reminder.FailedAt = DateTime.UtcNow;
                    reminder.FailureReason = ex.Message;
                    reminder.RetryCount++;
                    reminder.ModifiedAt = DateTime.UtcNow;
                }
            }

            await _dbContext.SaveChangesAsync();
        }

        private static IEnumerable<DateTime> CalculateDatesInRange(
            Entry entry,
            DateTime from,
            DateTime toExclusive)
        {
            if (entry.ScheduledDate >= toExclusive)
                yield break;

            var recurrenceEndExclusive =
                entry.RecurrenceEndDate?.AddTicks(1) ?? toExclusive;

            if (entry.RecurrenceType == RecurrenceType.Once)
            {
                if (entry.ScheduledDate >= from &&
                    entry.ScheduledDate < toExclusive &&
                    entry.ScheduledDate < recurrenceEndExclusive)
                {
                    yield return entry.ScheduledDate;
                }

                yield break;
            }

            if (entry.RecurrenceType == RecurrenceType.Weekly &&
                entry.RecurrenceDaysMask.HasValue &&
                entry.RecurrenceDaysMask.Value > 0)
            {
                foreach (var date in CalculateWeeklyDatesWithMask(
                    entry,
                    from,
                    toExclusive,
                    recurrenceEndExclusive))
                {
                    yield return date;
                }

                yield break;
            }

            var current = entry.ScheduledDate;

            while (current < from)
            {
                current = Advance(current, entry);
            }

            while (current < toExclusive && current < recurrenceEndExclusive)
            {
                yield return current;
                current = Advance(current, entry);
            }
        }

        private static IEnumerable<DateTime> CalculateWeeklyDatesWithMask(
            Entry entry,
            DateTime from,
            DateTime toExclusive,
            DateTime recurrenceEndExclusive)
        {
            var currentDate = from.Date;
            var endDate = toExclusive.Date;

            while (currentDate < endDate)
            {
                if (currentDate >= entry.ScheduledDate.Date &&
                    currentDate < recurrenceEndExclusive.Date.AddDays(1) &&
                    IsCorrectWeekInterval(
                        entry.ScheduledDate.Date,
                        currentDate,
                        entry.RecurrenceInterval) &&
                    IsDayIncluded(
                        entry.RecurrenceDaysMask!.Value,
                        currentDate.DayOfWeek))
                {
                    yield return currentDate.Date + entry.ScheduledDate.TimeOfDay;
                }

                currentDate = currentDate.AddDays(1);
            }
        }

        private static bool IsCorrectWeekInterval(
            DateTime startDate,
            DateTime currentDate,
            int interval)
        {
            interval = interval <= 0 ? 1 : interval;

            var startWeek = StartOfWeek(startDate);
            var currentWeek = StartOfWeek(currentDate);

            var weeksDiff = (int)((currentWeek - startWeek).TotalDays / 7);

            return weeksDiff >= 0 && weeksDiff % interval == 0;
        }

        private static DateTime StartOfWeek(DateTime date)
        {
            var diff = ((int)date.DayOfWeek + 6) % 7;
            return date.Date.AddDays(-diff);
        }

        private static bool IsDayIncluded(WeekDays mask, DayOfWeek dayOfWeek)
        {
            var dayMask = dayOfWeek switch
            {
                DayOfWeek.Monday => WeekDays.Monday,
                DayOfWeek.Tuesday => WeekDays.Tuesday,
                DayOfWeek.Wednesday => WeekDays.Wednesday,
                DayOfWeek.Thursday => WeekDays.Thursday,
                DayOfWeek.Friday => WeekDays.Friday,
                DayOfWeek.Saturday => WeekDays.Saturday,
                DayOfWeek.Sunday => WeekDays.Sunday,
                _ => WeekDays.None
            };

            return (mask & dayMask) != 0;
        }

        private static DateTime Advance(DateTime current, Entry entry)
        {
            var interval = entry.RecurrenceInterval <= 0
                ? 1
                : entry.RecurrenceInterval;

            return entry.RecurrenceType switch
            {
                RecurrenceType.Daily => current.AddDays(interval),
                RecurrenceType.Weekly => current.AddDays(7 * interval),
                RecurrenceType.Monthly => current.AddMonths(interval),
                RecurrenceType.Yearly => current.AddYears(interval),
                _ => throw new ArgumentOutOfRangeException(
                    nameof(entry.RecurrenceType),
                    "Unknown recurrence type")
            };
        }
    }
}
