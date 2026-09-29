import 'package:get_it/get_it.dart';
import 'package:labsync/features/StudentActivityHistory/activity_viewmodel.dart';
import 'package:labsync/features/activityHistory/activity_history_viewmodel.dart';
import 'package:labsync/features/appointmentFormPage/viewmodels/appointment_form_viewmodel.dart';
import 'package:labsync/features/approvalAppointment/viewmodels/approval_appointment_viewmodel.dart';
import 'package:labsync/features/attendance/viewmodels/update_att_viewmodel.dart';
import 'package:labsync/features/editProfile/viewmodels/edit_profile_viewmodel.dart';
import 'package:labsync/features/lecturerSchedule/viewmodels/lecturer_schedule_viewmodel.dart';
import 'package:labsync/features/notificationRequest/notification_request_viewmodel.dart';
import 'package:labsync/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:labsync/features/searchAppointment/viewmodels/search_appointment_viewmodel.dart';
import 'package:labsync/features/signUp/viewmodels/sign_up_viewmodel.dart';
import 'package:labsync/features/studentAppointment/viewmodels/student_appointment_viewmodel.dart';
import 'package:labsync/features/login/viewmodels/login_viewmodel.dart';
import 'package:labsync/features/lecturerAppointment/viewmodels/lecturer_appointment_viewmodel.dart';
import 'package:labsync/features/studentNotification/student_notification_viewmodel.dart';
import 'package:labsync/features/studentSchedule/viewmodels/student_schedule_viewmodel.dart';
import 'package:labsync/features/updateSchedule/viewmodels/update_schedule_viewmodel.dart';
import 'package:labsync/features/labHistory/viewmodel/lab_history_viewmodel.dart';
import 'package:labsync/features/labPresence/viewmodel/lab_presence_viewmodel.dart';
import 'package:labsync/features/labPresence/view/lab_presence_view.dart';
import 'package:labsync/services/StudentActivityHistory/activity_abstract.dart';
import 'package:labsync/services/StudentActivityHistory/activity_implementation.dart';
import 'package:labsync/services/activityHistory/activity_history_servce_impl.dart';
import 'package:labsync/services/activityHistory/activity_history_service.dart';
import 'package:labsync/services/appointmentForm/appointment_form_service.dart';
import 'package:labsync/services/appointmentForm/appointment_form_service_firebase.dart';
import 'package:labsync/services/approvalAppointment/approval_appointment_service_abstract.dart';
import 'package:labsync/services/approvalAppointment/approval_appointment_service_impl.dart';
import 'package:labsync/services/attendance/location_service.dart';
import 'package:labsync/services/attendance/location_service_firebase.dart';
import 'package:labsync/services/lecturerAppointment/lecturer_appointment_service_abstract.dart';
import 'package:labsync/services/lecturerAppointment/lecturer_appointment_service_implementation.dart';
import 'package:labsync/services/labHistory/presence_history_abstract.dart';
import 'package:labsync/services/labPresence/presence_abstract.dart';
import 'package:labsync/services/labHistory/presence_history_implementation.dart';
import 'package:labsync/services/labPresence/presence_implementation.dart';
import 'package:labsync/services/lecturerSchedule/lecturer_schedule_abstract.dart';
import 'package:labsync/services/lecturerSchedule/lecturer_schedule_implementation.dart';
import 'package:labsync/services/login/auth_service_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labsync/services/login/auth_service_firebase.dart';
import 'package:labsync/services/notificationRequest/notification_request_service.dart';
import 'package:labsync/services/notificationRequest/notification_request_service_implementation.dart';
import 'package:labsync/services/profile/profile_service_abstract.dart';
import 'package:labsync/services/profile/profile_service_implementation.dart';
import 'package:labsync/services/searchAppointment/search_appointment_service.dart';
import 'package:labsync/services/searchAppointment/search_appointment_service_firebase.dart';
import 'package:labsync/services/signUp/sign_up_service_abstract.dart';
import 'package:labsync/services/signUp/sign_up_service_implementation.dart';
import 'package:labsync/services/studentAppointment/student_appointment_service_implementation.dart';
import 'package:labsync/services/studentNotification/student_notification_service_impl.dart';
import 'package:labsync/services/studentSchedule/student_schedule_service_abstract.dart';
import 'package:labsync/services/studentSchedule/student_schedule_service_implementation.dart';
import 'package:labsync/services/updateSchedule/update_schedule_service_abstract.dart';
import 'package:labsync/services/updateSchedule/update_schedule_service_implementation.dart';
//import 'package:labsync/services/updateSchedule/update_schedule_service_memory.dart';
import 'package:labsync/services/EditProfile/edit_profile_service_abstract.dart';
import 'package:labsync/services/EditProfile/edit_profile_service_implementation.dart';

final serviceLocator = GetIt.instance;

