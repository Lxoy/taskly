using Microsoft.AspNetCore.Diagnostics;

namespace taskly.API.Handlers
{
    public class GlobalExceptionHandler
    {
        private readonly ILogger<GlobalExceptionHandler> _logger;

        public GlobalExceptionHandler(ILogger<GlobalExceptionHandler> logger)
        {
            _logger = logger;
        }

        public async Task HandleAsync(HttpContext context)
        {
            var exception = context.Features.Get<IExceptionHandlerFeature>()?.Error;
            _logger.LogError(exception, exception?.Message);

            var statusCode = exception switch
            {
                KeyNotFoundException => StatusCodes.Status404NotFound,
                ArgumentException => StatusCodes.Status400BadRequest,
                _ => StatusCodes.Status500InternalServerError
            };

            var userMessage = exception switch
            {
                KeyNotFoundException => "Resurs nije pronađen.",
                ArgumentException => "Neispravan zahtjev.",
                _ => "Došlo je do greške."
            };

            context.Response.ContentType = "application/json";
            context.Response.StatusCode = statusCode;

            await context.Response.WriteAsJsonAsync(new
            {
                message = userMessage,
                status = statusCode
            });
        }
    }
}
