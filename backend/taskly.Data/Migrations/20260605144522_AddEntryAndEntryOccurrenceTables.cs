using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace taskly.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddEntryAndEntryOccurrenceTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "entries",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    CategoryId = table.Column<int>(type: "integer", nullable: true),
                    Title = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    Description = table.Column<string>(type: "text", nullable: true),
                    Amount = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: true),
                    Priority = table.Column<int>(type: "integer", nullable: false),
                    RecurrenceType = table.Column<int>(type: "integer", nullable: false),
                    RecurrenceInterval = table.Column<int>(type: "integer", nullable: false, defaultValue: 1),
                    ScheduledDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    RecurrenceEndDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ModifiedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_entries", x => x.Id);
                    table.ForeignKey(
                        name: "FK_entries_categories_CategoryId",
                        column: x => x.CategoryId,
                        principalTable: "categories",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_entries_users_UserId",
                        column: x => x.UserId,
                        principalTable: "users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "entry_occurrences",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    EntryId = table.Column<int>(type: "integer", nullable: false),
                    OccurrenceDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Status = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ModifiedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
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
                name: "IX_entries_CategoryId",
                table: "entries",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_entries_UserId",
                table: "entries",
                column: "UserId");

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

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "entry_occurrences");

            migrationBuilder.DropTable(
                name: "entries");
        }
    }
}
