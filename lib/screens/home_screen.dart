import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/auth_provider.dart';
import '../services/event_service.dart';
import '../models/event.dart';
import 'package:intl/intl.dart';
import 'add_event_screen.dart'; // Import the new screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService _eventService = EventService();
  late final ValueNotifier<List<Event>> _selectedEvents;
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    // Use WidgetsBinding to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEvents();
    });
  }

  void _fetchEvents() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null) {
      _eventService.getEvents(token).then((events) {
        setState(() {
          _events = _groupEventsByDay(events);
          _selectedEvents.value = _getEventsForDay(_selectedDay!);
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải sự kiện: $error')),
        );
      });
    }
  }

  Map<DateTime, List<Event>> _groupEventsByDay(List<Event> events) {
    Map<DateTime, List<Event>> data = {};
    for (var event in events) {
      DateTime date = DateTime.utc(event.startTime.year, event.startTime.month, event.startTime.day);
      if (data[date] == null) data[date] = [];
      data[date]!.add(event);
    }
    return data;
  }

  List<Event> _getEventsForDay(DateTime day) {
    DateTime date = DateTime.utc(day.year, day.month, day.day);
    return _events[date] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _navigateAndRefresh() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddEventScreen()),
    );

    // If the AddEventScreen returns true, it means an event was created
    if (result == true) {
      _fetchEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false); // No need to listen here

    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch của ${authProvider.user?.email ?? "bạn"}'),
        actions: [
          Tooltip(
            message: 'Đăng xuất',
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
              },
            ),
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            locale: 'vi_VN', // Set locale to Vietnamese
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
             calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.indigoAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.indigo,
                shape: BoxShape.circle,
              ),
               markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
             headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return const Center(
                    child: Text('Không có sự kiện nào cho ngày này.'),
                  );
                }
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final event = value[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        onTap: () => print(event.title),
                        title: Text(event.title),
                        subtitle: Text('Từ ${DateFormat.Hm().format(event.startTime.toLocal())} đến ${DateFormat.Hm().format(event.endTime.toLocal())}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndRefresh, // Update this line
        tooltip: 'Thêm sự kiện',
        child: const Icon(Icons.add),
      ),
    );
  }
}
