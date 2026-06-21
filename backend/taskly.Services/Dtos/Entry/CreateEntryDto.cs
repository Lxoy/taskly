using taskly.Data.Enums;

namespace taskly.Services.Dtos.Entry
{
    public class CreateEntryDto
    {
        public int? CategoryId { get; set; }

        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }

        public decimal? Amount { get; set; }

        public Priority Priority { get; set; }

        public RecurrenceType RecurrenceType { get; set; }

        public int RecurrenceInterval { get; set; } = 1;

        public WeekDays? RecurrenceDaysMask { get; set; }

        public DateTime ScheduledDate { get; set; }

        public DateTime? RecurrenceEndDate { get; set; }
    }
}
