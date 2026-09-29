import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/filter_appointment_viewmodel.dart';
import 'filter_appointment_details.dart';

class AppointmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AppointmentViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
      ),
      body: Column(
        children: [
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
                      viewModel.filterByDate(selectedDate);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blue, // Sets the background color of the button
                    foregroundColor:
                        Color.fromARGB(255, 96, 10, 33), // Sets the text color
                  ),
                  child: Text('Filter by Date'),
                ),
                if (viewModel.selectedDate != null)
                  Row(
                    children: [
                      Text(
                        'Selected: ${viewModel.selectedDate!.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red, // Test with a visible color
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          viewModel.clearDateFilter();
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: viewModel.fetchAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error fetching data'));
                }
                return ListView.builder(
                  itemCount: viewModel.filteredAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = viewModel.filteredAppointments[index];
                    return ListTile(
                      title: Text(
                        'Date: ${appointment.date.toLocal()}, Time: ${appointment.time.toLocal()}',
                      ),
                      subtitle: Text('Reason: ${appointment.reason}'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentDetailsScreen(
                              appointment: appointment),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
