using taskly.Data.Enums;

namespace taskly.Data.Models
{
    public class Entry : BaseEntity
    {
        public bool IsActive { get; set; } = true;
        public int UserId { get; set; }
        public int? CategoryId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal? Amount { get; set; }
        public Priority Priority { get; set; } = Priority.Low;
        public RecurrenceType RecurrenceType { get; set; } = RecurrenceType.Once;
        public int RecurrenceInterval { get; set; } = 1;
        public WeekDays? RecurrenceDaysMask { get; set; }
        public DateTime ScheduledDate { get; set; }
        public DateTime? RecurrenceEndDate { get; set; }
        public int SeriesId { get; set; }
        public User User { get; set; } = null!;

        public Category? Category { get; set; }
        public ICollection<EntryAnomaly> EntryOccurrences { get; set; } = new List<EntryAnomaly>();
    }
}
