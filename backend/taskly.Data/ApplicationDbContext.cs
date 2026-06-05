using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Text;
using taskly.Data.Models;

namespace taskly.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
           : base(options) { }

        public DbSet<User> Users => Set<User>();

        public DbSet<Category> Categories { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.ApplyConfigurationsFromAssembly(
            typeof(ApplicationDbContext).Assembly
            );
        }
    }
}
