using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using System.Security.Claims;
using taskly.API.ViewModels.Requests;
using taskly.Data.Enums;
using taskly.Data.Models;
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
        [ProducesResponseType(StatusCodes.Status201Created)]
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
                RecurrenceDaysMask = request.RecurrenceDaysMask,
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

        [HttpPut("{entryId:int}/all")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> UpdateEntryAll([FromRoute] int entryId, [FromBody] UpdateEntryRequest request)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var dto = new UpdateEntryAllDto
            {
                CategoryId = request.CategoryId,
                Title = request.Title,
                Description = request.Description,
                Amount = request.Amount,
                Priority = request.Priority,
                RecurrenceType = request.RecurrenceType,
                RecurrenceInterval = request.RecurrenceInterval,
                RecurrenceDaysMask = request.RecurrenceDaysMask,
                ScheduledDate = request.ScheduledDate,
                RecurrenceEndDate = request.RecurrenceEndDate
            };

            var response = await _entryService.UpdateEntryAll(userId, entryId, dto);

            if (!response.Success)
                return BadRequest(new { response.Message });

            return NoContent();
        }

        [HttpPut("{entryId}/split")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> UpdateEntryThisAndFuture(int entryId, [FromBody] UpdateEntryThisAndFutureRequest request)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var updateEntrySplitDto = new UpdateEntryThisAndFutureDto
            {
                EffectiveDate = request.EffectiveDate,
                CategoryId = request.CategoryId,
                Title = request.Title,
                Description = request.Description,
                Amount = request.Amount,
                Priority = request.Priority,
                RecurrenceType = request.RecurrenceType,
                RecurrenceInterval = request.RecurrenceInterval,

                RecurrenceDaysMask = request.RecurrenceDaysMask,
                ScheduledDate = request.ScheduledDate,

                RecurrenceEndDate = request.RecurrenceEndDate
            };

            var response = await _entryService.UpdateEntryThisAndFuture(userId, entryId, updateEntrySplitDto);
            if (!response.Success)
            {
                return BadRequest(new { response.Message });
            }
            return Ok();
        }

        [HttpDelete("{entryId}/all")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> DeleteEntryAll(int entryId)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var response = await _entryService.DeleteEntryAll(userId, entryId);

            if (!response.Success)
            {
                return BadRequest(new { response.Message });
            }
            return NoContent();
        }

        [HttpDelete("{entryId}/future")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> DeleteEntryFuture(int entryId, [FromQuery] [Required(ErrorMessage = "Entry date must be entred.")] DateTime effectiveDate)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var response = await _entryService.DeleteEntryFuture(
                userId,
                entryId,
                effectiveDate);

            if (!response.Success)
            {
                return BadRequest(new { response.Message });
            }

            return NoContent();
        }

        [HttpDelete("{entryId:int}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> DeleteEntry([FromRoute] int entryId,[FromQuery][Required(ErrorMessage = "Entry date must be entered.")] DateTime effectiveDate)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var response = await _entryService.DeleteEntry(
                userId,
                entryId,
                effectiveDate);

            if (!response.Success)
                return BadRequest(new { response.Message });

            return NoContent();
        }

        [HttpGet("occurrences/month")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> GetEntryOccurrencesForMonth([FromQuery] EntryOccurrenceForMonthRequest request)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var response = await _entryService.GetOccurrencesForMonth(
                userId,
                request.Year,
                request.Month);

            if (!response.Success)
                return BadRequest(new { response.Message });

            return Ok(response.Data);
        }

        [HttpGet("occurrences/day")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> GetEntryOccurrencesForDay([FromQuery] EntryOccurrenceForDayRequest request)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var response = await _entryService.GetOccurrencesForDay(
                userId,
                request.Year,
                request.Month,
                request.Day);

            if (!response.Success)
                return BadRequest(new { response.Message });

            return Ok(response.Data);
        }

        [HttpGet("{entryId:int}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> GetEntry([FromRoute] int entryId)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var response = await _entryService.GetEntry(userId, entryId);

            if (!response.Success)
                return BadRequest(new { response.Message });

            return Ok(response.Data);
        }

    }
}
