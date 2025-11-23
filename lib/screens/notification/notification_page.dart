import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valhalla_android/services/notification_service.dart';
import 'package:valhalla_android/models/notification/notification_model.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/services/storage_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Future<List<Notifications>> _futureNotifications = Future.value(
    [],
  );
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndNotifications();
  }

  Future<void> _loadUserIdAndNotifications() async {
    final user = await StorageService.getUser();
    if (user != null) {
      setState(() {
        _userId = user.id;
        _futureNotifications = NotificationService().getUserNotifications(
          user.id,
        );
      });
    }
  }

  String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat("dd/MM/yyyy 'a las' hh:mm a").format(date);
    } catch (_) {
      return isoDate;
    }
  }

  // Icono según el tipo de notificación
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'Sistema':
        return Icons.computer;
      case 'Seguridad':
        return Icons.security;
      case 'Evento':
        return Icons.event;
      case 'Mantenimiento':
        return Icons.engineering;
      default:
        return Icons.notifications;
    }
  }

  // Color del icono según el tipo
  Color _getIconColor(String type) {
    switch (type) {
      case 'Sistema':
        return Colors.blue;
      case 'Seguridad':
        return Colors.red;
      case 'Evento':
        return Colors.green;
      case 'Mantenimiento':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 1,
        shadowColor: AppColors.shadow,
      ),
      body: FutureBuilder<List<Notifications>>(
        future: _futureNotifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Cargando notificaciones...",
                    style: TextStyle(color: AppColors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Error cargando notificaciones",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Intenta de nuevo más tarde",
                    style: TextStyle(fontSize: 14, color: AppColors.grey),
                  ),
                ],
              ),
            );
          }

          if (_userId == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login_rounded, size: 64, color: AppColors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Inicia sesión",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Para ver tus notificaciones",
                    style: TextStyle(fontSize: 14, color: AppColors.grey),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_rounded,
                    size: 64,
                    color: AppColors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No tienes notificaciones",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Te avisaremos cuando tengas novedades",
                    style: TextStyle(fontSize: 14, color: AppColors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icono de la notificación
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getIconColor(
                            notification.notificationTypeName,
                          ).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getNotificationIcon(
                            notification.notificationTypeName,
                          ),
                          color: _getIconColor(
                            notification.notificationTypeName,
                          ),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Contenido de la notificación
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tipo de notificación
                            Text(
                              notification.notificationTypeName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getIconColor(
                                  notification.notificationTypeName,
                                ),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Descripción
                            Text(
                              notification.notificationDescription,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.black,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Fecha
                            Text(
                              formatDate(notification.notificationCreatedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
