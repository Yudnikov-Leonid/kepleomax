class OnlineStatusUpdate {
  final int userId;
  final bool isOnline;
  final int lastActivityTime;

  OnlineStatusUpdate({
    required this.userId,
    required this.isOnline,
    required this.lastActivityTime,
  });

  factory OnlineStatusUpdate.fromJson(Map<String, dynamic> json) =>
      OnlineStatusUpdate(
        userId: json['user_id'],
        isOnline: json['is_online'],
        lastActivityTime: json['last_activity_time'],
      );
}
