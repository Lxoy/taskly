using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace taskly.Data.Migrations
{
    /// <inheritdoc />
    public partial class UpdateEntryAndEntryAnomaly : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "IsCancelled",
                table: "entry_anomalies",
                newName: "IsDeleted");

            migrationBuilder.AddColumn<int>(
                name: "SeriesId",
                table: "entries",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_entries_SeriesId",
                table: "entries",
                column: "SeriesId");

            migrationBuilder.CreateIndex(
                name: "IX_entries_UserId_SeriesId",
                table: "entries",
                columns: new[] { "UserId", "SeriesId" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_entries_SeriesId",
                table: "entries");

            migrationBuilder.DropIndex(
                name: "IX_entries_UserId_SeriesId",
                table: "entries");

            migrationBuilder.DropColumn(
                name: "SeriesId",
                table: "entries");

            migrationBuilder.RenameColumn(
                name: "IsDeleted",
                table: "entry_anomalies",
                newName: "IsCancelled");
        }
    }
}
