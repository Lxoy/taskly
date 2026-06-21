using Microsoft.EntityFrameworkCore;
using taskly.Data;
using taskly.Data.Enums;
using taskly.Services.Dtos.Base;
using taskly.Services.Dtos.Stats;
using taskly.Services.Interfaces;

namespace taskly.Services.Services
{
    internal class StatsService : IStatsService
    {
        private readonly ApplicationDbContext _dbContext;
        private readonly IEntryService _entryService;
        private readonly TimeProvider _timeProvider;

        public StatsService(
            ApplicationDbContext dbContext,
            IEntryService entryService,
            TimeProvider timeProvider)
        {
            _dbContext = dbContext;
            _entryService = entryService;
            _timeProvider = timeProvider;
        }

        public async Task<BaseResponse<StatsDto>> GetStats(int userId)
        {
            var response = new BaseResponse<StatsDto>();

            var userExists = await _dbContext.Users
                .AnyAsync(u => u.Id == userId && u.IsActive);

            if (!userExists)
            {
                response.SetNotFound("User");
                return response;
            }

            var now = _timeProvider.GetUtcNow().UtcDateTime;

            var currentMonthResponse = await _entryService.GetOccurrencesForMonth(
                userId,
                now.Year,
                now.Month);

            var currentMonthOccurrences =
                currentMonthResponse.Success && currentMonthResponse.Data is not null
                    ? currentMonthResponse.Data
                    : new();

            var completedThisMonth = currentMonthOccurrences
                .Where(o => o.OccurrenceDate < now)
                .ToList();

            var upcomingThisMonth = currentMonthOccurrences
                .Where(o => o.OccurrenceDate >= now)
                .ToList();

            var totalSpentThisMonth = completedThisMonth.Sum(o => o.Amount ?? 0);
            var averageAmount = completedThisMonth.Count == 0
                ? 0
                : totalSpentThisMonth / completedThisMonth.Count;

            var categories = await _dbContext.Categories
                .Where(c => c.UserId == userId && c.IsActive)
                .ToListAsync();

            var categorySpending = completedThisMonth
                .GroupBy(o => o.CategoryId)
                .Select(g =>
                {
                    var category = categories.FirstOrDefault(c => c.Id == g.Key);

                    return new CategorySpendingDto
                    {
                        CategoryId = g.Key,
                        CategoryName = category?.Name ?? "Uncategorized",
                        CategoryColor = category?.Color,
                        CategoryIcon = category?.Icon,
                        Amount = g.Sum(x => x.Amount ?? 0)
                    };
                })
                .OrderByDescending(x => x.Amount)
                .ToList();

            var topCategory = categorySpending.FirstOrDefault();

            var monthlySpending = new List<MonthlySpendingDto>();

            for (var i = 5; i >= 0; i--)
            {
                var monthDate = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc)
                    .AddMonths(-i);

                var monthResponse = await _entryService.GetOccurrencesForMonth(
                    userId,
                    monthDate.Year,
                    monthDate.Month);

                var monthOccurrences =
                    monthResponse.Success && monthResponse.Data is not null
                        ? monthResponse.Data
                        : new();

                var amount = monthOccurrences
                    .Where(o => o.OccurrenceDate < now)
                    .Sum(o => o.Amount ?? 0);

                monthlySpending.Add(new MonthlySpendingDto
                {
                    Month = monthDate.ToString("MMM"),
                    Amount = amount
                });
            }

            var priorityOverview = new PriorityStatsDto
            {
                Low = currentMonthOccurrences.Count(o => o.Priority == Priority.Low),
                Medium = currentMonthOccurrences.Count(o => o.Priority == Priority.Medium),
                High = currentMonthOccurrences.Count(o => o.Priority == Priority.High)
            };

            var entriesThisMonthIds = currentMonthOccurrences
                .Select(o => o.EntryId)
                .Distinct()
                .ToList();

            var entries = await _dbContext.Entries
                .Where(e =>
                    entriesThisMonthIds.Contains(e.Id) &&
                    e.UserId == userId &&
                    e.IsActive)
                .ToListAsync();

            var recurrenceOverview = new RecurrenceStatsDto
            {
                OneTime = entries.Count(e => e.RecurrenceType == RecurrenceType.Once),
                Recurring = entries.Count(e => e.RecurrenceType != RecurrenceType.Once)
            };

            response.Success = true;
            response.Data = new StatsDto
            {
                TotalSpentThisMonth = totalSpentThisMonth,
                AverageAmount = averageAmount,

                TotalOccurrencesThisMonth = currentMonthOccurrences.Count,
                CompletedOccurrencesThisMonth = completedThisMonth.Count,
                UpcomingOccurrencesThisMonth = upcomingThisMonth.Count,

                TopCategoryName = topCategory?.CategoryName ?? "None",
                TopCategoryAmount = topCategory?.Amount ?? 0,

                MonthlySpending = monthlySpending,
                CategorySpending = categorySpending,
                PriorityOverview = priorityOverview,
                RecurrenceOverview = recurrenceOverview
            };

            return response;
        }
    }
}
