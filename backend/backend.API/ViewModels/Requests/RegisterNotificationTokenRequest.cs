namespace taskly.API.ViewModels.Requests
{
    public class RegisterNotificationTokenRequest
    {
        public string Token { get; set; } = string.Empty;
        public string? Platform { get; set; }
    }
}
