import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, String> entries = {
    DateTime.utc(2025, 4, 12): "Danas sam razmišljao o novim idejama za aplikaciju.",
    DateTime.utc(2025, 4, 14): "Testirao sam funkciju prepoznavanja govora.",
    DateTime.utc(2025, 4, 15): "Dodao sam kalendar u aplikaciju!",
  };
  DateTime _normalizeDate(DateTime date){
    return DateTime.utc(date.year, date.month, date.day);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 10,
        shadowColor: Colors.black.withAlpha((0.4 * 255).toInt()),
        title:  Text(
        style:  TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),  
        'Calendar',
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

      if (entries.containsKey(normalizedDate)){
        showDialog(
          context: context, 
          builder: (context)=> AlertDialog(
            title: Text(
              "${normalizedDate.day}.${normalizedDate.month}.${normalizedDate.year}",
              style: const TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
            content: Text(entries[normalizedDate]!),
            actions: [
              TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),),
            ],
          ),);
      }else{
        showDialog(context: context, builder: (context)=> AlertDialog(
          title:  Text(
            "${normalizedDate.day}.${normalizedDate.month}.${normalizedDate.year}",
),
          content: const Text('There is no recorded entry for this day.'),
          actions: [
            TextButton(
            child: const Text('OK'),
            onPressed: ()=> Navigator.of(context).pop())
          ],
        ));
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
}}