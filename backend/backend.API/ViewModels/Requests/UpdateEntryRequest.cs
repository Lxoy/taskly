using System.ComponentModel.DataAnnotations;
using taskly.Data.Enums;

namespace taskly.API.ViewModels.Requests
{
    public class UpdateEntryRequest
    {
        public int? CategoryId { get; set; }
        [MaxLength(255)]
        public string? Title { get; set; }
        public string? Description { get; set; }
        [Range(0, double.MaxValue)]
        public decimal? Amount { get; set; }
        public Priority? Priority { get; set; }
        public RecurrenceType? RecurrenceType { get; set; }
        [Range(1, int.MaxValue)]
        public int? RecurrenceInterval { get; set; }
        public WeekDays? RecurrenceDaysMask { get; set; }
        public DateTime? ScheduledDate { get; set; }
        public DateTime? RecurrenceEndDate { get; set; }
    }
}
