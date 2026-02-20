class OnlineStatusUpdate {

  const OnlineStatusUpdate({
    required this.userId,
    required this.isOnline,
    required this.lastActivityTime,
  });

  factory OnlineStatusUpdate.fromJson(Map<String, dynamic> json) =>
      OnlineStatusUpdate(
        userId: json['user_id'] as int,
        isOnline: json['is_online'] as bool,
        lastActivityTime: json['last_activity_time'] as int,
      );
  final int userId;
  final bool isOnline;
  final int lastActivityTime;
}
