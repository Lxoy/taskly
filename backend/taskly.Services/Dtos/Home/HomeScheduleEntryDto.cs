namespace taskly.Services.Dtos.Home
{
    public class HomeScheduleEntryDto
    {
        public int EntryId { get; set; }
        public int? AnomalyId { get; set; }
        public string Title { get; set; } = string.Empty;
        public int? CategoryId { get; set; }
        public int DaysUntilDue { get; set; }
        public DateTime? DueDate { get; set; }
        public decimal? Amount { get; set; }
    }
}
