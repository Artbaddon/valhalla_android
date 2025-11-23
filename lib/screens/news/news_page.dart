import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valhalla_android/services/notification_service.dart';
import 'package:valhalla_android/models/news/news_model.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/services/storage_service.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late Future<List<AppNews>> _futureNews;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _futureNews = Future.value([]); // Inicializar primero
    _loadUserIdAndNews();
  }

  Future<void> _loadUserIdAndNews() async {
    final user = await StorageService.getUser();

    if (user != null) {
      setState(() {
        _userId = user.id;
        _futureNews = NotificationService().getUnreadNotifications(user.id);
      });
    }
  }

  String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat("dd/MM/yyyy hh:mm a").format(date);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<AppNews>>(
        future: _futureNews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("❌ Error cargando noticias"));
          }
          if (_userId == null) {
            return const Center(
              child: Text("🔐 Inicia sesión para ver tus noticias"),
            );
          }
          final news = snapshot.data ?? [];
          if (news.isEmpty) {
            return const Center(child: Text("📭 No tienes noticias"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: news.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final n = news[index];
              return Card(
                color: AppColors.white,
                elevation: 3,
                shadowColor: AppColors.shadow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.notificationTypeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        n.notificationDescription,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          formatDate(n.notificationCreatedAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
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
