using FirebaseAdmin.Messaging;
using taskly.Services.Interfaces;

namespace taskly.Services.Services
{
    internal class FirebasePushService : IFirebasePushService
    {
        

        public async Task SendAsync(
            string token,
            string title,
            string body)
        {
            var message = new Message
            {
                Token = token,
                Notification = new Notification
                {
                    Title = title,
                    Body = body
                }
            };

            await FirebaseMessaging.DefaultInstance.SendAsync(message);
        }
    }
}
