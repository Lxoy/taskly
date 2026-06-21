using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace taskly.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddRecurrenceDaysMask : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_entry_anomalies_EntryId_OccurrenceDate",
                table: "entry_anomalies");

            migrationBuilder.DropColumn(
                name: "Status",
                table: "entry_anomalies");

            migrationBuilder.AlterColumn<int>(
                name: "Priority",
                table: "entry_anomalies",
                type: "integer",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<decimal>(
                name: "Amount",
                table: "entry_anomalies",
                type: "numeric(10,2)",
                precision: 10,
                scale: 2,
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "numeric",
                oldNullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CategoryId",
                table: "entry_anomalies",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "entry_anomalies",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsCancelled",
                table: "entry_anomalies",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "NewOccurrenceDate",
                table: "entry_anomalies",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Title",
                table: "entry_anomalies",
                type: "character varying(255)",
                maxLength: 255,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "RecurrenceDaysMask",
                table: "entries",
                type: "integer",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_entry_anomalies_CategoryId",
                table: "entry_anomalies",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_entry_anomalies_EntryId_OccurrenceDate",
                table: "entry_anomalies",
                columns: new[] { "EntryId", "OccurrenceDate" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_entry_anomalies_categories_CategoryId",
                table: "entry_anomalies",
                column: "CategoryId",
                principalTable: "categories",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_entry_anomalies_categories_CategoryId",
                table: "entry_anomalies");

            migrationBuilder.DropIndex(
                name: "IX_entry_anomalies_CategoryId",
                table: "entry_anomalies");

            migrationBuilder.DropIndex(
                name: "IX_entry_anomalies_EntryId_OccurrenceDate",
                table: "entry_anomalies");

            migrationBuilder.DropColumn(
                name: "CategoryId",
                table: "entry_anomalies");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "entry_anomalies");

            migrationBuilder.DropColumn(
                name: "IsCancelled",
                table: "entry_anomalies");

            migrationBuilder.DropColumn(
                name: "NewOccurrenceDate",
                table: "entry_anomalies");

            migrationBuilder.DropColumn(
                name: "Title",
                table: "entry_anomalies");

            migrationBuilder.DropColumn(
                name: "RecurrenceDaysMask",
                table: "entries");

            migrationBuilder.AlterColumn<int>(
                name: "Priority",
                table: "entry_anomalies",
                type: "integer",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);

            migrationBuilder.AlterColumn<decimal>(
                name: "Amount",
                table: "entry_anomalies",
                type: "numeric",
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "numeric(10,2)",
                oldPrecision: 10,
                oldScale: 2,
                oldNullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Status",
                table: "entry_anomalies",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_entry_anomalies_EntryId_OccurrenceDate",
                table: "entry_anomalies",
                columns: new[] { "EntryId", "OccurrenceDate" });
        }
    }
}
