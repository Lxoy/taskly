using System;
using System.Collections.Generic;
using System.Text;
using taskly.Services.Dtos.Base;
using taskly.Services.Dtos.Category;

namespace taskly.Services.Interfaces
{
    public interface ICategoryService
    {
        Task<BaseResponse<List<CategoryDto>>> GetCategories(int userId);
        Task<BaseResponse> CreateCategory(int userId, CreateCategoryDto request);
        Task<BaseResponse> UpdateCategory(int userId, int categoryId, UpdateCategoryDto request);
        Task<BaseResponse> DeleteCategory(int userId, int categoryId);
    }
}
