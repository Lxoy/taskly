using taskly.Data;
using taskly.Services.Dtos.Auth;
using taskly.Services.Dtos.Base;
using taskly.Services.Dtos.User;
using taskly.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using taskly.Data.Models;

namespace taskly.Services.Services
{
    public class UserService : IUserService
    {
        private readonly ApplicationDbContext _dbContext;
        private readonly IAuthService _authService;

        public UserService(ApplicationDbContext dbContext, IAuthService authService)
        {
            _dbContext = dbContext;
            _authService = authService;
        }

        public async Task<BaseResponse<AuthDto>> UpdateAsync(int userId, UpdateUserDto request)
        {
            var response = new BaseResponse<AuthDto>();

            var user = await _dbContext.Users
                .FirstOrDefaultAsync(u => u.Id == userId && u.IsActive);

            if (user is null)
            {
                response.SetNotFound("User");
                return response;
            }

            ApplyUpdates(user, request);

            await _dbContext.SaveChangesAsync();

            response.Data = await _authService.RefreshUserTokenAsync(user);

            response.Success = true;
            return response;
        }

        public Task<BaseResponse> UpdatePasswordAsync(int userId, UpdateUserPasswordDto request)
        {
            throw new NotImplementedException();
        }

        private void ApplyUpdates(User user, UpdateUserDto request)
        {
            if (!string.IsNullOrWhiteSpace(request.FirstName))
                user.FirstName = request.FirstName.Trim();

            if (!string.IsNullOrWhiteSpace(request.LastName))
                user.LastName = request.LastName.Trim();

            if (!string.IsNullOrWhiteSpace(request.Username))
                user.Username = request.Username.Trim();

            if (!string.IsNullOrWhiteSpace(request.Email))
                user.Email = request.Email.Trim();

            if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
                user.PhoneNumber = request.PhoneNumber.Trim();
        }
    }
}
