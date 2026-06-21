using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using taskly.API.ViewModels.Requests;
using taskly.Services.Dtos.User;
using taskly.Services.Interfaces;

namespace taskly.API.Controllers
{
    [Authorize]
    [Route("api/user")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;

        public UserController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpPut]
        public async Task<IActionResult> Update([FromBody] UpdateUserRequest request)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var updateUserDto = new UpdateUserDto
            {
                FirstName = request.FirstName,
                LastName = request.LastName,
                Username = request.Username,
                Email = request.Email,
                PhoneNumber = request.PhoneNumber
            };

            var response =
                await _userService.UpdateAsync(userId, updateUserDto);

            if (!response.Success)
                return BadRequest(new { response.Message });

            return Ok(new
            {
                token = response.Data.AccessToken
            });
        }

        [HttpPut("password")]
        public async Task<IActionResult> UpdatePassword([FromBody] UpdateUserPasswordRequest request)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var updateUserPasswordDto = new UpdateUserPasswordDto
            {
                 NewPassword = request.NewPassword,
                 ConfirmedPassword = request.ConfirmedPassword
            };

            var response =
                await _userService.UpdatePasswordAsync(userId, updateUserPasswordDto);

            if (!response.Success)
                return BadRequest(new { response.Message });

            return NoContent();
        }

        [HttpGet]
        public async Task<IActionResult> GetUser()
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var response = await _userService.GetUser(userId);

            if (!response.Success)
                return BadRequest(new { response.Message });

            return Ok(response.Data);
        }
    }
}
