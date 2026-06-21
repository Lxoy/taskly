using taskly.Data.Enums;

namespace taskly.Services.Dtos.Entry
{
    public class UpdateEntryThisAndFutureDto
    {
        public DateTime EffectiveDate { get; set; }
        public int? CategoryId { get; set; }
        public string? Title { get; set; }
        public string? Description { get; set; }
        public decimal? Amount { get; set; }
        public Priority? Priority { get; set; }
        public DateTime? ScheduledDate { get; set; }
        public RecurrenceType? RecurrenceType { get; set; }
        public int? RecurrenceInterval { get; set; }
        public WeekDays? RecurrenceDaysMask { get; set; }
        public DateTime? RecurrenceEndDate { get; set; }
    }
}
