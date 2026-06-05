using System;
using System.Collections.Generic;
using System.Text;

namespace taskly.Services.Dtos
{
    public class AuthDto : BaseResponse
    {
        public string AccessToken { get; set; } = "";
    }
}
