using System;
using System.Collections.Generic;
using System.Text;

namespace taskly.Services.Dtos.Stats
{
    public class RecurrenceStatsDto
    {
        public int OneTime { get; set; }
        public int Recurring { get; set; }
    }
}
