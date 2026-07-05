using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using taskly.Data.Models;

namespace taskly.Data.Configurations
{
    internal class UserNotificationTokenConfiguration : IEntityTypeConfiguration<UserNotificationToken>
    {
        public void Configure(EntityTypeBuilder<UserNotificationToken> builder)
        {
            builder.ToTable("user_notification_tokens");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.Token)
                .IsRequired();

            builder.Property(x => x.Platform)
                .HasMaxLength(20)
                .IsRequired();

            builder.HasIndex(x => new
            {
                x.UserId,
                x.Token
            }).IsUnique();

            builder.HasOne(x => x.User)
                .WithMany()
                .HasForeignKey(x => x.UserId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
