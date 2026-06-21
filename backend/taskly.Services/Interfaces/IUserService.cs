using taskly.Services.Dtos.Auth;
using taskly.Services.Dtos.Base;
using taskly.Services.Dtos.User;

namespace taskly.Services.Interfaces
{
    public interface IUserService
    {
        public Task<BaseResponse<AuthDto>> UpdateAsync(int userId, UpdateUserDto request);
        public Task<BaseResponse> UpdatePasswordAsync(int userId, UpdateUserPasswordDto request);
        public Task<BaseResponse<GetUserDto>> GetUser(int userId);
    }
}
