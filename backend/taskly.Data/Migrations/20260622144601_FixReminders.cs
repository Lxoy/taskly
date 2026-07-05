using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace taskly.Data.Migrations
{
    /// <inheritdoc />
    public partial class FixReminders : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_reminders_EntryId_OccurrenceDate_RemindAt",
                table: "reminders");

            migrationBuilder.CreateIndex(
                name: "IX_reminders_EntryId_OccurrenceDate",
                table: "reminders",
                columns: new[] { "EntryId", "OccurrenceDate" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_reminders_EntryId_OccurrenceDate",
                table: "reminders");

            migrationBuilder.CreateIndex(
                name: "IX_reminders_EntryId_OccurrenceDate_RemindAt",
                table: "reminders",
                columns: new[] { "EntryId", "OccurrenceDate", "RemindAt" },
                unique: true);
        }
    }
}
