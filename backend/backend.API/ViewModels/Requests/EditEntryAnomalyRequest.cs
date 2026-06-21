using System.ComponentModel.DataAnnotations;
using taskly.Data.Enums;

namespace taskly.API.ViewModels.Requests
{
    public class EditEntryAnomalyRequest
    {
        public DateTime? OccurrenceDate { get; set; }

        public DateTime? NewOccurrenceDate { get; set; }

        [Required(ErrorMessage = "Title musn't be empty.")]
        [MaxLength(255)]
        public string? Title { get; set; }

        public string? Description { get; set; }

        [Range(0, double.MaxValue)]
        public decimal? Amount { get; set; }

        public Priority? Priority { get; set; }

        public int? CategoryId { get; set; }
    }
}
