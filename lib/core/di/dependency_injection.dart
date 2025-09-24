import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../network/dio_client.dart';
import '../services/storage_service.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';

// Dashboard
import '../../features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import '../../features/dashboard/presentation/viewmodels/owner_viewmodel.dart';
import '../../features/dashboard/presentation/viewmodels/admin_viewmodel.dart';
import '../../features/dashboard/data/datasources/owner_remote_datasource.dart';
import '../../features/dashboard/data/datasources/admin_remote_datasource.dart';
import '../../features/dashboard/data/repositories/owner_repository_impl.dart';
import '../../features/dashboard/data/repositories/admin_repository_impl.dart';
import '../../features/dashboard/domain/repositories/owner_repository.dart';
import '../../features/dashboard/domain/repositories/admin_repository.dart';
import '../../features/dashboard/domain/usecases/get_owner_stats_usecase.dart';
import '../../features/dashboard/domain/usecases/change_password_usecase.dart';
import '../../features/dashboard/domain/usecases/update_profile_usecase.dart';
import '../../features/dashboard/domain/usecases/get_admin_stats_usecase.dart';
import '../../features/dashboard/domain/usecases/manage_parking_spots_usecase.dart';
import '../../features/dashboard/domain/usecases/manage_visitors_usecase.dart';

// Notes
import '../../features/notes/data/datasources/notes_local_datasource.dart';
import '../../features/notes/data/repositories/notes_repository_impl.dart';
import '../../features/notes/presentation/viewmodels/notes_viewmodel.dart';

// Payments
import '../../features/payments/data/datasources/payments_remote_datasource_impl.dart';
import '../../features/payments/data/repositories/payments_repository_impl.dart';
import '../../features/payments/domain/repositories/payments_repository.dart';
import '../../features/payments/domain/usecases/get_payments_usecase.dart';
import '../../features/payments/domain/usecases/manage_payment_methods_usecase.dart';
import '../../features/payments/presentation/viewmodels/payments_viewmodel.dart';

// Reservations
import '../../features/reservations/data/datasources/reservations_remote_data_source.dart';
import '../../features/reservations/data/repositories/reservations_repository_impl.dart';
import '../../features/reservations/domain/repositories/reservations_repository.dart';
import '../../features/reservations/domain/usecases/reservations_usecases.dart';
import '../../features/reservations/presentation/viewmodels/reservations_viewmodel.dart';

/// Centralized dependency injection container
/// This class manages all the dependencies and provides them to the app
class DependencyInjection {
  static DioClient get _dio => DioClient.instance;
  static StorageService get _storage => StorageService.instance;

  // Lazy initialization of repositories and use cases
  static AuthRepository? _authRepository;
  static OwnerRepository? _ownerRepository;
  static AdminRepository? _adminRepository;
  static PaymentsRepository? _paymentsRepository;
  static ReservationsRepository? _reservationsRepository;

