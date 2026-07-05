using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Security.Claims;
using taskly.API.ViewModels.Requests;
using taskly.Data.Models;
using taskly.Services.Interfaces;

namespace taskly.API.Controllers
{
    [ApiController]
    [Route("api/notifications")]
    [Authorize]
    public class NotificationsController : ControllerBase
    {
        private readonly INotificationService _notificationService;
        private readonly IFirebasePushService _firebaseService;

        public NotificationsController(INotificationService notificationService, IFirebasePushService firebaseService)
        {
            _notificationService = notificationService;
            _firebaseService = firebaseService;
        }

        [HttpPost("register-token")]
        public async Task<IActionResult> RegisterToken(RegisterNotificationTokenRequest request)
        {
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

            await _notificationService.RegisterTokenAsync(
                userId,
                request.Token,
                request.Platform ?? "android"
            );

            return Ok();
        }

        [HttpPost("test-push")]
        public async Task<IActionResult> TestPush([FromBody] TestPushRequest request)
        {
            await _firebaseService.SendAsync(
                request.Token,
                "Taskly test",
                "Push iz .NET backenda radi 🎉"
            );

            return Ok();
        }
    }
}
