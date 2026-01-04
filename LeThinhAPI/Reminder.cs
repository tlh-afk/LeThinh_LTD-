using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace LeThinhAPI.Models
{
    public class Reminder
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public DateTime RemindAt { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Required]
        public int EventId { get; set; }

        [ForeignKey("EventId")]
        [JsonIgnore]
        public virtual Event Event { get; set; } = null!;
    }
}