import 'package:flutter/material.dart';
import 'package:labsync/features/appointmentFormPage/views/appointment_form_view.dart';
import 'package:labsync/features/lecturerAppointment/viewmodels/lecturer_appointment_viewmodel.dart';
import 'package:map_mvvm/view/view.dart';

class LecturerAppointmentView extends StatelessWidget {
  final String lecturerId;

  const LecturerAppointmentView({super.key, required this.lecturerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Appointments'),
        backgroundColor: const Color.fromARGB(255, 99, 29, 59),
      ),
      body: ViewWrapper<LecturerAppointmentViewModel>(
        builder: (context, viewModel) {
          // Ensure lecturerId is set after the build phase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.lecturerId != lecturerId) {
              viewModel.setLecturerId(lecturerId);
            }
          });

          if (viewModel.busy) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage.isNotEmpty) {
            return Center(child: Text(viewModel.errorMessage));
          }

          return Column(
            children: [
              if (viewModel.students.isEmpty)
                const Center(child: Text('No students available.'))
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: viewModel.filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = viewModel.filteredStudents[index];

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          leading: CircleAvatar(
                            backgroundColor: Colors.pinkAccent,
                            child: Text(
                              student['username'][0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            student['username'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    student['attendanceStatus'] ==
                                            'You are inside the lab building.'
                                        ? Icons.check_circle_outline
                                        : Icons.cancel_outlined,
                                    color: student['attendanceStatus'] ==
                                            'You are inside the lab building.'
                                        ? Colors.green
                                        : Colors.red,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      student['attendanceStatus'] ==
                                              'You are inside the lab building.'
                                          ? 'Student currently present in lab'
                                          : 'Student is not present in lab',
                                      style: const TextStyle(fontSize: 10),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Classroom: ${student['currentClassroom'] ?? 'Unknown'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          trailing: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 100),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.class_outlined,
                                  color: Colors.deepPurpleAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 22,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        content: Text(
                                          'Are you sure you want to delete ${student['username']}?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await viewModel
                                          .deleteStudent(student['username']);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          onTap: student['attendanceStatus'] ==
                                  'You are inside the lab building.'
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AppointmentFormView(
                                        selectedDate: DateTime.now(),
                                        selectedTime: DateTime.now(),
                                        username: student['username'],
                                        studentId: student['username'],
                                        lecturerId: lecturerId,
                                        userRole: 'Lecturer',
                                        id: '',
                                        status: 'Pending',
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
