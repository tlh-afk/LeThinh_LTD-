using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace LeThinhAPI.Models
{
    public class User
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [JsonIgnore]
        public string Password { get; set; } = string.Empty;

        [Required]
        public string Role { get; set; } = string.Empty; // "ADMIN", "STAFF", "USER"

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? DeletedAt { get; set; }

        [JsonIgnore]
        public virtual ICollection<Event> CreatedEvents { get; set; } = new List<Event>();

        [JsonIgnore]
        public virtual ICollection<EventAssignment> StaffAssignments { get; set; } = new List<EventAssignment>();

        [JsonIgnore]
        public virtual ICollection<EventAssignment> AdminAssignments { get; set; } = new List<EventAssignment>();
    }
}