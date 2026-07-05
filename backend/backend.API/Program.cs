using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Hangfire;
using Hangfire.PostgreSql;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;
using System.Text;
using taskly.API.Authorization;
using taskly.API.Handlers;
using taskly.Data;
using taskly.Services;
using taskly.Services.Dtos.Base;
using taskly.Services.Jobs;
using taskly.Services.Options;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddServices();
builder.Services.AddScoped<IAuthorizationHandler, ActiveUserHandler>();

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("ActiveUser", policy =>
        policy.Requirements.Add(new ActiveUserRequirement()));

    // Ovo postavlja ActiveUser kao DEFAULT policy za sve endpointe
    // znači ne moraš pisati [Authorize(Policy = "ActiveUser")] svuda
    options.DefaultPolicy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .AddRequirements(new ActiveUserRequirement())
        .Build();
});

builder.Services.AddSingleton<GlobalExceptionHandler>();

// Add services to the container.
builder.Services.AddControllers();

builder.Services.AddControllers()
    .ConfigureApiBehaviorOptions(options =>
    {
        options.InvalidModelStateResponseFactory = context =>
        {
            var errors = context.ModelState
                .Where(e => e.Value?.Errors.Count > 0)
                .Select(e => new
                {
                    Field = e.Key,
                    Error = e.Value!.Errors.First().ErrorMessage
                });

            return new BadRequestObjectResult(new BaseResponse
            {
                Success = false,
                Message = string.Join(", ", errors.Select(e => e.Error))
            });
        };
    });

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Upiši JWT token."
    });

    options.AddSecurityRequirement(document => new()
    {
        [new OpenApiSecuritySchemeReference("Bearer", document)] = []
    });
});

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(
        builder.Configuration.GetConnectionString("Database")));

builder.Services.Configure<JwtOptions>(
    builder.Configuration.GetSection("JwtOptions"));

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,

            ValidIssuer = builder.Configuration["JwtOptions:Issuer"],
            ValidAudience = builder.Configuration["JwtOptions:Audience"],

            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["JwtOptions:Token"]))
        };
    });

FirebaseApp.Create(new AppOptions
{
    Credential = GoogleCredential.FromFile(
        "firebase/firebase-service-account.json")
});

builder.Services.AddHangfire(config =>
{
    config.UsePostgreSqlStorage(
        builder.Configuration.GetConnectionString("Database"));
});

builder.Services.AddHangfireServer();

var app = builder.Build();

app.UseExceptionHandler(appBuilder =>
    appBuilder.Run(async context =>
    {
        var handler = context.RequestServices
            .GetRequiredService<GlobalExceptionHandler>();
        await handler.HandleAsync(context);
    }));

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseAuthentication();
app.UseAuthorization();

app.UseHangfireDashboard("/hangfire");

app.MapControllers();

using var scope = app.Services.CreateScope();

var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

var canConnect = await db.Database.CanConnectAsync();

Console.WriteLine($"DATABASE CONNECTED: {canConnect}");

RecurringJob.AddOrUpdate<ReminderNotificationJob>(
    "reminder-notifications",
    job => job.RunAsync(),
    "*/5 * * * *"
);

RecurringJob.AddOrUpdate<ReminderMaintenanceJob>(
    "reminder-maintenance",
    job => job.RunAsync(),
    "*/5 * * * *"
);

app.Run();
