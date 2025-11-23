class Notifications {
  final int notificationId;
  final int notificationTypeFkId;
  final String notificationDescription;
  final int? notificationUserFkId;
  final String notificationCreatedAt;
  final String notificationUpdatedAt;
  final String notificationTypeName;
  final bool isForAllUsers;

  Notifications({
    required this.notificationId,
    required this.notificationTypeFkId,
    required this.notificationDescription,
    this.notificationUserFkId,
    required this.notificationCreatedAt,
    required this.notificationUpdatedAt,
    required this.notificationTypeName,
    required this.isForAllUsers,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      notificationId: json['Notification_id'] as int,
      notificationTypeFkId: json['Notification_type_FK_ID'] as int,
      notificationDescription: json['Notification_description'] as String,
      notificationUserFkId: json['Notification_User_FK_ID'] as int?,
      notificationCreatedAt: json['Notification_createdAt'] as String,
      notificationUpdatedAt: json['Notification_updatedAt'] as String,
      notificationTypeName: json['Notification_type_name'] as String,
      isForAllUsers: json['is_for_all_users'] as bool,
    );
  }
}