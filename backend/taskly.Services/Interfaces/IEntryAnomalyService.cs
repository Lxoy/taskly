using taskly.Services.Dtos.Base;
using taskly.Services.Dtos.EntryAnomaly;

namespace taskly.Services.Interfaces
{
    public interface IEntryAnomalyService
    {
        public Task<BaseResponse<AnomalyDto>> GetAnomaly(int userId, int anomalyId);
        public Task<BaseResponse> CreateEntryAnomaly(int userId, CreateEntryAnomalyDto dto);
        public Task<BaseResponse> EditEntryAnomaly(int userId, EditEntryAnomalyDto dto);
        public Task<BaseResponse> DeleteEntryAnomaly(int userId, int anomalyId);
    }
}
