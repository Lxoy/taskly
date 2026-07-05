using taskly.Data.Enums;

namespace taskly.Data.Models
{
    public class EntryAnomaly : BaseEntity
    {

        public int EntryId { get; set; }

        public DateTime OccurrenceDate { get; set; }

        public DateTime? NewOccurrenceDate { get; set; }

        public string Title { get; set; }
        public string? Description { get; set; }
        public decimal? Amount { get; set; }
        public Priority Priority { get; set; }
        public int? CategoryId { get; set; }
        public bool IsDeleted { get; set; } = false;

        public Entry Entry { get; set; } = null!;
        public Category? Category { get; set; }
    }
}
