using System;
using System.Collections.Generic;
using System.Text;
using taskly.Services.Dtos;

namespace taskly.Services.Interfaces
{
    public interface IAuthService
    {
        Task<AuthDto> LoginAsync(LoginDto request);

        Task<AuthDto> RegisterAsync(RegisterDto request);
    }
}
