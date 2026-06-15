using taskly.Data.Models;
using taskly.Services.Dtos.Auth;
using taskly.Services.Dtos.Base;

namespace taskly.Services.Interfaces
{
    public interface IAuthService
    {
        Task<BaseResponse<AuthDto>> LoginAsync(LoginDto request);
        Task<AuthDto> RefreshUserTokenAsync(User user);
        Task<BaseResponse<AuthDto>> RegisterAsync(RegisterDto request);
    }
}
