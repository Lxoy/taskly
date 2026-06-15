using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using taskly.API.ViewModels.Requests;
using taskly.Services.Interfaces;

namespace taskly.API.Controllers
{
    [Route("api/entry-anomaly")]
    [ApiController]
    [Authorize]
    public class EntryOccurrenceController : ControllerBase
    {
        private readonly IEntryAnomalyService _entryOccurrenceService;

        public EntryOccurrenceController(IEntryAnomalyService entryOccurrenceService)
        {
            _entryOccurrenceService = entryOccurrenceService;
        }

        [HttpGet]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> GetEntryOccurrencesForMonth([FromQuery] EntryOccurrenceForMonthRequest request)
        {
            if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
                return Unauthorized();

            var response = await _entryOccurrenceService.GetOccurrencesForMonth(userId, request.Year, request.Month);

            if(!response.Success)
                return BadRequest(new {response.Message});

            return Ok(response.Data);
        }
    }
}
