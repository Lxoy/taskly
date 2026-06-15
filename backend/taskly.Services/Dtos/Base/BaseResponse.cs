namespace taskly.Services.Dtos.Base
{
    public class BaseResponse
    {
        public bool Success { get; set; }

        public string Message { get; set; } = string.Empty;

        public void SetSuccess(string message = "Success.")
        {
            Success = true;
            Message = message;
        }

        public void SetServerError()
        {
            Success = false;
            Message = "An unexpected error occurred.";
        }

        public void SetUnauthorized()
        {
            Success = false;
            Message = "Invalid email or password.";
        }

        public void SetNotFound(string entityName)
        {
            Success = false;
            Message = $"{entityName} was not found.";
        }

        public void SetError(string message)
        {
            Success = false;
            Message = message;
        }

        public void SetValidationError(string message)
        {
            Success = false;
            Message = message;
        }
    }
}
