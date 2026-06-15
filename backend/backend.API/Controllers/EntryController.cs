using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using taskly.API.ViewModels.Requests;
using taskly.Services.Dtos.Entry;
using taskly.Services.Interfaces;

namespace taskly.API.Controllers
{
    [Route("api/entry")]
    [ApiController]
    [Authorize]
    public class EntryController : ControllerBase
    {
        private readonly IEntryService _entryService;

        public EntryController(IEntryService entryService)
        {
            _entryService = entryService;
        }

        [HttpPost]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> CreateEntry([FromBody] CreateEntryRequest request)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var createNewEntryDto = new CreateEntryDto
            {
                CategoryId = request.CategoryId,
                Title = request.Title,
                Description = request.Description,
                Amount = request.Amount,
                Priority = request.Priority,
                RecurrenceType = request.RecurrenceType,
                RecurrenceInterval = request.RecurrenceInterval,
                ScheduledDate = request.ScheduledDate,
                RecurrenceEndDate = request.RecurrenceEndDate
            };

            var response = await _entryService.CreateNewEntry(userId, createNewEntryDto);

            if (!response.Success)
            {
                return BadRequest(new { response.Message });
            }

            return Ok();
        }

        [HttpPut("{entryId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> UpdateEntry(int entryId, [FromBody] UpdateEntryRequest request)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var updateEntryDto = new UpdateEntryDto
            {
                CategoryId = request.CategoryId,
                Title = request.Title,
                Description = request.Description,
                Amount = request.Amount,
                Priority = request.Priority,
                RecurrenceType = request.RecurrenceType,
                RecurrenceInterval = request.RecurrenceInterval,
                ScheduledDate = request.ScheduledDate,
                RecurrenceEndDate = request.RecurrenceEndDate
            };

            var response = await _entryService.UpdateEntry(userId, entryId, updateEntryDto);
            if (!response.Success)
            {
                return BadRequest(new { response.Message });
            }
            return Ok();
        }

        [HttpDelete("{entryId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> DeleteEntry(int entryId)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();
            var response = await _entryService.DeleteEntry(userId, entryId);
            if (!response.Success)
            {
                return BadRequest(new { response.Message });
            }
            return Ok();
        }
    }
}
