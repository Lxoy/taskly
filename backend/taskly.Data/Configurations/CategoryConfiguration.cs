using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using taskly.Data.Models;

namespace taskly.Data.Configurations
{
    internal class CategoryConfiguration : IEntityTypeConfiguration<Category>
    {
        public void Configure(EntityTypeBuilder<Category> builder)
        {
            builder.ToTable("categories");

            builder.HasKey(c => c.Id);

            builder.Property(c => c.IsActive)
                .IsRequired();

            builder.Property(c => c.CreatedAt)
                .IsRequired();

            builder.Property(c => c.ModifiedAt);

            builder.Property(c => c.UserId)
                .IsRequired();

            builder.Property(c => c.Name)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(c => c.Icon)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(c => c.Color)
                .IsRequired()
                .HasMaxLength(7);

            builder.HasOne(c => c.User)
                .WithMany(u => u.Categories)
                .HasForeignKey(c => c.UserId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