void initializeServiceLocator() {
  // Registering Firestore Instance
  serviceLocator.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);

  // Registering the ViewModels
  serviceLocator.registerLazySingleton(() => LoginViewModel(serviceLocator()));

  serviceLocator.registerLazySingleton<ApprovalAppointmentServiceAbstract>(
    () => ApprovalAppointmentServiceImpl(),
  );

  serviceLocator.registerFactory<ApprovalAppointmentViewmodel>(
    () => ApprovalAppointmentViewmodel(
      serviceLocator<ApprovalAppointmentServiceAbstract>(), // Inject service
    ),
  );

  serviceLocator.registerLazySingleton<AppointmentServiceInterface>(
    () => AppointmentService(FirebaseFirestore.instance),
  );

  // Register your viewmodels or services here
  serviceLocator.registerFactory<AppointmentFormViewModel>(
      () => AppointmentFormViewModel());

  serviceLocator.registerLazySingleton<LocationServiceAbstract>(
    () => LocationServiceImplementation(),
  );
  serviceLocator.registerLazySingleton<StudentDashboardViewModel>(
    () => StudentDashboardViewModel(),
  );

  // History ViewModel
  serviceLocator.registerFactoryParam<HistoryViewModel, String, void>(
    (lecturerId, _) => HistoryViewModel(),
  );

  // Lab Presence ViewModel and View
  serviceLocator.registerFactoryParam<LabPresenceViewModel, String, void>(
    (lecturerId, _) {
      assert(lecturerId.isNotEmpty, 'lecturerId cannot be null or empty');
      return LabPresenceViewModel(lecturerId: lecturerId);
    },
  );
  serviceLocator.registerFactoryParam<LabAttendanceView, String, void>(
    (lecturerId, _) {
      assert(lecturerId.isNotEmpty, 'lecturerId cannot be null or empty');
      return LabAttendanceView(
        lecturerId: lecturerId,
        //viewModel: serviceLocator<LabPresenceViewModel>(),
      );
    },
  );

  // Registering the service (StudentAppointmentService)
  serviceLocator.registerLazySingleton<StudentAppointmentService>(
      () => StudentAppointmentService());

  // Registering the viewmodel (StudentAppointmentViewModel) and injecting the service
  serviceLocator.registerFactory<StudentAppointmentViewModel>(
    () => StudentAppointmentViewModel(
        serviceLocator<StudentAppointmentService>()),
  );

  serviceLocator.registerLazySingleton<AuthServiceAbstract>(
    () => AuthServiceImplementation(
        firestore: serviceLocator<FirebaseFirestore>()),
  );

  // Register LabPresenceService
  serviceLocator.registerLazySingleton<LabPresenceServiceAbstract>(
    () => FirebaseLabAttendanceService(),
  );

  // Register AttendanceHistoryService
  serviceLocator.registerLazySingleton<AttendanceHistoryServiceAbstract>(
    () => FirebaseAttendanceHistoryServices(),
  );

  // Register Lecturer Schedule Service
  serviceLocator.registerLazySingleton<LecturerScheduleServiceAbstract>(() =>
      LecturerScheduleServiceImplementation(
          serviceLocator<FirebaseFirestore>()));

  // Register SearchAppointmentService
  serviceLocator.registerSingleton<SearchAppointmentServiceAbstract>(
    FirebaseSearchAppointmentService(FirebaseFirestore.instance),
  );

  serviceLocator.registerLazySingleton<AppointmentSearchViewModel>(
      () => AppointmentSearchViewModel());

  serviceLocator.registerLazySingleton<LecturerAppointmentServiceAbstract>(
    () => LecturerAppointmentService(),
  );

  // Register LecturerAppointmentViewModel with a named parameter for lecturerId
  serviceLocator.registerFactory<LecturerAppointmentViewModel>(
    () => LecturerAppointmentViewModel(),
  );

  serviceLocator.registerLazySingleton<StudentScheduleServiceAbstract>(
      () => StudentScheduleServiceImpl());

  serviceLocator.registerLazySingleton<SignUpService>(
      () => SignUpServiceImplementation());

  serviceLocator.registerFactory<SignUpViewmodel>(() => SignUpViewmodel());

  serviceLocator
      .registerLazySingleton<ProfileService>(() => ProfileServiceImpl());

  serviceLocator.registerFactory(
      () => ProfileViewModel(serviceLocator<ProfileService>()));

  serviceLocator.registerLazySingleton<EditProfileViewModel>(
      () => EditProfileViewModel());

  serviceLocator.registerLazySingleton<EditProfileService>(
      () => EditProfileServiceImpl());

  serviceLocator.registerLazySingleton<NotificationServiceInterface>(
    () => NotificationService(FirebaseFirestore.instance),
  );

  serviceLocator.registerSingleton(NotificationViewModel());

  // Register Service Interface and Implementation
  serviceLocator.registerLazySingleton<LecturerScheduleServiceInterface>(
    () => LecturerScheduleService(serviceLocator<FirebaseFirestore>()),
  );
  serviceLocator.registerFactory(() => LecturerScheduleViewModel(
        serviceLocator<
            LecturerScheduleServiceAbstract>(), // Provide the abstract
        service: serviceLocator<
            LecturerScheduleServiceInterface>(), // Provide the service
      ));
  // Register the LecturerScheduleViewModel1
  serviceLocator.registerFactoryParam<LecturerScheduleViewModel1, String,
      LecturerScheduleViewModel1>(
    (lecturerId, _) => LecturerScheduleViewModel1(lecturerId: lecturerId),
  );

  serviceLocator.registerLazySingleton<StudentActivityHistoryServiceAbstract>(
      () => StudentActivityHistoryServiceImpl());

  serviceLocator.registerFactory<StudentActivityHistoryViewModel>(
      () => StudentActivityHistoryViewModel());

  serviceLocator.registerFactory<ActivityHistoryViewModel>(
    () => ActivityHistoryViewModel(),
  );

  serviceLocator.registerLazySingleton<ActivityHistoryServiceInterface>(
    () => ActivityHistoryService(),
  );

  serviceLocator.registerLazySingleton<StudentNotificationService>(
    () => StudentNotificationService(),
  );

// Register the StudentNotificationViewModel with the service locator
  serviceLocator.registerLazySingleton<StudentNotificationViewModel>(
    () => StudentNotificationViewModel(
        serviceLocator<StudentNotificationService>()),
  );

  serviceLocator.registerFactory<StudentScheduleViewModel>(
    () => StudentScheduleViewModel(),
  );
}
