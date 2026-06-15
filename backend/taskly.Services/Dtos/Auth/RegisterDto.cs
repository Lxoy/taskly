using System;
using System.Collections.Generic;
using System.Text;

namespace taskly.Services.Dtos.Auth
{
    public class RegisterDto
    {
        public string Email { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }
}
