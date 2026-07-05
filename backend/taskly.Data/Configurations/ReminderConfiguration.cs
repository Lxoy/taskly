using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;
using System.Collections.Generic;
using System.Text;
using taskly.Data.Models;

namespace taskly.Data.Configurations
{
    internal class ReminderConfiguration : IEntityTypeConfiguration<Reminder>
    {
        public void Configure(EntityTypeBuilder<Reminder> builder)
        {
            builder.ToTable("reminders");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.OccurrenceDate)
                .IsRequired();

            builder.Property(x => x.RemindAt)
                .IsRequired();

            builder.Property(x => x.Status)
                .HasConversion<int>()
                .IsRequired();

            builder.Property(x => x.RetryCount)
                .HasDefaultValue(0);

            builder.Property(x => x.FailureReason)
                .HasMaxLength(1000);

            builder.HasIndex(x => new
            {
                x.EntryId,
                x.OccurrenceDate
            }).IsUnique();

            builder.HasIndex(x => new
            {
                x.Status,
                x.RemindAt
            });

            builder.HasOne(x => x.User)
                .WithMany()
                .HasForeignKey(x => x.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(x => x.Entry)
                .WithMany()
                .HasForeignKey(x => x.EntryId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
