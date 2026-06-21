using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using taskly.API.ViewModels.Requests;
using taskly.Services.Dtos.EntryAnomaly;
using taskly.Services.Interfaces;
using taskly.Services.Services;

namespace taskly.API.Controllers
{
    [Route("api/entry-anomaly")]
    [ApiController]
    [Authorize]
    public class EntryAnomalyController : ControllerBase
    {
        private readonly IEntryAnomalyService _entryAnomalyService;

        public EntryAnomalyController(IEntryAnomalyService entryAnomalyService)
        {
            _entryAnomalyService = entryAnomalyService;
        }

        [HttpGet("{anomalyId:int}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> GetEntry([FromRoute] int anomalyId)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var response = await _entryAnomalyService.GetAnomaly(userId, anomalyId);

            if (!response.Success)
                return BadRequest(new { response.Message });

            return Ok(response.Data);
        }


        [HttpPost("{entryId:int}/anomaly")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> CreateEntryAnomaly([FromRoute] int entryId, [FromBody] CreateEntryAnomalyRequest request)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var dto = new CreateEntryAnomalyDto
            {
                EntryId = entryId,
                OccurrenceDate = request.OccurrenceDate,
                NewOccurrenceDate = request.NewOccurrenceDate,
                Title = request.Title,
                Description = request.Description,
                Amount = request.Amount,
                Priority = request.Priority,
                CategoryId = request.CategoryId
            };

            var response = await _entryAnomalyService.CreateEntryAnomaly(userId, dto);

            if (!response.Success)
                return BadRequest(new { response.Message });

            return NoContent();
        }

        [HttpPut("{anomalyId:int}/anomaly")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> EditEntryAnomaly([FromRoute] int anomalyId, [FromBody] EditEntryAnomalyRequest request)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var dto = new EditEntryAnomalyDto
            {
                AnomalyId = anomalyId,
                OccurrenceDate = request.OccurrenceDate,
                NewOccurrenceDate = request.NewOccurrenceDate,
                Title = request.Title,
                Description = request.Description,
                Amount = request.Amount,
                Priority = request.Priority,
                CategoryId = request.CategoryId
            };

            var response = await _entryAnomalyService.EditEntryAnomaly(userId, dto);

            if (!response.Success)
                return BadRequest(new { response.Message });

            return NoContent();
        }

        [HttpDelete("{anomalyId:int}/anomaly")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> DeleteEntryAnomaly([FromRoute] int anomalyId)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var response = await _entryAnomalyService.DeleteEntryAnomaly(userId, anomalyId);

            if (!response.Success)
                return BadRequest(new { response.Message });

            return NoContent();
        }
    }
}
