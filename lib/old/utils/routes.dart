/// Central route path definitions and helpers.
class AppRoutes {
  // Route names
  static const String login = '/';
  static const String homeAdmin = '/home-admin';
  static const String homeOwner = '/home-owner';
  static const String detailAdmin = '/detail-admin';
  static const String detailOwner = '/detail-owner';
  static const String changePassword = '/change-password';
  static const String changePasswordProfileAdmin =
      '/change-password-profile-admin';
  static const String changePasswordProfileOwner =
      '/change-password-profile-owner';
  static const String recoverPassword = '/recover-password';

  static const String parkingHomeAdmin = '/parking-home-admin';
  // Payments
  static const String paymentsHome = '/payments-home';
  static const String paymentMethods = '/payment-methods';
  static const String paymentMethodForm = '/payment-method-form';
  static const String paymentHistory = '/payment-history';
  // Reservations
  static const String reservationsHome = '/reservations-home';
  static const String reservationForm = '/reservation-form';

  /// Return the correct home route based on role name.
  static String homeForRole(String roleName) =>
      roleName.toLowerCase() == 'admin' ? homeAdmin : homeOwner;

  /// List of public (unauthenticated) routes used by router redirect logic.
  static const List<String> publicRoutes = [
    login,
    recoverPassword,
    changePassword,
  ];
}
