namespace taskly.Services.Interfaces
{
    public interface IFirebasePushService
    {
        public Task SendAsync(string token, string title, string body);
    }
}
