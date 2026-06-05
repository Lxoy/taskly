using System;
using System.Collections.Generic;
using System.Text;

namespace taskly.Services.Options
{
    public class JwtOptions
    {
        public string Token { get; set; } = string.Empty;

        public string Issuer { get; set; } = string.Empty;

        public string Audience { get; set; } = string.Empty;
        public int AccessTokenExpirationMonths { get; set; }
    }
}
