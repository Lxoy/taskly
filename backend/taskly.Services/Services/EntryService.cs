using Microsoft.EntityFrameworkCore;
using taskly.Data;
using taskly.Data.Enums;
using taskly.Data.Models;
using taskly.Services.Dtos.Base;
using taskly.Services.Dtos.Entry;
using taskly.Services.Interfaces;
using taskly.Services.Mappers;

namespace taskly.Services.Services
{
    public class EntryService : IEntryService
    {
        private readonly ApplicationDbContext _dbContext;
        public EntryService(ApplicationDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<BaseResponse<EntryDto>> GetEntry(int userId, int entryId)
        {
            var response = new BaseResponse<EntryDto>();

            var entry = await _dbContext.Entries
                .FirstOrDefaultAsync(e =>
                    e.Id == entryId &&
                    e.UserId == userId &&
                    e.IsActive);

            if (entry is null)
            {
                response.SetNotFound("Entry");
                return response;
            }

            response.Success = true;
            response.Data = new EntryDto
            {
                Id = entry.Id,
                CategoryId = entry.CategoryId,
                Title = entry.Title,
                Description = entry.Description,
                Amount = entry.Amount,
                Priority = entry.Priority,
                RecurrenceType = entry.RecurrenceType,
                RecurrenceInterval = entry.RecurrenceInterval,
                RecurrenceDaysMask = entry.RecurrenceDaysMask,
                ScheduledDate = entry.ScheduledDate,
                RecurrenceEndDate = entry.RecurrenceEndDate
            };

            return response;
        }

        public async Task<BaseResponse> CreateNewEntry(int userId, CreateEntryDto request)
        {
            var response = new BaseResponse();

            if (request.CategoryId is not null)
            {
                var categoryExists = await _dbContext.Categories
                    .AnyAsync(c => c.Id == request.CategoryId &&
                                   c.UserId == userId &&
                                   c.IsActive);

                if (!categoryExists)
                {
                    response.SetNotFound("Category");
                    return response;
                }
            }

            if (request.RecurrenceInterval < 1)
            {
                response.SetValidationError("Recurrence interval must be at least 1.");
                return response;
            }

            if (request.RecurrenceEndDate.HasValue &&
                request.RecurrenceEndDate.Value < request.ScheduledDate)
            {
                response.SetValidationError("Recurrence end date cannot be before scheduled date.");
                return response;
            }

            if (request.RecurrenceType == RecurrenceType.Once)
            {
                request.RecurrenceInterval = 1;
                request.RecurrenceDaysMask = null;
                request.RecurrenceEndDate = null;
            }

            if (request.RecurrenceType == RecurrenceType.Weekly &&
                (!request.RecurrenceDaysMask.HasValue ||
                 request.RecurrenceDaysMask.Value == WeekDays.None))
            {
                response.SetValidationError("Weekly recurrence requires at least one selected day.");
                return response;
            }

            if (request.RecurrenceType != RecurrenceType.Weekly)
            {
                request.RecurrenceDaysMask = null;
            }

            var entry = new Entry
            {
                UserId = userId,
                CategoryId = request.CategoryId,
                Title = request.Title,
                Description = request.Description,
                Amount = request.Amount,
                Priority = request.Priority,

                RecurrenceType = request.RecurrenceType,
                RecurrenceInterval = request.RecurrenceInterval,
                RecurrenceDaysMask = request.RecurrenceDaysMask,

                ScheduledDate = DateTime.SpecifyKind(request.ScheduledDate, DateTimeKind.Utc),
                RecurrenceEndDate = request.RecurrenceEndDate.HasValue
                    ? DateTime.SpecifyKind(request.RecurrenceEndDate.Value, DateTimeKind.Utc)
                    : null
            };

            await _dbContext.Entries.AddAsync(entry);
            await _dbContext.SaveChangesAsync();

            entry.SeriesId = entry.Id;

            await _dbContext.SaveChangesAsync();

            response.Success = true;
            return response;
        }

        public async Task<BaseResponse> UpdateEntryAll(int userId, int entryId, UpdateEntryAllDto request)
        {
            var response = new BaseResponse();

            var selectedEntry = await _dbContext.Entries
                .FirstOrDefaultAsync(e =>
                    e.Id == entryId &&
                    e.UserId == userId &&
                    e.IsActive);

            if (selectedEntry is null)
            {
                response.SetNotFound("Entry");
                return response;
            }

            var validationError = await ValidateUpdateRequest(userId, request, selectedEntry);
            if (validationError is not null)
            {
                response.SetValidationError(validationError);
                return response;
            }

            if (HasRecurrenceChanges(request))
            {
                await ReplaceWholeSeries(userId, selectedEntry, request);
            }
            else
            {
                await UpdateWholeSeriesContent(userId, selectedEntry, request);
            }

            await _dbContext.SaveChangesAsync();

            response.Success = true;
            return response;
        }

        public async Task<BaseResponse> UpdateEntryThisAndFuture(int userId, int entryId, UpdateEntryThisAndFutureDto request)
        {
            var response = new BaseResponse();

            var currentEntry = await _dbContext.Entries
                .FirstOrDefaultAsync(e =>
                    e.Id == entryId &&
                    e.UserId == userId &&
                    e.IsActive);

            if (currentEntry is null)
            {
                response.SetNotFound("Entry");
                return response;
            }

            var effectiveDate = request.EffectiveDate;
            var entryStart = currentEntry.ScheduledDate;

            DateTime? entryEnd = currentEntry.RecurrenceEndDate.HasValue
                ? currentEntry.RecurrenceEndDate.Value
                : null;

            if (effectiveDate.Date < entryStart.Date)
            {
                response.SetValidationError("Effective date cannot be before current entry start date.");
                return response;
            }

            if (entryEnd.HasValue && effectiveDate.Date > entryEnd.Value.Date)
            {
                response.SetValidationError("Effective date cannot be after current entry end date.");
                return response;
            }

            var validationError = await ValidateUpdateRequest(userId, request, currentEntry);
            if (validationError is not null)
            {
                response.SetValidationError(validationError);
                return response;
            }

            if (effectiveDate <= entryStart)
            {
                currentEntry.IsActive = false;
            }
            else
            {
                currentEntry.RecurrenceEndDate = effectiveDate.AddTicks(-1);
            }

            var futureEntries = await _dbContext.Entries
                .Where(e =>
                    e.Id != currentEntry.Id &&
                    e.UserId == userId &&
                    e.SeriesId == currentEntry.SeriesId &&
                    e.IsActive &&
                    e.ScheduledDate >= effectiveDate)
                .ToListAsync();

            foreach (var futureEntry in futureEntries)
            {
                futureEntry.IsActive = false;
            }

            var anomaliesToDeactivate = await _dbContext.EntryAnomalies
                .Where(a =>
                    a.IsActive &&
                    a.Entry.UserId == userId &&
                    a.Entry.SeriesId == currentEntry.SeriesId &&
                    (
                        a.OccurrenceDate >= effectiveDate ||
                        (a.NewOccurrenceDate.HasValue &&
                         a.NewOccurrenceDate.Value >= effectiveDate)
                    ))
                .ToListAsync();

            foreach (var anomaly in anomaliesToDeactivate)
            {
                anomaly.IsActive = false;
            }

            var newEntry = new Entry
            {
                UserId = currentEntry.UserId,
                SeriesId = currentEntry.SeriesId,

                CategoryId = request.CategoryId,
                Title = request.Title ?? currentEntry.Title,
                Description = request.Description ?? currentEntry.Description,
                Amount = request.Amount ?? currentEntry.Amount,
                Priority = request.Priority ?? currentEntry.Priority,

                RecurrenceType = request.RecurrenceType ?? currentEntry.RecurrenceType,
                RecurrenceInterval = request.RecurrenceInterval ?? currentEntry.RecurrenceInterval,
                RecurrenceDaysMask = request.RecurrenceDaysMask ?? currentEntry.RecurrenceDaysMask,

                ScheduledDate = request.ScheduledDate.HasValue
                    ? request.ScheduledDate.Value
                    : effectiveDate,

                RecurrenceEndDate = request.RecurrenceEndDate.HasValue
                    ? request.RecurrenceEndDate.Value
                    : entryEnd
            };

            NormalizeRecurrence(newEntry);

            await _dbContext.Entries.AddAsync(newEntry);
            await _dbContext.SaveChangesAsync();

            response.Success = true;
            return response;
        }

        public async Task<BaseResponse> DeleteEntryAll(int userId, int entryId)
        {
            var response = new BaseResponse();

            var entry = await _dbContext.Entries
                .FirstOrDefaultAsync(e =>
                    e.Id == entryId &&
                    e.UserId == userId &&
                    e.IsActive);

            if (entry is null)
            {
                response.SetNotFound("Entry");
                return response;
            }

            var entriesToDeactivate = await _dbContext.Entries
                .Where(e =>
                    e.UserId == userId &&
                    e.SeriesId == entry.SeriesId &&
                    e.IsActive)
                .ToListAsync();

            foreach (var item in entriesToDeactivate)
            {
                item.IsActive = false;
            }

            var anomaliesToDeactivate = await _dbContext.EntryAnomalies
                .Where(a =>
                    a.IsActive &&
                    a.Entry.UserId == userId &&
                    a.Entry.SeriesId == entry.SeriesId)
                .ToListAsync();

            foreach (var anomaly in anomaliesToDeactivate)
            {
                anomaly.IsActive = false;
            }

            await _dbContext.SaveChangesAsync();

            response.Success = true;
            return response;
        }

        public async Task<BaseResponse> DeleteEntryFuture(int userId, int entryId, DateTime effectiveDate)
        {
            var response = new BaseResponse();

            var entry = await _dbContext.Entries
                .FirstOrDefaultAsync(e =>
                    e.Id == entryId &&
                    e.UserId == userId &&
                    e.IsActive);

            if (entry is null)
            {
                response.SetNotFound("Entry");
                return response;
            }

            if (effectiveDate <= entry.ScheduledDate)
            {
                entry.IsActive = false;
            }
            else
            {
                entry.RecurrenceEndDate = effectiveDate.AddTicks(-1);
            }

            var futureEntries = await _dbContext.Entries
                .Where(e =>
                    e.Id != entry.Id &&
                    e.UserId == userId &&
                    e.SeriesId == entry.SeriesId &&
                    e.IsActive &&
                    e.ScheduledDate >= effectiveDate)
                .ToListAsync();

            foreach (var futureEntry in futureEntries)
            {
                futureEntry.IsActive = false;
            }

            var anomalies = await _dbContext.EntryAnomalies
                .Where(a =>
                    a.IsActive &&
                    a.Entry.UserId == userId &&
                    a.Entry.SeriesId == entry.SeriesId &&
                    (
                        a.OccurrenceDate >= effectiveDate ||
                        (a.NewOccurrenceDate.HasValue &&
                         a.NewOccurrenceDate.Value >= effectiveDate)
                    ))
                .ToListAsync();

            foreach (var anomaly in anomalies)
            {
                anomaly.IsActive = false;
            }

            await _dbContext.SaveChangesAsync();

            response.Success = true;
            return response;
        }

        public async Task<BaseResponse> DeleteEntry(int userId, int entryId, DateTime effectiveDate)
        {
            var response = new BaseResponse();

            var entry = await _dbContext.Entries
                .FirstOrDefaultAsync(e =>
                    e.Id == entryId &&
                    e.UserId == userId &&
                    e.IsActive);

            if (entry is null)
            {
                response.SetNotFound("Entry");
                return response;
            }

            var occurrenceDate = DateTime.SpecifyKind(effectiveDate, DateTimeKind.Utc);

            var anomaly = await _dbContext.EntryAnomalies
                .FirstOrDefaultAsync(a =>
                    a.EntryId == entryId &&
                    a.OccurrenceDate == occurrenceDate);

            if (anomaly is null)
            {
                anomaly = new EntryAnomaly
                {
                    EntryId = entry.Id,
                    OccurrenceDate = occurrenceDate,

                    Title = entry.Title,
                    Description = entry.Description,
                    Amount = entry.Amount,
                    Priority = entry.Priority,
                    CategoryId = entry.CategoryId,

                    IsDeleted = true,
                    IsActive = true
                };

                await _dbContext.EntryAnomalies.AddAsync(anomaly);
            }
            else
            {
                anomaly.IsActive = true;
                anomaly.IsDeleted = true;
            }

            await _dbContext.SaveChangesAsync();

            response.Success = true;
            return response;
        }

        public async Task<BaseResponse<List<EntryMonthDto>>> GetOccurrencesForMonth(int userId, int year, int month)
        {
            var response = new BaseResponse<List<EntryMonthDto>>();

            var monthStart = new DateTime(year, month, 1, 0, 0, 0, DateTimeKind.Utc);
            var monthEndExclusive = monthStart.AddMonths(1);

            var entries = await _dbContext.Entries
                .Where(e =>
                    e.UserId == userId &&
                    e.IsActive &&
                    e.ScheduledDate < monthEndExclusive &&
                    (e.RecurrenceEndDate == null ||
                     e.RecurrenceEndDate >= monthStart))
                .ToListAsync();

            var entryIds = entries.Select(e => e.Id).ToList();

            var anomalies = await _dbContext.EntryAnomalies
                .Include(a => a.Entry)
                .Where(a =>
                    a.IsActive &&
                    a.Entry.UserId == userId &&
                    a.Entry.IsActive &&
                    entryIds.Contains(a.EntryId) &&
                    (
                        (a.OccurrenceDate >= monthStart &&
                         a.OccurrenceDate < monthEndExclusive)
                        ||
                        (a.NewOccurrenceDate.HasValue &&
                         a.NewOccurrenceDate.Value >= monthStart &&
                         a.NewOccurrenceDate.Value < monthEndExclusive)
                    ))
                .ToListAsync();

            var anomaliesByOriginalDate = anomalies
                .GroupBy(a => new { a.EntryId, a.OccurrenceDate })
                .ToDictionary(g => g.Key, g => g.First());

            var result = new List<EntryMonthDto>();

            foreach (var entry in entries)
            {
                var dates = CalculateDatesInRange(
                    entry,
                    monthStart,
                    monthEndExclusive);

                foreach (var occurrenceDate in dates)
                {
                    var key = new
                    {
                        EntryId = entry.Id,
                        OccurrenceDate = occurrenceDate
                    };

                    if (anomaliesByOriginalDate.TryGetValue(key, out var anomaly))
                    {
                        if (anomaly.IsDeleted)
                            continue;

                        result.Add(EntryOccurrenceMapper.ToDto(anomaly));
                        continue;
                    }

                    result.Add(EntryOccurrenceMapper.ToDto(entry, occurrenceDate));
                }
            }

            var movedIntoThisMonth = anomalies
                .Where(a =>
                    !a.IsDeleted &&
                    a.NewOccurrenceDate.HasValue &&
                    a.NewOccurrenceDate.Value >= monthStart &&
                    a.NewOccurrenceDate.Value < monthEndExclusive &&
                    (a.OccurrenceDate < monthStart ||
                     a.OccurrenceDate >= monthEndExclusive))
                .ToList();

            foreach (var anomaly in movedIntoThisMonth)
            {
                result.Add(EntryOccurrenceMapper.ToDto(anomaly));
            }

            response.Success = true;
            response.Data = result
                .OrderBy(x => x.OccurrenceDate)
                .ToList();

            return response;
        }

        public async Task<BaseResponse<List<EntryMonthDto>>> GetOccurrencesForDay(int userId, int year, int month,int day)
        {
            var response = new BaseResponse<List<EntryMonthDto>>();

            if (day < 1 || day > DateTime.DaysInMonth(year, month))
            {
                response.SetValidationError("Invalid day for selected month and year.");
                return response;
            }

            var dayStart = new DateTime(year, month, day, 0, 0, 0, DateTimeKind.Utc);
            var dayEndExclusive = dayStart.AddDays(1);

            var monthResponse = await GetOccurrencesForMonth(userId, year, month);

            if (!monthResponse.Success || monthResponse.Data is null)
            {
                response.Success = false;
                response.Message = monthResponse.Message;
                return response;
            }

            response.Success = true;
            response.Data = monthResponse.Data
                .Where(o => o.OccurrenceDate >= dayStart &&
                            o.OccurrenceDate < dayEndExclusive)
                .OrderBy(o => o.OccurrenceDate)
                .ToList();

            return response;
        }

        #region Helper Methods

        private IEnumerable<DateTime> CalculateDatesInRange(Entry entry, DateTime from, DateTime toExclusive)
        {
            if (entry.ScheduledDate >= toExclusive)
                yield break;

            var recurrenceEndExclusive = entry.RecurrenceEndDate?.AddTicks(1) ?? toExclusive;

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

        private static IEnumerable<DateTime> CalculateWeeklyDatesWithMask(Entry entry, DateTime from, DateTime toExclusive, DateTime recurrenceEndExclusive)
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
                    IsDayIncluded(entry.RecurrenceDaysMask!.Value, currentDate.DayOfWeek))
                {
                    yield return currentDate.Date + entry.ScheduledDate.TimeOfDay;
                }

                currentDate = currentDate.AddDays(1);
            }
        }

