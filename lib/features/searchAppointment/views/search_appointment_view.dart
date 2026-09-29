import 'package:flutter/material.dart';
import 'package:labsync/features/searchAppointment/viewmodels/search_appointment_viewmodel.dart';
import 'package:labsync/models/appointment_model.dart';
import 'package:map_mvvm/view/view.dart';

class AppointmentSearchView extends StatelessWidget {
  final String lecturerId;
  const AppointmentSearchView({super.key, required this.lecturerId});

  @override
  Widget build(BuildContext context) {
    return ViewWrapper<AppointmentSearchViewModel>(
      showProgressIndicator: true,
      builder: (context, viewModel) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!viewModel.isLoading &&
              viewModel.searchResults.isEmpty &&
              viewModel.selectedDate == null) {
            // Fetch all appointments only when the page is loaded and no filters are applied
            viewModel.fetchAppointments(lecturerId);
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: const Text('Search Appointments'),
            backgroundColor: const Color.fromARGB(255, 99, 29, 59),
          ),
          body: Column(
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search by Matric Number or other fields',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (query) {
                    viewModel.searchAppointments(query);
                  },
                ),
              ),
              // Filter by Matric Number
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Filter by Matric Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  onChanged: (matricNumber) {
                    viewModel.filterAppointments(
                        matricNumber, viewModel.selectedDate);
                  },
                ),
              ),
              // Filter by Date
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: viewModel.selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          viewModel.setDateFilter(selectedDate);
                        }
                      },
                      child: Text(viewModel.selectedDate == null
                          ? 'Filter by Date'
                          : 'Selected: ${viewModel.selectedDate!.toLocal().toString().split(' ')[0]}'),
                    ),
                    if (viewModel.selectedDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          viewModel.clearFilters();
                        },
                      ),
                  ],
                ),
              ),
              // Appointments List
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.searchResults.isEmpty
                        ? const Center(child: Text('No appointments found'))
                        : ListView.builder(
                            itemCount: viewModel.searchResults.length,
                            itemBuilder: (context, index) {
                              final appointment =
                                  viewModel.searchResults[index];
                              debugPrint(
                                  'Displaying appointment: ${appointment.studentId}');
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 12.0),
                                child: ListTile(
                                  title:
                                      Text('Student: ${appointment.studentId}'),
                                  subtitle: Text(
                                    'Lecturer: ${appointment.lecturerId}\nDate: ${appointment.date} \nTime: ${appointment.time}\nStatus: ${appointment.status}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.arrow_forward),
                                    onPressed: () {
                                      _showAppointmentDetails(
                                          context, appointment);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
              )
            ],
          ),
        );
      },
    );
  }

  // Function to display appointment details
  void _showAppointmentDetails(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Appointment Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Student ID: ${appointment.studentId}'),
                Text('Lecturer ID: ${appointment.lecturerId}'),
                Text('Date: ${appointment.date}'),
                Text('Time: ${appointment.time}'),
                Text('Status: ${appointment.status}'),
                Text('Reason: ${appointment.reason}'),
                Text('Username: ${appointment.username}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
