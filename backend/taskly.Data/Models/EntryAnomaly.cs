using taskly.Data.Enums;

namespace taskly.Data.Models
{
    public class EntryAnomaly : BaseEntity
    {
        public bool IsActive { get; set; } = true;
        public int EntryId { get; set; }
        public DateTime OccurrenceDate { get; set; }
        public decimal? Amount { get; set; }
        public Priority Priority { get; set; } = Priority.Low;
        public EntryStatus Status { get; set; } = EntryStatus.Pending;
        public Entry Entry { get; set; } = null!;
    }
}
