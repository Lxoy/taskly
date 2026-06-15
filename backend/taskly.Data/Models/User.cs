using System;
using System.Collections.Generic;
using System.Text;

namespace taskly.Data.Models
{
    public class User : BaseEntity
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public bool IsActive { get; set; } = true;
        public ICollection<Category> Categories { get; set; } = new List<Category>();
        public ICollection<Entry> Entries { get; set; } = new List<Entry>();
    }
}
