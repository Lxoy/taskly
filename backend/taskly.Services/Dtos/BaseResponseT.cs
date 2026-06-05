using System;
using System.Collections.Generic;
using System.Text;

namespace taskly.Services.Dtos
{
    public class BaseResponse<T> : BaseResponse
    {
        public T? Data { get; set; }
    }
}
