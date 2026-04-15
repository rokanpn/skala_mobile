class Complaint {
  final String id;
  final String userName;
  final String userImage;
  final String content;
  final String? mediaUrl;
  final String timeAgo;
  int supportCount;

  Complaint({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.content,
    this.mediaUrl,
    required this.timeAgo,
    this.supportCount = 0,
  });
}