        private static bool IsCorrectWeekInterval(DateTime startDate, DateTime currentDate,int interval)
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

        private static bool HasRecurrenceChanges(UpdateEntryAllDto request)
        {
            return request.RecurrenceType is not null
                || request.RecurrenceInterval is not null
                || request.RecurrenceDaysMask is not null
                || request.ScheduledDate is not null
                || request.RecurrenceEndDate is not null;
        }

        private async Task ReplaceWholeSeries(int userId, Entry selectedEntry, UpdateEntryAllDto request)
        {
            var oldSeriesId = selectedEntry.SeriesId;

            var entriesInSeries = await _dbContext.Entries
                .Where(e =>
                    e.UserId == userId &&
                    e.SeriesId == oldSeriesId &&
                    e.IsActive)
                .ToListAsync();

            foreach (var entry in entriesInSeries)
            {
                entry.IsActive = false;
            }

            var anomaliesInSeries = await _dbContext.EntryAnomalies
                .Where(a =>
                    a.IsActive &&
                    a.Entry.UserId == userId &&
                    a.Entry.SeriesId == oldSeriesId)
                .ToListAsync();

            foreach (var anomaly in anomaliesInSeries)
            {
                anomaly.IsActive = false;
            }

            var newEntry = new Entry
            {
                UserId = selectedEntry.UserId,

                CategoryId = request.CategoryId,
                Title = request.Title ?? selectedEntry.Title,
                Description = request.Description ?? selectedEntry.Description,
                Amount = request.Amount ?? selectedEntry.Amount,
                Priority = request.Priority ?? selectedEntry.Priority,

                RecurrenceType = request.RecurrenceType ?? selectedEntry.RecurrenceType,
                RecurrenceInterval = request.RecurrenceInterval ?? selectedEntry.RecurrenceInterval,
                RecurrenceDaysMask = request.RecurrenceDaysMask ?? selectedEntry.RecurrenceDaysMask,

                ScheduledDate = request.ScheduledDate.HasValue
                    ? DateTime.SpecifyKind(request.ScheduledDate.Value, DateTimeKind.Utc)
                    : selectedEntry.ScheduledDate,

                RecurrenceEndDate = request.RecurrenceEndDate.HasValue
                    ? DateTime.SpecifyKind(request.RecurrenceEndDate.Value, DateTimeKind.Utc)
                    : selectedEntry.RecurrenceEndDate
            };

            NormalizeRecurrence(newEntry);

            await _dbContext.Entries.AddAsync(newEntry);
            await _dbContext.SaveChangesAsync();

            newEntry.SeriesId = newEntry.Id;
        }

