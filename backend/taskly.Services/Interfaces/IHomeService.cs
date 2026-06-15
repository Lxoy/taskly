using taskly.Services.Dtos.Base;
using taskly.Services.Dtos.Home;

namespace taskly.Services.Interfaces
{
    public interface IHomeService
    {
        public Task<BaseResponse<HomeDto>> GetHomeData(int userId);
    }
}
