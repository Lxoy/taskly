using System;
using System.Collections.Generic;
using System.Text;

namespace taskly.Services.Dtos.Stats
{
    public class MonthlySpendingDto
    {
        public string Month { get; set; } = string.Empty;
        public decimal Amount { get; set; }
    }
}
