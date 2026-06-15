using taskly.Services.Dtos.Base;
using taskly.Services.Dtos.Entry;

namespace taskly.Services.Interfaces
{
    public interface IEntryService
    {
        public Task<BaseResponse> CreateNewEntry(int userId, CreateEntryDto request);
        public Task<BaseResponse> UpdateEntry(int userId, int entryId, UpdateEntryDto request);
        public Task<BaseResponse> DeleteEntry(int userId, int entryId);
    }
}
