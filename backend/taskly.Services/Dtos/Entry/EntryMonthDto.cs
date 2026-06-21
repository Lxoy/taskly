using taskly.Data.Enums;

namespace taskly.Services.Dtos.Entry
{
    public class EntryMonthDto
    {
        public int EntryId { get; set; }
        public int? AnomalyId { get; set; }

        public DateTime OccurrenceDate { get; set; }

        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal? Amount { get; set; }
        public Priority Priority { get; set; }
        public int? CategoryId { get; set; }
    }
}
