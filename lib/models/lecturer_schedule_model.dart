class LecturerSchedule {
  final String lecturerId;
  final List<String> availableDates;
  final List<String> availableTimes;

  LecturerSchedule({
    required this.lecturerId,
    required this.availableDates,
    required this.availableTimes,
  });
}
