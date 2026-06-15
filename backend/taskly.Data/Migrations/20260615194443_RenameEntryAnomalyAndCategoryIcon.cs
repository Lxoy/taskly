using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace taskly.Data.Migrations
{
    /// <inheritdoc />
    public partial class RenameEntryAnomalyAndCategoryIcon : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "entry_occurrences");

            migrationBuilder.AddColumn<string>(
                name: "Icon",
                table: "categories",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateTable(
                name: "entry_anomalies",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    EntryId = table.Column<int>(type: "integer", nullable: false),
                    OccurrenceDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Amount = table.Column<decimal>(type: "numeric", nullable: true),
                    Priority = table.Column<int>(type: "integer", nullable: false),
                    Status = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ModifiedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_entry_anomalies", x => x.Id);
                    table.ForeignKey(
                        name: "FK_entry_anomalies_entries_EntryId",
                        column: x => x.EntryId,
                        principalTable: "entries",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_entry_anomalies_EntryId",
                table: "entry_anomalies",
                column: "EntryId");

            migrationBuilder.CreateIndex(
                name: "IX_entry_anomalies_EntryId_OccurrenceDate",
                table: "entry_anomalies",
                columns: new[] { "EntryId", "OccurrenceDate" });

            migrationBuilder.CreateIndex(
                name: "IX_entry_anomalies_OccurrenceDate",
                table: "entry_anomalies",
                column: "OccurrenceDate");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "entry_anomalies");

            migrationBuilder.DropColumn(
                name: "Icon",
                table: "categories");

            migrationBuilder.CreateTable(
                name: "entry_occurrences",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    EntryId = table.Column<int>(type: "integer", nullable: false),
                    Amount = table.Column<decimal>(type: "numeric", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    ModifiedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    OccurrenceDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Priority = table.Column<int>(type: "integer", nullable: false),
                    Status = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_entry_occurrences", x => x.Id);
                    table.ForeignKey(
                        name: "FK_entry_occurrences_entries_EntryId",
                        column: x => x.EntryId,
                        principalTable: "entries",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_entry_occurrences_EntryId",
                table: "entry_occurrences",
                column: "EntryId");

            migrationBuilder.CreateIndex(
                name: "IX_entry_occurrences_EntryId_OccurrenceDate",
                table: "entry_occurrences",
                columns: new[] { "EntryId", "OccurrenceDate" });

            migrationBuilder.CreateIndex(
                name: "IX_entry_occurrences_OccurrenceDate",
                table: "entry_occurrences",
                column: "OccurrenceDate");
        }
    }
}
