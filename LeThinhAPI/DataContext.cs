using LeThinhAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace LeThinhAPI.Data
{
    public class DataContext : DbContext
    {
        public DataContext(DbContextOptions<DataContext> options) : base(options)
        {
        }

        // Khai báo các bảng
        public DbSet<User> Users { get; set; }
        public DbSet<Event> Events { get; set; }
        public DbSet<Reminder> Reminders { get; set; }
        public DbSet<EventAssignment> EventAssignments { get; set; }

        // Cấu hình các mối quan hệ phức tạp
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Cấu hình EventAssignment
            modelBuilder.Entity<EventAssignment>()
                .HasOne(ea => ea.Event)
                .WithMany(e => e.Assignments)
                .HasForeignKey(ea => ea.EventId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<EventAssignment>()
                .HasOne(ea => ea.Staff)
                .WithMany(u => u.StaffAssignments)
                .HasForeignKey(ea => ea.StaffId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<EventAssignment>()
                .HasOne(ea => ea.AssignedBy)
                .WithMany(u => u.AdminAssignments)
                .HasForeignKey(ea => ea.AssignedById)
                .OnDelete(DeleteBehavior.NoAction);

            // Cấu hình Event
            modelBuilder.Entity<Event>()
                .HasOne(e => e.CreatedBy)
                .WithMany(u => u.CreatedEvents)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade); // Nếu user tạo bị xóa, event cũng bị xóa
        }
    }
}