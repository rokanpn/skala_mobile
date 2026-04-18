class ComplaintPost {
  final int id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final double? latitude;
  final double? longitude;
  final int supportCount;
  final int commentCount;
  final bool isSupportedByMe;
  final String createdAt;
  final UserSummary author;
  final List<String> imageUrls;

  ComplaintPost({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.latitude,
    this.longitude,
    required this.supportCount,
    required this.commentCount,
    required this.isSupportedByMe,
    required this.createdAt,
    required this.author,
    required this.imageUrls,
  });

  factory ComplaintPost.fromJson(Map<String, dynamic> json) {
    return ComplaintPost(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      priority: json['priority'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      supportCount: json['support_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isSupportedByMe: json['is_supported_by_me'] ?? false,
      createdAt: json['created_at'],
      author: UserSummary.fromJson(json['author']),
      imageUrls: List<String>.from(json['image_urls'] ?? []),
    );
  }
}

class UserSummary {
  final int id;
  final String name;
  final String? avatarUrl;
  final int coins;

  UserSummary({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.coins,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) => UserSummary(
        id: json['id'],
        name: json['name'],
        avatarUrl: json['avatar_url'],
        coins: json['coins'] ?? 0,
      );
}
