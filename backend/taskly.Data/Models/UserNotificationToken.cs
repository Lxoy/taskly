namespace taskly.Data.Models
{
    public class UserNotificationToken : BaseEntity
    {
        public int UserId { get; set; }
        public string Token { get; set; } = string.Empty;
        public string Platform { get; set; } = "android";
        public DateTime? LastUsedAt { get; set; }

        public User User { get; set; } = null!;
    }
}
