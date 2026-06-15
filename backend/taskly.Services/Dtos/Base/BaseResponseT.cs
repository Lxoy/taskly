namespace taskly.Services.Dtos.Base
{
    public class BaseResponse<T> : BaseResponse
    {
        public T? Data { get; set; }
    }
}
