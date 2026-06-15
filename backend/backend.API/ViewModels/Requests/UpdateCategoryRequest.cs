using System.ComponentModel.DataAnnotations;

namespace taskly.API.ViewModels.Requests
{
    public class UpdateCategoryRequest
    {
        [MaxLength(100)]
        public string? Name { get; set; }

        [MaxLength(100)]
        public string? Icon { get; set; }

        [MaxLength(7)]
        [RegularExpression("^#[0-9A-Fa-f]{6}$", ErrorMessage = "Invalid hex color.")]
        public string? Color { get; set; }
    }
}
