class ComplaintModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final String status;
  final int supportCount;
  final String userName;
  final String? userImage;
  final String? mediaUrl;
  final String createdAt;
  final double? latitude;
  final double? longitude;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.supportCount,
    required this.userName,
    this.userImage,
    this.mediaUrl,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> j) {
    return ComplaintModel(
      id: j['id'] is int ? j['id'] : int.parse(j['id'].toString()),
      title: j['title'] ?? '',
      description: j['description'] ?? '',
      category: j['category'] ?? '',
      status: j['status'] ?? 'PENDING',
      supportCount: j['supportCount'] ?? 0,
      userName: j['user'] != null
          ? (j['user']['name'] ?? 'بەکارهێنەر')
          : 'بەکارهێنەر',
      userImage: j['user'] != null ? j['user']['avatar_url'] : null,
      mediaUrl: j['media_url'],
      createdAt: j['createdAt'] ?? '',
      latitude: j['latitude'] != null
          ? double.tryParse(j['latitude'].toString())
          : null,
      longitude: j['longitude'] != null
          ? double.tryParse(j['longitude'].toString())
          : null,
    );
  }
}
