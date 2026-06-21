using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using taskly.Data.Models;

namespace taskly.Data.Configurations
{
    internal class EntryAnomalyConfiguration : IEntityTypeConfiguration<EntryAnomaly>
    {
        public void Configure(EntityTypeBuilder<EntryAnomaly> builder)
        {
            builder.ToTable("entry_anomalies");

            builder.HasKey(e => e.Id);

            builder.Property(e => e.IsActive)
                .IsRequired();

            builder.Property(e => e.CreatedAt)
                .IsRequired();

            builder.Property(e => e.ModifiedAt);

            builder.Property(e => e.EntryId)
                .IsRequired();

            builder.Property(e => e.OccurrenceDate)
                .IsRequired();

            builder.Property(e => e.NewOccurrenceDate);

            builder.Property(e => e.Title)
                .IsRequired()
                .HasMaxLength(255);

            builder.Property(e => e.Description);

            builder.Property(e => e.Amount)
                .HasPrecision(10, 2);

            builder.Property(e => e.Priority)
                .IsRequired();

            builder.Property(e => e.CategoryId);

            builder.Property(e => e.IsDeleted)
                .IsRequired()
                .HasDefaultValue(false);

            builder.HasOne(e => e.Entry)
                .WithMany(e => e.EntryOccurrences)
                .HasForeignKey(e => e.EntryId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasOne(e => e.Category)
                .WithMany()
                .HasForeignKey(e => e.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasIndex(e => e.EntryId);
            builder.HasIndex(e => e.OccurrenceDate);

            builder.HasIndex(e => new { e.EntryId, e.OccurrenceDate })
                .IsUnique();
        }
    }
}