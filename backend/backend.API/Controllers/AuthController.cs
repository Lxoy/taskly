using Microsoft.AspNetCore.Mvc;
using taskly.Services.Interfaces;
using taskly.API.ViewModels.Requests;
using taskly.Services.Dtos.Auth;

namespace taskly.API.Controllers
{
    [Route("api/auth")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            var loginRequest = new LoginDto
            {
                Email = request.Email,
                Password = request.Password
            };

            var response =
                await _authService.LoginAsync(loginRequest);

            if (!response.Success)
                return Unauthorized(new { response.Message });

            return Ok(new
            {
                token = response.Data.AccessToken
            });
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            var registerRequest = new RegisterDto
            {
                Email = request.Email,
                Username = request.Username,
                Password = request.Password
            };

            var response =
                await _authService.RegisterAsync(registerRequest);

            if (!response.Success)
                return BadRequest(new { response.Message });

            return Ok(new
            {
                token = response.Data.AccessToken
            });
        }
    }
}
