using taskly.Data.Enums;

namespace taskly.Services.Dtos.EntryAnomaly
{
    public class EditEntryAnomalyDto
    {
        public int AnomalyId { get; set; }
        public DateTime? OccurrenceDate { get; set; }
        public DateTime? NewOccurrenceDate { get; set; }

        public string? Title { get; set; }
        public string? Description { get; set; }
        public decimal? Amount { get; set; }
        public Priority? Priority { get; set; }
        public int? CategoryId { get; set; }
    }
}
