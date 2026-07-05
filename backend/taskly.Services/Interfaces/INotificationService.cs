namespace taskly.Services.Interfaces
{
    public interface INotificationService
    {
        public Task RegisterTokenAsync(int userId, string token, string platform = "android");
    }
}
