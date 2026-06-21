using taskly.Data.Models;
using taskly.Services.Dtos.Entry;
namespace taskly.Services.Mappers
{
    internal static class EntryOccurrenceMapper
    {
        public static EntryMonthDto ToDto(Entry entry, DateTime occurrenceDate)
        {
            return new EntryMonthDto
            {
                EntryId = entry.Id,
                AnomalyId = null,
                OccurrenceDate = occurrenceDate,

                Title = entry.Title,
                Description = entry.Description,
                Amount = entry.Amount,
                Priority = entry.Priority,
                CategoryId = entry.CategoryId
            };
        }

        public static EntryMonthDto ToDto(EntryAnomaly anomaly)
        {
            return new EntryMonthDto
            {
                EntryId = anomaly.EntryId,
                AnomalyId = anomaly.Id,
                OccurrenceDate = anomaly.NewOccurrenceDate ?? anomaly.OccurrenceDate,

                Title = anomaly.Title,
                Description = anomaly.Description,
                Amount = anomaly.Amount,
                Priority = anomaly.Priority,
                CategoryId = anomaly.CategoryId
            };
        }
    }
}
