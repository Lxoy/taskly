using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using taskly.API.ViewModels.Requests;
using taskly.Services.Dtos.Category;
using taskly.Services.Interfaces;

namespace taskly.API.Controllers
{
    [Route("api/category")]
    [ApiController]
    [Authorize]
    public class CategoryController : ControllerBase
    {
        private readonly ICategoryService _categoryService;
        public CategoryController(ICategoryService categoryService)
        {
            _categoryService = categoryService;
        }

        [HttpGet]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> GetCategories()
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var response = await _categoryService.GetCategories(userId);

            if (!response.Success)
                return BadRequest(new { response.Message });

            return Ok(response.Data);
        }

        [HttpPost]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> CreateCategory([FromBody] CreateCategoryRequest request)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var createCategoryDto = new CreateCategoryDto
            {
                Name = request.Name,
                Icon = request.Icon,
                Color = request.Color
            };

            var response = await _categoryService.CreateCategory(userId, createCategoryDto);
            if (!response.Success)
                return BadRequest(new { response.Message });
            return Ok();
        }

        [HttpPut("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdateCategory(int id, [FromBody] UpdateCategoryRequest request)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var updateCategoryDto = new UpdateCategoryDto
            {
                Name = request.Name,
                Icon = request.Icon,
                Color = request.Color
            };
            var response = await _categoryService.UpdateCategory(userId, id, updateCategoryDto);

            if (!response.Success)
                return BadRequest(new { response.Message });

            return Ok();
        }

        [HttpDelete("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteCategory(int id)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var response = await _categoryService.DeleteCategory(userId, id);

            if (!response.Success)
                return BadRequest(new { response.Message });

            return Ok();
        }
    }
}
