using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using taskly.Data;
using taskly.Data.Models;
using taskly.Services.Dtos.Auth;
using taskly.Services.Dtos.Base;
using taskly.Services.Interfaces;
using taskly.Services.Options;

namespace taskly.Services.Services
{
    public class AuthService : IAuthService
    {
        private readonly ApplicationDbContext _dbContext;
        private readonly JwtOptions _jwtOptions;

        public AuthService(
            ApplicationDbContext dbContext,
            IOptions<JwtOptions> jwtOptions)
        {
            _dbContext = dbContext;
            _jwtOptions = jwtOptions.Value;
        }

        public async Task<BaseResponse<AuthDto>> LoginAsync(LoginDto request)
        {
            var response = new BaseResponse<AuthDto>();

            var user = await _dbContext.Users
                .FirstOrDefaultAsync(x => x.Email == request.Email);

            if (user == null)
            {
                response.SetUnauthorized();
                return response;
            }

            if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            {
                response.SetUnauthorized();
                return response;
            }

            var jwt = GenerateJwt(user);

            response.Success = true;
            response.Data = new AuthDto
            {
                AccessToken = jwt
            };

            return response;
        }

        public async Task<AuthDto> RefreshUserTokenAsync(User user)
        {
            var jwt = GenerateJwt(user);

            var response = new AuthDto
            {
                AccessToken = jwt
            };

            return response;
        }

        public async Task<BaseResponse<AuthDto>> RegisterAsync(RegisterDto request)
        {
            var response = new BaseResponse<AuthDto>();

            var userExists = await _dbContext.Users
                .AnyAsync(x => x.Email == request.Email);

            if (userExists)
            {
                response.SetError("User already exists.");
                return response;
            }

            var newUser = new User
            {
                CreatedAt = DateTime.UtcNow,
                Email = request.Email,
                Username = request.Username,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password)
            };


            await _dbContext.Users.AddAsync(newUser);

            await _dbContext.SaveChangesAsync();

            var jwt = GenerateJwt(newUser);

            response.Success = true;
            response.Data = new AuthDto
            {
                AccessToken = jwt
            };

            return response;
        }

        private string GenerateJwt(User user)
        {
            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Name, user.Username)
            };

            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(_jwtOptions.Token));

            var creds = new SigningCredentials(
                key,
                SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _jwtOptions.Issuer,
                audience: _jwtOptions.Audience,
                claims: claims,
                expires: DateTime.UtcNow.AddMonths(_jwtOptions.AccessTokenExpirationMonths),
                signingCredentials: creds);

            return new JwtSecurityTokenHandler()
                .WriteToken(token);
        }
    }
}
