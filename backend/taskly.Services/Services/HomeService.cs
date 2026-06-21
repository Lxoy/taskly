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
        private readonly IEntryService _entryService;
        private readonly TimeProvider _timeProvider;

        public HomeService(
            ApplicationDbContext dbContext,
            IEntryService entryService,
            TimeProvider timeProvider)
        {
            _dbContext = dbContext;
            _entryService = entryService;
            _timeProvider = timeProvider;
        }

        public async Task<BaseResponse<HomeDto>> GetHomeData(int userId)
        {
            var response = new BaseResponse<HomeDto>();

            var userExists = await _dbContext.Users
                .AnyAsync(u => u.Id == userId && u.IsActive);

            if (!userExists)
            {
                response.SetNotFound("User");
                return response;
            }

            var now = _timeProvider.GetUtcNow().UtcDateTime;

            var occurrencesResponse = await _entryService.GetOccurrencesForMonth(
                userId,
                now.Year,
                now.Month);

            var occurrences = occurrencesResponse.Success && occurrencesResponse.Data is not null
                ? occurrencesResponse.Data
                : new();

            var finishedOccurrences = occurrences
                .Where(o => o.OccurrenceDate < now)
                .ToList();

            var upcomingOccurrences = occurrences
                .Where(o => o.OccurrenceDate >= now)
                .OrderBy(o => o.OccurrenceDate)
                .ToList();

            response.Success = true;
            response.Data = new HomeDto
            {
                TotalMoneySpentThisMonth = finishedOccurrences.Sum(o => o.Amount ?? 0),
                Month = now.ToString("MMMM"),
                Year = now.Year.ToString(),
                TotalEntriesFinishedThisMonth = finishedOccurrences.Count,
                TotalEntriesScheduledForThisMonth = upcomingOccurrences.Count,
                ScheduleEntries = upcomingOccurrences
                    .Take(10)
                    .Select(o => new HomeScheduleEntryDto
                    {
                        EntryId = o.EntryId,
                        AnomalyId = o.AnomalyId,
                        Title = o.Title,
                        CategoryId = o.CategoryId,
                        DueDate = o.OccurrenceDate,
                        Amount = o.Amount,
                        DaysUntilDue = (int)(o.OccurrenceDate.Date - now.Date).TotalDays
                    })
                    .ToList()
            };

            return response;
        }
    }
}
