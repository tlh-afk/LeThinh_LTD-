using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace LeThinhAPI.Models
{
    public class EventAssignment
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int EventId { get; set; }

        [Required]
        public int StaffId { get; set; }

        [Required]
        public int AssignedById { get; set; }

        [ForeignKey("EventId")]
        [JsonIgnore]
        public virtual Event Event { get; set; } = null!;

        [ForeignKey("StaffId")]
        [JsonIgnore]
        public virtual User Staff { get; set; } = null!;

        [ForeignKey("AssignedById")]
        [JsonIgnore]
        public virtual User AssignedBy { get; set; } = null!;
    }
}