        private async Task UpdateWholeSeriesContent(int userId, Entry selectedEntry, UpdateEntryAllDto request)
        {
            var entriesInSeries = await _dbContext.Entries
                .Where(e =>
                    e.UserId == userId &&
                    e.SeriesId == selectedEntry.SeriesId &&
                    e.IsActive)
                .ToListAsync();

            foreach (var entry in entriesInSeries)
            {
                if (request.CategoryId is not null) entry.CategoryId = request.CategoryId;
                if (request.Title is not null) entry.Title = request.Title;
                if (request.Description is not null) entry.Description = request.Description;
                if (request.Amount is not null) entry.Amount = request.Amount;
                if (request.Priority is not null) entry.Priority = request.Priority.Value;
            }

            var anomaliesInSeries = await _dbContext.EntryAnomalies
                .Where(a =>
                    a.IsActive &&
                    a.Entry.UserId == userId &&
                    a.Entry.SeriesId == selectedEntry.SeriesId)
                .ToListAsync();

            foreach (var anomaly in anomaliesInSeries)
            {
                anomaly.IsActive = false;
            }
        }

        private static void NormalizeRecurrence(Entry entry)
        {
            if (entry.RecurrenceType == RecurrenceType.Once)
            {
                entry.RecurrenceInterval = 1;
                entry.RecurrenceDaysMask = null;
                entry.RecurrenceEndDate = null;
            }

            if (entry.RecurrenceType != RecurrenceType.Weekly)
            {
                entry.RecurrenceDaysMask = null;
            }

            if (entry.RecurrenceInterval < 1)
            {
                entry.RecurrenceInterval = 1;
            }
        }

