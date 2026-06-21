using taskly.Data.Models;
using taskly.Services.Dtos.Base;
using taskly.Services.Dtos.Entry;

namespace taskly.Services.Interfaces
{
    public interface IEntryService
    {
        public Task<BaseResponse<EntryDto>> GetEntry(int userId, int entryId);
        public Task<BaseResponse> CreateNewEntry(int userId, CreateEntryDto request);
        public Task<BaseResponse> UpdateEntryAll(int userId, int entryId, UpdateEntryAllDto request);
        public Task<BaseResponse> UpdateEntryThisAndFuture(int userId, int entryId, UpdateEntryThisAndFutureDto request);
        public Task<BaseResponse> DeleteEntryAll(int userId, int entryId);
        public Task<BaseResponse> DeleteEntryFuture(int userId, int entryId, DateTime effectiveDate);
        public Task<BaseResponse> DeleteEntry(int userId, int entryId, DateTime effectiveDate);
        public Task<BaseResponse<List<EntryMonthDto>>> GetOccurrencesForMonth(int userId, int year, int month);
        public Task<BaseResponse<List<EntryMonthDto>>> GetOccurrencesForDay(int userId, int year, int month, int day);
    }
}
