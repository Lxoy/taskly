namespace taskly.Services.Dtos.Home
{
    public class HomeScheduleEntryDto
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public int DaysUntilDue { get; set; }
        public DateTime? DueDate { get; set; }
        public decimal? Amount { get; set; }
    }
}
