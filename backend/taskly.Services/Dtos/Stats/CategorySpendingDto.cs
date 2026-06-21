using System;
using System.Collections.Generic;
using System.Text;

namespace taskly.Services.Dtos.Stats
{
    public class CategorySpendingDto
    {
        public int? CategoryId { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public string? CategoryColor { get; set; }
        public string? CategoryIcon { get; set; }
        public decimal Amount { get; set; }
    }
}
