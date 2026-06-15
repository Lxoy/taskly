using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace taskly.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddFieldsToEntryOccurrence : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "Amount",
                table: "entry_occurrences",
                type: "numeric",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Priority",
                table: "entry_occurrences",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Amount",
                table: "entry_occurrences");

            migrationBuilder.DropColumn(
                name: "Priority",
                table: "entry_occurrences");
        }
    }
}
