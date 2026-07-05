using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Text;
using taskly.Services.Interfaces;
using taskly.Services.Jobs;
using taskly.Services.Services;

namespace taskly.Services
{
    public static class DependencyInjection
    {
        public static IServiceCollection AddServices(this IServiceCollection services)
        {
            services.AddScoped<IAuthService, AuthService>();
            services.AddScoped<ICategoryService, CategoryService>();
            services.AddScoped<IEntryService, EntryService>();
            services.AddScoped<IEntryAnomalyService, EntryAnomalyService>();
            services.AddScoped<IHomeService, HomeService>();
            services.AddScoped<IUserService, UserService>();
            services.AddScoped<IStatsService, StatsService>();

            services.AddScoped<INotificationService, NotificationService>();
            services.AddScoped<IFirebasePushService, FirebasePushService>();

            services.AddScoped<ReminderNotificationJob>();
            services.AddScoped<ReminderMaintenanceJob>();

            return services;
        }
    }
}
