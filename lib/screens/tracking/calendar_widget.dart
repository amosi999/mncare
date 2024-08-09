import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        _buildCalendarDays(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 56,
      color: const Color.fromARGB(255, 255, 178, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              onDateChanged(selectedDate.subtract(const Duration(days: 7)));
            },
          ),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Text(
              DateFormat('MMMM yyyy').format(selectedDate),
              style: const TextStyle(
                fontSize: 21.5,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              onDateChanged(selectedDate.add(const Duration(days: 7)));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDays(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = selectedDate
              .subtract(Duration(days: selectedDate.weekday - 1))
              .add(Duration(days: index));
          final isToday = date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day;
          final isSelectable = !date.isAfter(DateTime.now());

          return GestureDetector(
            onTap: () {
              if (isSelectable) {
                onDateChanged(date);
              }
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: selectedDate.day == date.day
                    ? const Color.fromARGB(255, 235, 91, 0)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ['일', '월', '화', '수', '목', '금', '토'][date.weekday % 7],
                    style: TextStyle(
                      color: isSelectable
                          ? (selectedDate.day == date.day
                              ? Colors.white
                              : (isToday
                                  ? const Color.fromARGB(255, 235, 91, 0)
                                  : Colors.black))
                          : Colors.grey,
                    ),
                  ),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelectable
                          ? (selectedDate.day == date.day
                              ? Colors.white
                              : (isToday
                                  ? const Color.fromARGB(255, 235, 91, 0)
                                  : Colors.black))
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }
}
