using System.ComponentModel.DataAnnotations;

namespace taskly.API.ViewModels.Requests
{
    public class EntryOccurrenceForMonthRequest
    {
        [Required]
        [Range(1, 9999)]
        public int Year { get; set; }

        [Required]
        [Range(1, 12)]
        public int Month { get; set; }
    }
}
