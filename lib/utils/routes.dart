/// Central route path definitions and helpers.
class AppRoutes {
  // Route names
  static const String login = '/';
  static const String homeAdmin = '/home-admin';
  static const String homeOwner = '/home-owner';
  static const String homeGuard = '/home-guard';

  static const String profilePage = '/profile';
  static const String changePassword = '/change-password';
  static const String recoverPassword = '/recover-password';

  static const String parkingHome = '/parking-home';
  
  // Payments
  static const String paymentsHome = '/payments-home';
  static const String paymentCreate = '/payment-create';
  static const String paymentMethods = '/payment-methods';
  static const String paymentMake = '/payment-make';
  static const String paymentHistory = '/payment-history';
  // Reservations
  static const String reservationsHome = '/reservations-home';
  static const String reservationForm = '/reservation-form';
  // Packages
  static const String packagesHome = '/packages-home';
  static const String packageForm = '/package-form';
  // Visitors
  static const String visitorsHome = '/visitors-home';
  static const String visitorForm = '/visitor-form';

  static const String infoCard = '/info-card';

  /// Return the correct home route based on role name.
  static String homeForRole(String roleName) {
    final normalized = roleName.toLowerCase();
    return switch (normalized) {
      'admin' => homeAdmin,
      'owner' => homeOwner,
      'security' => homeGuard,
      _ => login,
    };
  }

  /// Convenience list with every role-specific home route.
  static const List<String> homeRoutes = [homeAdmin, homeOwner, homeGuard];

  /// List of public (unauthenticated) routes used by router redirect logic.
  static const List<String> publicRoutes = [login, recoverPassword];
}