  // Auth dependencies
  static AuthRepository get authRepository {
    _authRepository ??= AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(dioClient: _dio),
      storageService: _storage,
    );
    return _authRepository!;
  }

  static LoginUseCase get loginUseCase => LoginUseCase(authRepository);
  static LogoutUseCase get logoutUseCase => LogoutUseCase(authRepository);
  static GetCurrentUserUseCase get getCurrentUserUseCase => GetCurrentUserUseCase(authRepository);

  // Owner dependencies
  static OwnerRepository get ownerRepository {
    _ownerRepository ??= OwnerRepositoryImpl(
      OwnerRemoteDataSourceImpl(_dio.dio),
    );
    return _ownerRepository!;
  }

  static GetOwnerStatsUseCase get getOwnerStatsUseCase => GetOwnerStatsUseCase(ownerRepository);
  static ChangePasswordUseCase get changePasswordUseCase => ChangePasswordUseCase(ownerRepository);
  static UpdateProfileUseCase get updateProfileUseCase => UpdateProfileUseCase(ownerRepository);

  // Admin dependencies
  static AdminRepository get adminRepository {
    _adminRepository ??= AdminRepositoryImpl(
      AdminRemoteDataSourceImpl(_dio.dio),
    );
    return _adminRepository!;
  }

  static GetAdminStatsUseCase get getAdminStatsUseCase => GetAdminStatsUseCase(adminRepository);
  static ManageParkingSpotsUseCase get manageParkingSpotsUseCase => ManageParkingSpotsUseCase(adminRepository);
  static ManageVisitorsUseCase get manageVisitorsUseCase => ManageVisitorsUseCase(adminRepository);

  // Payments dependencies
  static PaymentsRepository get paymentsRepository {
    _paymentsRepository ??= PaymentsRepositoryImpl(
      PaymentsRemoteDataSourceImpl(_dio),
    );
    return _paymentsRepository!;
  }

  static GetPaymentsUseCase get getPaymentsUseCase => GetPaymentsUseCase(paymentsRepository);
  static GetPaymentStatsUseCase get getPaymentStatsUseCase => GetPaymentStatsUseCase(paymentsRepository);
  static ProcessPaymentUseCase get processPaymentUseCase => ProcessPaymentUseCase(paymentsRepository);
  static CreatePaymentUseCase get createPaymentUseCase => CreatePaymentUseCase(paymentsRepository);
  static ManagePaymentMethodsUseCase get managePaymentMethodsUseCase => ManagePaymentMethodsUseCase(paymentsRepository);

  // Reservations dependencies
  static ReservationsRepository get reservationsRepository {
    _reservationsRepository ??= ReservationsRepositoryImpl(
      remoteDataSource: ReservationsRemoteDataSourceImpl(dio: _dio.dio),
    );
    return _reservationsRepository!;
  }

  static GetReservationsUseCase get getReservationsUseCase => GetReservationsUseCase(reservationsRepository);
  static GetFacilitiesUseCase get getFacilitiesUseCase => GetFacilitiesUseCase(reservationsRepository);
  static CreateReservationUseCase get createReservationUseCase => CreateReservationUseCase(reservationsRepository);
  static CancelReservationUseCase get cancelReservationUseCase => CancelReservationUseCase(reservationsRepository);
  static CheckAvailabilityUseCase get checkAvailabilityUseCase => CheckAvailabilityUseCase(reservationsRepository);

  // Notes repository (simple in-memory implementation)
  static final notesRepository = NotesRepositoryImpl(InMemoryNotesLocalDataSource());

  /// Provides all the required providers for the app
  static List<ChangeNotifierProvider> get providers => [
    // Auth
    ChangeNotifierProvider(
      create: (_) => AuthViewModel(
        authRepository: authRepository,
        loginUseCase: loginUseCase,
        logoutUseCase: logoutUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
      ),
    ),

    // Dashboard
    ChangeNotifierProvider(create: (_) => DashboardViewModel()),

    // Owner
    ChangeNotifierProvider(
      create: (_) => OwnerViewModel(
        getOwnerStatsUseCase,
        changePasswordUseCase,
        updateProfileUseCase,
      ),
    ),

    // Admin
    ChangeNotifierProvider(
      create: (_) => AdminViewModel(
        getAdminStatsUseCase,
        manageParkingSpotsUseCase,
        manageVisitorsUseCase,
      ),
    ),

    // Notes
    ChangeNotifierProvider(
      create: (_) => NotesViewModel(notesRepository)..load(),
    ),

    // Payments
    ChangeNotifierProvider(
      create: (_) => PaymentsViewModel(
        getPaymentsUseCase,
        getPaymentStatsUseCase,
        processPaymentUseCase,
        createPaymentUseCase,
        managePaymentMethodsUseCase,
      ),
    ),

    // Reservations
    ChangeNotifierProvider(
      create: (_) => ReservationsViewModel(
        getReservationsUseCase: getReservationsUseCase,
        getFacilitiesUseCase: getFacilitiesUseCase,
        createReservationUseCase: createReservationUseCase,
        cancelReservationUseCase: cancelReservationUseCase,
        checkAvailabilityUseCase: checkAvailabilityUseCase,
      ),
    ),
  ];

  /// Setup all providers for the app
  static Widget setupProviders({required Widget child}) {
    return MultiProvider(
      providers: providers,
      child: child,
    );
  }

  /// Clean up resources when app is disposed
  static void dispose() {
    _authRepository = null;
    _ownerRepository = null;
    _adminRepository = null;
    _paymentsRepository = null;
    _reservationsRepository = null;
  }
}