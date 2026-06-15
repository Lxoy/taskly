using System;
using System.Collections.Generic;
using System.Text;
using taskly.Data.Enums;
using taskly.Data.Models;
using taskly.Services.Dtos.Occurrence;

namespace taskly.Services.Mappers
{
    internal class EntryOccurrenceMapper
    {
        public static OccurrenceDto ToDto(Entry entry, DateTime date)
        {
            return new OccurrenceDto
            {
                EntryId = entry.Id,
                OccurrenceDate = date,
                Title = entry.Title,
                Description = entry.Description,
                Amount = entry.Amount,
                Priority = entry.Priority,
                CategoryId = entry.CategoryId,
                Status = EntryStatus.Pending,
                IsMaterialized = false
            };
        }

        public static OccurrenceDto ToDto(EntryAnomaly occurrence)
        {
            return new OccurrenceDto
            {
                EntryId = occurrence.EntryId,
                OccurrenceDate = occurrence.OccurrenceDate,
                Title = occurrence.Entry.Title,
                Description = occurrence.Entry?.Description,
                Amount = occurrence.Amount,
                Priority = occurrence.Priority,
                CategoryId = occurrence.Entry?.CategoryId,
                Status = occurrence.Status,
                IsMaterialized = true
            };
        }
    }
}
