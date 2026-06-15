using System.ComponentModel.DataAnnotations;

namespace taskly.API.Validators
{
    public class FutureDateAttribute : ValidationAttribute
    {
        protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
        {
            if (value is DateTime date && date.Date < DateTime.UtcNow.Date)
                return new ValidationResult(ErrorMessage ?? "Date must be today or in the future.");

            return ValidationResult.Success;
        }
    }
}
