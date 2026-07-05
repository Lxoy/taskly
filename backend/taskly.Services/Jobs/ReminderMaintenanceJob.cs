using Microsoft.EntityFrameworkCore;
using taskly.Data;
using taskly.Data.Enums;

namespace taskly.Services.Jobs
{
    public class ReminderMaintenanceJob
    {
        private readonly ApplicationDbContext _dbContext;

        public ReminderMaintenanceJob(ApplicationDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task RunAsync()
        {
            var now = DateTime.UtcNow;

            var pendingReminders = await _dbContext.Reminders
                .Include(r => r.Entry)
                .Where(r =>
                    r.IsActive &&
                    r.Status == ReminderStatus.Pending &&
                    r.RemindAt >= now.AddHours(-2))
                .ToListAsync();

            foreach (var reminder in pendingReminders)
            {
                // Entry soft-deleted
                if (!reminder.Entry.IsActive)
                {
                    Cancel(reminder);
                    continue;
                }

                // Entry recurrence ended before this occurrence
                if (reminder.Entry.RecurrenceEndDate.HasValue &&
                    reminder.OccurrenceDate > reminder.Entry.RecurrenceEndDate.Value)
                {
                    Cancel(reminder);
                    continue;
                }

                var anomaly = await _dbContext.EntryAnomalies
                    .FirstOrDefaultAsync(a =>
                        a.IsActive &&
                        a.EntryId == reminder.EntryId &&
                        a.OccurrenceDate == reminder.OccurrenceDate);

                if (anomaly is null)
                    continue;

                if (anomaly.IsDeleted)
                {
                    Cancel(reminder);
                    continue;
                }

                if (anomaly.NewOccurrenceDate.HasValue &&
                    anomaly.NewOccurrenceDate.Value != reminder.OccurrenceDate)
                {
                    Cancel(reminder);
                    continue;
                }
            }

            await _dbContext.SaveChangesAsync();
        }

        private static void Cancel(Data.Models.Reminder reminder)
        {
            reminder.Status = ReminderStatus.Cancelled;
            reminder.ModifiedAt = DateTime.UtcNow;
        }
    }
}
