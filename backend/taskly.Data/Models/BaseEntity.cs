using System;
using System.Collections.Generic;
using System.Text;

namespace taskly.Data.Models
{
    public class BaseEntity
    {
        public int Id { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ModifiedAt { get; set; }
    }
}
