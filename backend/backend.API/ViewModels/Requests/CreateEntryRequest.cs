using System.ComponentModel.DataAnnotations;
using taskly.API.Validators;
using taskly.Data.Enums;

namespace taskly.API.ViewModels.Requests
{
    public class CreateEntryRequest
    {
        public int? CategoryId { get; set; }
        [Required]
        [MaxLength(255)]
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        [Range(0, double.MaxValue)]
        public decimal? Amount { get; set; }
        [Required]
        public Priority Priority { get; set; }
        [Required]
        public RecurrenceType RecurrenceType { get; set; }
        [Range(1, int.MaxValue)]
        public int RecurrenceInterval { get; set; } = 1;
        [Required]
        [FutureDate]
        public DateTime ScheduledDate { get; set; }
        [AfterDate(nameof(ScheduledDate))]
        public DateTime? RecurrenceEndDate { get; set; }

    }
}
