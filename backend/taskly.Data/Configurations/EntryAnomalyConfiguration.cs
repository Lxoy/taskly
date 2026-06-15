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

            builder.Property(e => e.Status)
                .IsRequired();

            builder.HasOne(e => e.Entry)
                .WithMany(e => e.EntryOccurrences)
                .HasForeignKey(e => e.EntryId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasIndex(e => e.EntryId);

            builder.HasIndex(e => e.OccurrenceDate);

            builder.HasIndex(e => new { e.EntryId, e.OccurrenceDate });
        }
    }
}
