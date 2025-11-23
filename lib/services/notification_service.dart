// lib/services/notification_service.dart
import 'package:valhalla_android/models/news/news_model.dart';
import 'package:valhalla_android/models/notification/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  final _api = ApiService();

  Future<List<AppNews>> getUnreadNotifications(int userId) async {
    final response = await _api.dio.get('/notifications/unread/$userId/user');
    final data = response.data["notifications"] as List;
    return data.map((json) => AppNews.fromJson(json)).toList();
  }

  Future<List<Notifications>> getUserNotifications(int userId) async {
    final response = await _api.dio.get('/notifications/recipient/$userId/user');
    final data = response.data["notifications"] as List;
    return data.map((json) => Notifications.fromJson(json)).toList();
  }
}