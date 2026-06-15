using System.ComponentModel.DataAnnotations;

namespace taskly.API.ViewModels.Requests
{
    public class UpdateUserRequest
    {
        [MaxLength(50)]
        public string? FirstName { get; set; }

        [MaxLength(50)]
        public string? LastName { get; set; }

        [MaxLength(30)]
        public string? Username { get; set; }

        [MaxLength(100)]
        [EmailAddress]
        public string? Email { get; set; }

        [MaxLength(20)]
        [Phone]
        public string? PhoneNumber { get; set; }
    }
}
