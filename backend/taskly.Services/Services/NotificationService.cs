using Microsoft.EntityFrameworkCore;
using taskly.Data;
using taskly.Data.Models;
using taskly.Services.Interfaces;

namespace taskly.Services.Services
{
    internal class NotificationService : INotificationService
    {
        private readonly ApplicationDbContext _dbContext;

        public NotificationService(ApplicationDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task RegisterTokenAsync(int userId, string token, string platform = "android")
        {

            var existing = await _dbContext.UserNotificationTokens
                .FirstOrDefaultAsync(t => t.UserId == userId && t.Token == token && t.Platform == platform);


            if (existing == null)
            {
                _dbContext.UserNotificationTokens.Add(new UserNotificationToken
                {
                    UserId = userId,
                    Token = token,
                    Platform = platform,
                    IsActive = true
                });
            }
            else
            {
                existing.IsActive = true;
                existing.LastUsedAt = DateTime.UtcNow;
                existing.ModifiedAt = DateTime.UtcNow;
            }

            await _dbContext.SaveChangesAsync();
        }
    }
}
