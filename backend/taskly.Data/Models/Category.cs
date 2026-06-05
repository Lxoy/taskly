using System;
using System.Collections.Generic;
using System.Text;

namespace taskly.Data.Models
{
    public class Category : BaseEntity
    {
        public bool IsActive { get; set; } = true;
        public int UserId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Color { get; set; } = string.Empty;
        public User User { get; set; } = null!;
    }
}
