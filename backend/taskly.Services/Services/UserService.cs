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

        public async Task<BaseResponse> UpdatePasswordAsync(int userId, UpdateUserPasswordDto request)
        {
            var response = new BaseResponse();

            var user = await _dbContext.Users
                .FirstOrDefaultAsync(u => u.Id == userId && u.IsActive);

            if (user is null)
            {
                response.SetNotFound("User");
                return response;
            }

            if (string.IsNullOrWhiteSpace(request.NewPassword))
            {
                response.SetValidationError("Password is required.");
                return response;
            }

            if (request.NewPassword != request.ConfirmedPassword)
            {
                response.SetValidationError("Passwords do not match.");
                return response;
            }

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);

            await _dbContext.SaveChangesAsync();

            response.Success = true;
            return response;
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

        public async Task<BaseResponse<GetUserDto>> GetUser(int userId)
        {
            var response = new BaseResponse<GetUserDto>();

            var user = await _dbContext.Users
                .FirstOrDefaultAsync(u => u.Id == userId && u.IsActive);

            if (user is null)
            {
                response.SetNotFound("User");
                return response;
            }

            GetUserDto userDto = new GetUserDto
            {
                FirstName = user.FirstName,
                LastName = user.LastName,
                Username = user.Username,
                Email = user.Email,
                PhoneNumber = user.PhoneNumber
            };


            response.Data = userDto;

            response.Success = true;
            return response;
        }
    }
}
