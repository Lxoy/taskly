using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using taskly.Services.Interfaces;

namespace taskly.API.Controllers
{
    [Route("api")]
    [ApiController]
    [Authorize]
    public class HomeController : ControllerBase
    {
        private readonly IHomeService _homeService;

        public HomeController(IHomeService homeService)
        {
            _homeService = homeService;
        }

        [HttpGet("home")]
        public async Task<IActionResult> GetHomeData()
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();
            var response = await _homeService.GetHomeData(userId);
            if (!response.Success)
            {
                return BadRequest(new { response.Message });
            }
            return Ok(response.Data);
        }
    }
}
