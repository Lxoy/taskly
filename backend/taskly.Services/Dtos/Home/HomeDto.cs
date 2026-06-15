namespace taskly.Services.Dtos.Home
{
    public class HomeDto
    {
        public decimal TotalMoneySpentThisMonth { get; set; }
        public string Month { get; set; } = string.Empty;
        public string Year { get; set; } = string.Empty;
        public int TotalEntriesFinishedThisMonth { get; set; }
        public int TotalEntriesScheduledForThisMonth { get; set; }
        public List<HomeScheduleEntryDto> ScheduleEntries { get; set; } = new List<HomeScheduleEntryDto>();
    }
}
