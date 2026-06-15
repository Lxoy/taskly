using Microsoft.EntityFrameworkCore;
using taskly.Data;
using taskly.Data.Enums;
using taskly.Services.Dtos.Base;
using taskly.Services.Dtos.Home;
using taskly.Services.Interfaces;

namespace taskly.Services.Services
{
    internal class HomeService : IHomeService
    {
        private readonly ApplicationDbContext _dbContext;
        private readonly IEntryAnomalyService _occurrenceService;

        public HomeService(ApplicationDbContext dbContext, IEntryAnomalyService occurrenceService)
        {
            _dbContext = dbContext;
            _occurrenceService = occurrenceService;
        }

        public async Task<BaseResponse<HomeDto>> GetHomeData(int userId)
        {
            var response = new BaseResponse<HomeDto>();

            var userExists = await _dbContext.Users.AnyAsync(u => u.Id == userId && u.IsActive);
            if (!userExists)
            {
                response.SetNotFound("User");
                return response;
            }

            var now = DateTime.UtcNow;
            var monthStart = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
            var monthEnd = monthStart.AddMonths(1).AddTicks(-1);

            // Materialized occurrences this month that are done
            var completedOccurrences = await _dbContext.EntryOccurrences
                .Include(o => o.Entry)
                .Where(o => o.Entry.UserId == userId
                         && o.IsActive
                         && o.OccurrenceDate >= monthStart
                         && o.OccurrenceDate <= monthEnd
                         && o.Status == EntryStatus.Completed)
                .ToListAsync();

            var moneySpent = completedOccurrences.Sum(o => o.Amount ?? o.Entry.Amount ?? 0);
            var finishedCount = completedOccurrences.Count;

            // All occurrences for this month (virtual + materialized) via existing service
            var occurrencesResponse = await _occurrenceService.GetOccurrencesForMonth(userId, now.Year, now.Month);
            var occurrences = occurrencesResponse.Success ? occurrencesResponse.Data : new();

            var scheduledCount = occurrences.Count;

            // Upcoming: not completed, from today onward, soonest first, top 10
            var scheduleEntries = occurrences
                .Where(o => o.Status != EntryStatus.Completed && o.OccurrenceDate >= now.Date)
                .OrderBy(o => o.OccurrenceDate)
                .Take(10)
                .Select(o => new HomeScheduleEntryDto
                {
                    Id = o.EntryId,          // virtual occurrences have no own Id
                    Title = o.Title,
                    DueDate = o.OccurrenceDate,
                    Amount = o.Amount,
                    DaysUntilDue = (int)(o.OccurrenceDate.Date - now.Date).TotalDays
                })
                .ToList();

            response.Success = true;
            response.Data = new HomeDto
            {
                TotalMoneySpentThisMonth = moneySpent,
                Month = now.ToString("MMMM"),
                Year = now.Year.ToString(),
                TotalEntriesFinishedThisMonth = finishedCount,
                TotalEntriesScheduledForThisMonth = scheduledCount,
                ScheduleEntries = scheduleEntries
            };

            return response;
        }
    }
}
