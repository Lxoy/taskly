using Microsoft.EntityFrameworkCore;
using taskly.Data;
using taskly.Data.Enums;
using taskly.Data.Models;
using taskly.Services.Dtos.Base;
using taskly.Services.Dtos.Occurrence;
using taskly.Services.Interfaces;
using taskly.Services.Mappers;

namespace taskly.Services.Services
{
    internal class EntryAnomalyService : IEntryAnomalyService
    {
        private readonly ApplicationDbContext _dbContext;

        public EntryAnomalyService(ApplicationDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<BaseResponse<List<OccurrenceDto>>> GetOccurrencesForMonth(int userId, int year, int month)
        {
            var response = new BaseResponse<List<OccurrenceDto>>();

            var monthStart = new DateTime(year, month, 1, 0, 0, 0, DateTimeKind.Utc);
            var monthEnd = monthStart.AddMonths(1).AddTicks(-1);

            var entries = await _dbContext.Entries
                .Where(e => e.UserId == userId && e.IsActive)
                .ToListAsync();

            var materialized = await _dbContext.EntryOccurrences
                .Include(o => o.Entry)
                .Where(o => o.Entry.UserId == userId
                         && o.OccurrenceDate >= monthStart
                         && o.OccurrenceDate <= monthEnd
                         && o.IsActive)
                .ToListAsync();

            var result = new List<OccurrenceDto>();

            foreach (var entry in entries)
            {
                var dates = CalculateDatesInRange(entry, monthStart, monthEnd);

                foreach (var date in dates)
                {
                    var mat = materialized.FirstOrDefault(m =>
                        m.EntryId == entry.Id &&
                        m.OccurrenceDate.Date == date.Date);

                    if (mat != null)
                    {
                        result.Add(EntryOccurrenceMapper.ToDto(mat));
                    }
                    else
                    {
                        result.Add(EntryOccurrenceMapper.ToDto(entry, date));
                    }
                }
            }

            response.Success = true;
            response.Data = result;

            return response;
        }

        private IEnumerable<DateTime> CalculateDatesInRange(Entry entry, DateTime from, DateTime to)
        {
            if (entry.ScheduledDate > to) yield break;

            var endDate = entry.RecurrenceEndDate ?? to;
            var current = entry.ScheduledDate;

            if (entry.RecurrenceType != RecurrenceType.Once)
            {
                while (current < from)
                {
                    current = Advance(current, entry);
                }
            }

            while (current <= to && current <= endDate)
            {
                if (current >= from) yield return current;

                if (entry.RecurrenceType == RecurrenceType.Once) yield break;

                current = Advance(current, entry);
            }
        }

        private static DateTime Advance(DateTime current, Entry entry)
        {
            return entry.RecurrenceType switch
            {
                RecurrenceType.Daily => current.AddDays(entry.RecurrenceInterval),
                RecurrenceType.Weekly => current.AddDays(7 * entry.RecurrenceInterval),
                RecurrenceType.Monthly => current.AddMonths(entry.RecurrenceInterval),
                RecurrenceType.Yearly => current.AddYears(entry.RecurrenceInterval),
                _ => throw new ArgumentOutOfRangeException(
                                              nameof(entry.RecurrenceType),
                                              "Unknown recurrence type")
            };
        }
    }
}
