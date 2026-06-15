using System.ComponentModel.DataAnnotations;

namespace taskly.API.Validators
{
    public class AfterDateAttribute : ValidationAttribute
    {
        private readonly string _comparedPropertyName;

        public AfterDateAttribute(string comparedPropertyName)
        {
            _comparedPropertyName = comparedPropertyName;
        }

        protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
        {
            if (value is not DateTime date) return ValidationResult.Success;

            var property = validationContext.ObjectType.GetProperty(_comparedPropertyName);
            if (property?.GetValue(validationContext.ObjectInstance) is not DateTime comparedDate)
                return ValidationResult.Success;

            if (date.Date <= comparedDate.Date)
                return new ValidationResult(ErrorMessage ?? $"Date must be after {_comparedPropertyName}.");

            return ValidationResult.Success;
        }
    }
}
