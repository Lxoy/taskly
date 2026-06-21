using taskly.Services.Dtos.Base;
using taskly.Services.Dtos.Stats;

namespace taskly.Services.Interfaces
{
    public interface IStatsService
    {
        public Task<BaseResponse<StatsDto>> GetStats(int userId);
    }
}
