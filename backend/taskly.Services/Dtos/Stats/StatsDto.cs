
namespace taskly.Services.Dtos.Stats
{
    public class StatsDto
    {
        public decimal TotalSpentThisMonth { get; set; }
        public decimal AverageAmount { get; set; }

        public int TotalOccurrencesThisMonth { get; set; }
        public int CompletedOccurrencesThisMonth { get; set; }
        public int UpcomingOccurrencesThisMonth { get; set; }

        public string TopCategoryName { get; set; } = "None";
        public decimal TopCategoryAmount { get; set; }

        public List<MonthlySpendingDto> MonthlySpending { get; set; } = new();
        public List<CategorySpendingDto> CategorySpending { get; set; } = new();
        public PriorityStatsDto PriorityOverview { get; set; } = new();
        public RecurrenceStatsDto RecurrenceOverview { get; set; } = new();
    }
}
