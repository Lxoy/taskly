using System;
using System.Collections.Generic;
using System.Text;
using taskly.Data.Enums;

namespace taskly.Data.Models
{
    public class Reminder : BaseEntity
    {

        public int UserId { get; set; }

        public int EntryId { get; set; }

        public DateTime OccurrenceDate { get; set; }

        public DateTime RemindAt { get; set; }

        public ReminderStatus Status { get; set; } = ReminderStatus.Pending;

        public DateTime? SentAt { get; set; }

        public DateTime? FailedAt { get; set; }

        public string? FailureReason { get; set; }

        public int RetryCount { get; set; } = 0;


        public User User { get; set; } = null!;

        public Entry Entry { get; set; } = null!;

    }
}
