namespace taskly.Services.Dtos.User
{
    public class GetUserDto
    {
        public string? FirstName { get; set; }

        public string? LastName { get; set; }

        public string? Username { get; set; }
        public string? Email { get; set; }

        public string? PhoneNumber { get; set; }
    }
}
