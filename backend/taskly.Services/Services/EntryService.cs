using Microsoft.EntityFrameworkCore;
using taskly.Data;
using taskly.Data.Enums;
using taskly.Data.Models;
using taskly.Services.Dtos.Base;
using taskly.Services.Dtos.Entry;
using taskly.Services.Interfaces;

namespace taskly.Services.Services
{
    public class EntryService : IEntryService
    {
        private readonly ApplicationDbContext _dbContext;
        public EntryService(ApplicationDbContext dbContext)
        {
            _dbContext = dbContext;
        }
        public async Task<BaseResponse> CreateNewEntry(int userId, CreateEntryDto request)
        {
            var response = new BaseResponse();

            if (request.CategoryId is not null)
            {
                var categoryExists = await _dbContext.Categories
                    .AnyAsync(c => c.Id == request.CategoryId &&
                                   c.UserId == userId &&
                                   c.IsActive);

                if (!categoryExists)
                {
                    response.SetNotFound("Category");
                    return response;
                }
            }

            if (request.RecurrenceInterval < 1)
            {
                response.SetValidationError("Recurrence interval must be at least 1.");
                return response;
            }

            if (request.RecurrenceEndDate.HasValue && request.RecurrenceEndDate < request.ScheduledDate)
            {
                response.SetValidationError(
                    "Recurrence end date cannot be before scheduled date.");

                return response;
            }

            if (request.RecurrenceType == RecurrenceType.Once)
            {
                request.RecurrenceInterval = 1;
            }
            var entry = new Entry
            {
                UserId = userId,
                CategoryId = request.CategoryId,
                Title = request.Title,
                Description = request.Description,
                Amount = request.Amount,
                Priority = request.Priority,
                RecurrenceType = request.RecurrenceType,
                RecurrenceInterval = request.RecurrenceInterval,
                ScheduledDate = DateTime.SpecifyKind(request.ScheduledDate.Date, DateTimeKind.Utc),
                RecurrenceEndDate = request.RecurrenceEndDate.HasValue ? DateTime.SpecifyKind(request.RecurrenceEndDate.Value.Date, DateTimeKind.Utc) : null,
            };

            await _dbContext.Entries.AddAsync(entry);
            await _dbContext.SaveChangesAsync();

            if (entry.RecurrenceType == RecurrenceType.Once)
            {
                var occurrence = new EntryAnomaly
                {
                    EntryId = entry.Id,
                    OccurrenceDate = entry.ScheduledDate,
                    Amount = entry.Amount,
                    Status = EntryStatus.Pending
                };

                await _dbContext.EntryOccurrences.AddAsync(occurrence);
                await _dbContext.SaveChangesAsync();
            }

            response.Success = true;
            return response;
        }

        public async Task<BaseResponse> UpdateEntry(int userId, int entryId, UpdateEntryDto request)
        {
            var response = new BaseResponse();

            var entry = await _dbContext.Entries
                .FirstOrDefaultAsync(e => e.Id == entryId && e.UserId == userId && e.IsActive);

            if (entry is null)
            {
                response.SetNotFound("Entry");
                return response;
            }

            var validationError = await ValidateUpdateRequest(userId, request, entry);
            if (validationError is not null)
            {
                response.SetValidationError(validationError);
                return response;
            }

            ApplyUpdates(entry, request);

            await _dbContext.SaveChangesAsync();
            response.Success = true;
            return response;
        }

        public async Task<BaseResponse> DeleteEntry(int userId, int entryId)
        {
            var response = new BaseResponse();

            var entry = await _dbContext.Entries
                .FirstOrDefaultAsync(e => e.Id == entryId && e.UserId == userId && e.IsActive);

            if (entry is null)
            {
                response.SetNotFound("Entry");
                return response;
            }

            entry.IsActive = false;

            await _dbContext.SaveChangesAsync();

            response.Success = true;
            return response;
        }

        private async Task<string?> ValidateUpdateRequest(int userId, UpdateEntryDto request, Entry entry)
        {
            if (request.CategoryId is not null)
            {
                var categoryExists = await _dbContext.Categories
                    .AnyAsync(c => c.Id == request.CategoryId && c.UserId == userId && c.IsActive);

                if (!categoryExists) return "Category not found.";
            }

            if (request.RecurrenceInterval is not null && request.RecurrenceInterval < 1)
                return "Recurrence interval must be at least 1.";

            if (request.ScheduledDate is not null && DateTime.UtcNow.Date > request.ScheduledDate.Value.Date)
                return "Scheduled date cannot be in the past.";

            if (request.RecurrenceEndDate is not null)
            {
                var scheduledDate = request.ScheduledDate.HasValue
                    ? DateTime.SpecifyKind(request.ScheduledDate.Value.Date, DateTimeKind.Utc)
                    : entry.ScheduledDate;

                var endDate = DateTime.SpecifyKind(request.RecurrenceEndDate.Value.Date, DateTimeKind.Utc);

                if (endDate < scheduledDate)
                    return "Recurrence end date cannot be before scheduled date.";
            }

            return null;
        }

        private static void ApplyUpdates(Entry entry, UpdateEntryDto request)
        {
            if (request.CategoryId is not null) entry.CategoryId = request.CategoryId;
            if (request.Title is not null) entry.Title = request.Title;
            if (request.Description is not null) entry.Description = request.Description;
            if (request.Amount is not null) entry.Amount = request.Amount;
            if (request.Priority is not null) entry.Priority = request.Priority.Value;
            if (request.RecurrenceType is not null) entry.RecurrenceType = request.RecurrenceType.Value;
            if (request.RecurrenceInterval is not null) entry.RecurrenceInterval = request.RecurrenceInterval.Value;
            if (request.ScheduledDate is not null) entry.ScheduledDate = DateTime.SpecifyKind(request.ScheduledDate.Value.Date, DateTimeKind.Utc);
            if (request.RecurrenceEndDate is not null) entry.RecurrenceEndDate = DateTime.SpecifyKind(request.RecurrenceEndDate.Value.Date, DateTimeKind.Utc);
        }
    }
}
