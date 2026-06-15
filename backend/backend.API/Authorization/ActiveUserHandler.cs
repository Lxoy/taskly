using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using taskly.Data;

namespace taskly.API.Authorization
{
    public class ActiveUserHandler : AuthorizationHandler<ActiveUserRequirement>
    {
        private readonly ApplicationDbContext _db;

        public ActiveUserHandler(ApplicationDbContext db) => _db = db;

        protected override async Task HandleRequirementAsync(AuthorizationHandlerContext context, ActiveUserRequirement requirement)
        {
            if (!int.TryParse(
                context.User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return;

            var isActive = await _db.Users.AnyAsync(u => u.Id == userId && u.IsActive == true);

            if (isActive)
                context.Succeed(requirement);
        }
    }
}
