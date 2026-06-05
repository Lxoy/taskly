using Microsoft.EntityFrameworkCore;
using taskly.Data;
using taskly.Data.Models;
using taskly.Services.Dtos;
using taskly.Services.Interfaces;

namespace taskly.Services.Services
{
    public class CategoryService : ICategoryService
    {
        private readonly ApplicationDbContext _dbContext;

        public CategoryService(ApplicationDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        public async Task<BaseResponse<List<CategoryDto>>> GetCategories(int userId)
        {

            var response = new BaseResponse<List<CategoryDto>>();

            var categories = await _dbContext.Categories
                .Where(c => c.UserId == userId && c.IsActive == true)
                .Select(c => new CategoryDto
                {
                    Id = c.Id,
                    Name = c.Name,
                    Color = c.Color
                })
                .ToListAsync();

            response.Success = true;
            response.Data = categories;

            return response;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<BaseResponse> CreateCategory(int userId, CreateCategoryDto request)
        {
            var response = new BaseResponse();

            var user = await _dbContext.Users.AnyAsync(u => u.Id == userId && u.IsActive == true);

            if (!user)
            {
                response.Success = false;
                response.SetNotFound("User");
                return response;
            }

            _dbContext.Categories.Add(new Category
            {
                CreatedAt = DateTime.UtcNow,
                UserId = userId,
                Name = request.Name,
                Color = request.Color,
            });

            await _dbContext.SaveChangesAsync();

            response.Success = true;
            return response;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="categoryId"></param>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<BaseResponse> UpdateCategory(int userId, int categoryId, UpdateCategoryDto request)
        {
            var response = new BaseResponse();

            if (request.Name == null && request.Color == null)
            {
                response.SetError("At least one field must be provided.");
                return response;
            }


            var category = await _dbContext.Categories
                .FirstOrDefaultAsync(c => c.Id == categoryId && c.UserId == userId && c.IsActive == true);

            if (category is null)
            {
                response.Success = false;
                response.SetNotFound("Category");
                return response;
            }

            if (request.Name != null)
                category.Name = request.Name;
            if (request.Color != null)
                category.Color = request.Color;

            category.ModifiedAt = DateTime.UtcNow;

            await _dbContext.SaveChangesAsync();

            response.Success = true;
            return response;
        }

        public async Task<BaseResponse> DeleteCategory(int userId, int categoryId)
        {
            var response = new BaseResponse();

            var category = await _dbContext.Categories.FirstOrDefaultAsync(c => c.Id == categoryId && c.UserId == userId && c.IsActive == true);

            if (category is null)
            {
                response.Success = false;
                response.SetNotFound("Category");
                return response;
            }

            category.IsActive = false;
            category.ModifiedAt = DateTime.UtcNow;

            await _dbContext.SaveChangesAsync();

            response.Success = true;
            return response;
        }
    }
}
