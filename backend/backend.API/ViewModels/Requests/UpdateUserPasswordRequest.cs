using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace taskly.API.ViewModels.Requests
{
    public class UpdateUserPasswordRequest
    {
        [Required]
        [StringLength(100, MinimumLength = 8)]
        public string NewPassword { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        [Compare(nameof(NewPassword))]
        public string ConfirmedPassword { get; set; } = string.Empty;
    }
}
