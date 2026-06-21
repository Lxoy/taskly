using Microsoft.EntityFrameworkCore;
using taskly.Data;
using taskly.Data.Models;
using taskly.Services.Dtos.Base;
using taskly.Services.Dtos.EntryAnomaly;
using taskly.Services.Interfaces;
namespace taskly.Services.Services
{
    internal class EntryAnomalyService : IEntryAnomalyService
    {
        private readonly ApplicationDbContext _dbContext;

        public EntryAnomalyService(ApplicationDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<BaseResponse<AnomalyDto>> GetAnomaly(int userId, int anomalyId)
        {
            var response = new BaseResponse<AnomalyDto>();

            var anomaly = await _dbContext.EntryAnomalies
                .Include(a => a.Entry)
                .FirstOrDefaultAsync(a =>
                    a.Id == anomalyId &&
                    a.Entry.UserId == userId &&
                    a.IsActive);

            if (anomaly is null)
            {
                response.SetNotFound("Entry anomaly");
                return response;
            }

            response.Success = true;
            response.Data = new AnomalyDto
            {
                Id = anomaly.Id,
                EntryId = anomaly.EntryId,
                OccurrenceDate = anomaly.OccurrenceDate,
                NewOccurrenceDate = anomaly.NewOccurrenceDate,
                Title = anomaly.Title,
                Description = anomaly.Description,
                Amount = anomaly.Amount,
                Priority = anomaly.Priority,
                CategoryId = anomaly.CategoryId
            };

            return response;
        }

        public async Task<BaseResponse> CreateEntryAnomaly(int userId, CreateEntryAnomalyDto dto)
        {
            var response = new BaseResponse();

            var entry = await _dbContext.Entries
                .FirstOrDefaultAsync(e =>
                    e.Id == dto.EntryId &&
                    e.UserId == userId &&
                    e.IsActive);

            if (entry is null)
            {
                response.SetNotFound("Entry");
                return response;
            }

            if (dto.CategoryId is not null)
            {
                var categoryExists = await _dbContext.Categories
                    .AnyAsync(c =>
                        c.Id == dto.CategoryId &&
                        c.UserId == userId &&
                        c.IsActive);

                if (!categoryExists)
                {
                    response.SetNotFound("Category");
                    return response;
                }
            }

            var occurrenceDate = DateTime.SpecifyKind(
                dto.OccurrenceDate,
                DateTimeKind.Utc);

            DateTime? newOccurrenceDate = dto.NewOccurrenceDate.HasValue
                ? DateTime.SpecifyKind(dto.NewOccurrenceDate.Value, DateTimeKind.Utc)
                : null;

            var anomaly = await _dbContext.EntryAnomalies
                .FirstOrDefaultAsync(a =>
                    a.EntryId == dto.EntryId &&
                    a.OccurrenceDate == occurrenceDate);

            if (anomaly is null)
            {
                anomaly = new EntryAnomaly
                {
                    EntryId = dto.EntryId,
                    OccurrenceDate = occurrenceDate
                };

                await _dbContext.EntryAnomalies.AddAsync(anomaly);
            }

            anomaly.IsActive = true;
            anomaly.IsDeleted = false;

            anomaly.NewOccurrenceDate = newOccurrenceDate;

            anomaly.Title = dto.Title ?? entry.Title;
            anomaly.Description = dto.Description ?? entry.Description;
            anomaly.Amount = dto.Amount ?? entry.Amount;
            anomaly.Priority = dto.Priority ?? entry.Priority;
            anomaly.CategoryId = dto.CategoryId;

            await _dbContext.SaveChangesAsync();

            response.Success = true;
            return response;
        }

        public async Task<BaseResponse> EditEntryAnomaly(int userId, EditEntryAnomalyDto dto)
        {
            var response = new BaseResponse();

            var anomaly = await _dbContext.EntryAnomalies
                .Include(a => a.Entry)
                .FirstOrDefaultAsync(a =>
                    a.Id == dto.AnomalyId &&
                    a.Entry.UserId == userId &&
                    a.IsActive);

            if (anomaly is null)
            {
                response.SetNotFound("Entry anomaly");
                return response;
            }

            if (dto.CategoryId is not null)
            {
                var categoryExists = await _dbContext.Categories
                    .AnyAsync(c =>
                        c.Id == dto.CategoryId &&
                        c.UserId == userId &&
                        c.IsActive);

                if (!categoryExists)
                {
                    response.SetNotFound("Category");
                    return response;
                }
            }

            if (dto.OccurrenceDate.HasValue)
                anomaly.OccurrenceDate = dto.OccurrenceDate.Value;

            anomaly.NewOccurrenceDate = dto.NewOccurrenceDate;

            if (dto.Title is not null)
                anomaly.Title = dto.Title;

            anomaly.Description = dto.Description;
            anomaly.Amount = dto.Amount;

            if (dto.Priority is not null)
                anomaly.Priority = dto.Priority.Value;

            anomaly.CategoryId = dto.CategoryId;

            anomaly.IsDeleted = false;

            await _dbContext.SaveChangesAsync();

            response.Success = true;
            return response;
        }

        public async Task<BaseResponse> DeleteEntryAnomaly(int userId, int anomalyId)
        {
            var response = new BaseResponse();

            var anomaly = await _dbContext.EntryAnomalies
                .Include(a => a.Entry)
                .FirstOrDefaultAsync(a =>
                    a.Id == anomalyId &&
                    a.Entry.UserId == userId &&
                    a.IsActive);

            if (anomaly is null)
            {
                response.SetNotFound("Entry anomaly");
                return response;
            }

            anomaly.IsDeleted = true;
            anomaly.IsActive = true;

            await _dbContext.SaveChangesAsync();

            response.Success = true;
            return response;
        }
    }
}
