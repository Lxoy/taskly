namespace taskly.Services.Dtos.User
{
    public class UpdateUserPasswordDto
    {
        public string NewPassword { get; set; } = string.Empty;

        public string ConfirmedPassword { get; set; } = string.Empty;
    }
}
