using System.ComponentModel.DataAnnotations;

namespace taskly.API.ViewModels.Requests
{
    public class EntryOccurrenceForDayRequest
    {
        [Required]
        [Range(1, int.MaxValue)]
        public int Year { get; set; }
        [Required]
        [Range(1, 12)]
        public int Month { get; set; }
        [Required]
        [Range(1, 31)]
        public int Day { get; set; }
    }
}
