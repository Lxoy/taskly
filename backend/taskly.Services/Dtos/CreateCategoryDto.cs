using System;
using System.Collections.Generic;
using System.Text;

namespace taskly.Services.Dtos
{
    public class CreateCategoryDto
    {
        public string Name { get; set; } = string.Empty;
        public string Color { get; set; } = string.Empty;
    }
}
