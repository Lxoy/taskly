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

        public DbSet<EntryAnomaly> EntryOccurrences { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.ApplyConfigurationsFromAssembly(
            typeof(ApplicationDbContext).Assembly
            );
        }
    }
}
