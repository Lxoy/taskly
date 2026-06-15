using taskly.Services.Dtos.Base;
using taskly.Services.Dtos.Occurrence;

namespace taskly.Services.Interfaces
{
    public interface IEntryAnomalyService
    {
        public Task<BaseResponse<List<OccurrenceDto>>> GetOccurrencesForMonth(int userId, int year, int month);
    }
}
