using taskly.Data.Enums;

namespace taskly.Services.Dtos.Occurrence
{
    public class OccurrenceDto
    {
        public int EntryId { get; set; }
        public int? OccurrenceId { get; set; }
        public DateTime OccurrenceDate { get; set; }

        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal? Amount { get; set; }
        public Priority Priority { get; set; }
        public int? CategoryId { get; set; }

        public EntryStatus Status { get; set; }
        public bool IsMaterialized { get; set; }

        public RecurrenceType RecurrenceType { get; set; }
    }
}
