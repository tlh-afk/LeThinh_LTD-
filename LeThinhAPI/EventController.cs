using LeThinhAPI.Data;
using LeThinhAPI.DTOs;
using LeThinhAPI.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
namespace LeThinhAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // Tất cả các API trong đây đều yêu cầu phải đăng nhập
    public class EventsController : ControllerBase
    {
        private readonly DataContext _context;

        public EventsController(DataContext context)
        {
            _context = context;
        }

        // GET: api/Events
        [HttpGet]
        public async Task<ActionResult<IEnumerable<EventDto>>> GetEvents()
        {
            // Lấy userId từ token JWT
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));

            var events = await _context.Events
                .Where(e => e.UserId == userId && e.DeletedAt == null)
                .Select(e => new EventDto
                {
                    Id = e.Id,
                    Title = e.Title,
                    Description = e.Description,
                    StartTime = e.StartTime,
                    EndTime = e.EndTime
                })
                .ToListAsync();

            return Ok(events);
        }

        // POST: api/Events
        [HttpPost]
        public async Task<ActionResult<EventDto>> CreateEvent(CreateEventDto createEventDto)
        {
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));

            var newEvent = new Event
            {
                Title = createEventDto.Title,
                Description = createEventDto.Description,
                StartTime = createEventDto.StartTime,
                EndTime = createEventDto.EndTime,
                UserId = userId
            };

            _context.Events.Add(newEvent);
            await _context.SaveChangesAsync();

            var eventDto = new EventDto
            {
                Id = newEvent.Id,
                Title = newEvent.Title,
                Description = newEvent.Description,
                StartTime = newEvent.StartTime,
                EndTime = newEvent.EndTime
            };

            return CreatedAtAction(nameof(GetEvents), new { id = newEvent.Id }, eventDto);
        }
    }
}