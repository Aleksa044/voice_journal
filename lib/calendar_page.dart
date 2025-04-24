import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarPage extends StatefulWidget {
  final Map<DateTime, String> entries;
  const CalendarPage({super.key, required this.entries});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    Set<String> savedEntries =
        prefs.getStringList('entries')?.toSet() ?? <String>{};

    setState(() {
      for (var entry in savedEntries) {
        var parts = entry.split('|');
        if (parts.length >= 2) {
          DateTime date = DateTime.parse(parts[0]);
          String text = parts.sublist(1).join('|');
          widget.entries[_normalizeDate(date)] = text;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 10,
        shadowColor: Colors.black.withAlpha((0.4 * 255).toInt()),
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime.utc(2000, 1, 1),
        lastDay: DateTime(2040, 12, 31),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });

          final normalizedDate = _normalizeDate(selectedDay);

          if (widget.entries.containsKey(normalizedDate)) {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text(
                      "${normalizedDate.day}.${normalizedDate.month}.${normalizedDate.year}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: Text(widget.entries[normalizedDate]!),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
            );
          } else {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text(
                      "${normalizedDate.day}.${normalizedDate.month}.${normalizedDate.year}",
                    ),
                    content: const Text(
                      'There is no recorded entry for this day.',
                    ),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
            );
          }
        },
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
      ),
    );
  }
}
