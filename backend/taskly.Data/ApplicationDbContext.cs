using Microsoft.EntityFrameworkCore;
using taskly.Data.Models;

namespace taskly.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
           : base(options) { }

        public DbSet<User> Users { get; set; }

        public DbSet<Category> Categories { get; set; }

        public DbSet<Entry> Entries { get; set; }

        public DbSet<EntryAnomaly> EntryAnomalies { get; set; }

        public DbSet<Reminder> Reminders { get; set; }

        public DbSet<UserNotificationToken> UserNotificationTokens { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.ApplyConfigurationsFromAssembly(
            typeof(ApplicationDbContext).Assembly
            );
        }
    }
}
