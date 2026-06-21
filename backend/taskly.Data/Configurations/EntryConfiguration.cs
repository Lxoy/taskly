using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using taskly.Data.Models;

namespace taskly.Data.Configurations
{
    internal class EntryConfiguration : IEntityTypeConfiguration<Entry>
    {
        public void Configure(EntityTypeBuilder<Entry> builder)
        {
            builder.ToTable("entries");

            builder.HasKey(e => e.Id);

            builder.Property(e => e.IsActive)
                .IsRequired();

            builder.Property(e => e.CreatedAt)
                .IsRequired();

            builder.Property(e => e.ModifiedAt);

            builder.Property(e => e.UserId)
                .IsRequired();

            builder.Property(e => e.CategoryId);

            builder.Property(e => e.Title)
                .IsRequired()
                .HasMaxLength(255);

            builder.Property(e => e.Description);

            builder.Property(e => e.Amount)
                .HasPrecision(10, 2);

            builder.Property(e => e.Priority)
                .IsRequired();

            builder.Property(e => e.RecurrenceType)
                .IsRequired();

            builder.Property(e => e.RecurrenceInterval)
                .IsRequired()
                .HasDefaultValue(1);

            builder.Property(e => e.RecurrenceDaysMask)
                .HasConversion<int?>();

            builder.Property(e => e.ScheduledDate)
                .IsRequired();

            builder.Property(e => e.RecurrenceEndDate);

            builder.Property(e => e.SeriesId)
                .IsRequired();

            builder.HasOne(e => e.User)
                .WithMany(u => u.Entries)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(e => e.Category)
                .WithMany(c => c.Entries)
                .HasForeignKey(e => e.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasIndex(e => e.UserId);
            builder.HasIndex(e => e.SeriesId);
            builder.HasIndex(e => new { e.UserId, e.SeriesId });
        }
    }
}