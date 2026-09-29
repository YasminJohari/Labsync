import 'package:flutter/material.dart';
import 'package:map_mvvm/view/view.dart';
import 'package:table_calendar/table_calendar.dart';
import '../viewmodels/update_schedule_viewmodel.dart';

class LecturerScheduleUpdateView extends StatelessWidget {
  final String lecturerId;

  const LecturerScheduleUpdateView({
    super.key,
    required this.lecturerId,
  });

  Future<void> _fetchTimesForSelectedDay(
      BuildContext context, LecturerScheduleViewModel viewModel, DateTime? selectedDay) async {
    if (selectedDay == null) return;

    final dateKey = selectedDay.toIso8601String().split('T')[0];
    final times = await viewModel.getTimesForDate(lecturerId, dateKey);
    viewModel.updateAvailableTimes(times);
  }

  String _formatTime(BuildContext context, TimeOfDay time) {
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return ViewWrapper<LecturerScheduleViewModel>(
      builder: (context, viewModel) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Manage Schedule for $lecturerId'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime(2024),
                  lastDay: DateTime(2026),
                  focusedDay: DateTime.now(),
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) =>
                      isSameDay(viewModel.selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    viewModel.setSelectedDay(selectedDay);
                    _fetchTimesForSelectedDay(context, viewModel, selectedDay);
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (viewModel.selectedDay != null)
                  Column(
                    children: [
                      Row(
                        children: [
                          const Text('Select Time: '),
                          ElevatedButton(
                            onPressed: () async {
                              final selectedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (selectedTime != null) {
                                viewModel.setSelectedTime(selectedTime);
                              }
                            },
                            child: Text(
                                _formatTime(context, viewModel.selectedTime)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final dateKey = viewModel.selectedDay
                                      ?.toIso8601String()
                                      .split('T')[0] ??
                                  '';
                              await viewModel.addTimeSlot(
                                lecturerId,
                                dateKey,
                                _formatTime(context, viewModel.selectedTime),
                              );
                              await _fetchTimesForSelectedDay(
                                  context, viewModel, viewModel.selectedDay);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Time slot added successfully."),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            child: const Text('Add Time Slot'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (viewModel.availableTimes.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Available Times:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: viewModel.availableTimes.length,
                              itemBuilder: (context, index) {
                                final time = viewModel.availableTimes[index];
                                return ListTile(
                                  title: Text(time),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      await viewModel.removeTimeSlot(
                                        lecturerId,
                                        viewModel.selectedDay!
                                            .toIso8601String()
                                            .split('T')[0],
                                        time,
                                      );
                                      await _fetchTimesForSelectedDay(
                                          context, viewModel, viewModel.selectedDay);

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Time slot deleted successfully.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      else
                        const Text('No available times for this date.'),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}