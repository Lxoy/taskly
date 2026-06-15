using System.ComponentModel.DataAnnotations;

namespace taskly.API.ViewModels.Requests
{
    public class CreateCategoryRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string Icon { get; set; } = string.Empty;

        [Required]
        [MaxLength(7)]
        [RegularExpression("^#[0-9A-Fa-f]{6}$", ErrorMessage = "Invalid hex color.")]
        public string Color { get; set; } = string.Empty;
    }
}