        private async Task<string?> ValidateUpdateRequest(int userId, UpdateEntryAllDto request, Entry entry)
        {
            if (request.CategoryId is not null)
            {
                var categoryExists = await _dbContext.Categories
                    .AnyAsync(c => c.Id == request.CategoryId && c.UserId == userId && c.IsActive);

                if (!categoryExists) return "Category not found.";
            }

            if (request.RecurrenceInterval is not null && request.RecurrenceInterval < 1)
                return "Recurrence interval must be at least 1.";

            if (request.ScheduledDate is not null && DateTime.UtcNow.Date > request.ScheduledDate.Value.Date)
                return "Scheduled date cannot be in the past.";

            if (request.RecurrenceEndDate is not null)
            {
                var scheduledDate = request.ScheduledDate.HasValue
                    ? DateTime.SpecifyKind(request.ScheduledDate.Value.Date, DateTimeKind.Utc)
                    : entry.ScheduledDate;

                var endDate = DateTime.SpecifyKind(request.RecurrenceEndDate.Value.Date, DateTimeKind.Utc);

                if (endDate < scheduledDate)
                    return "Recurrence end date cannot be before scheduled date.";
            }

            return null;
        }

        private async Task<string?> ValidateUpdateRequest(int userId, UpdateEntryThisAndFutureDto request, Entry entry)
        {
            if (request.CategoryId is not null)
            {
                var categoryExists = await _dbContext.Categories
                    .AnyAsync(c => c.Id == request.CategoryId && c.UserId == userId && c.IsActive);

                if (!categoryExists) return "Category not found.";
            }

            if (request.RecurrenceInterval is not null && request.RecurrenceInterval < 1)
                return "Recurrence interval must be at least 1.";

            if (request.RecurrenceEndDate is not null)
            {
                var endDate = DateTime.SpecifyKind(request.RecurrenceEndDate.Value.Date, DateTimeKind.Utc);
            }

            return null;
        }

        #endregion
    }
}
