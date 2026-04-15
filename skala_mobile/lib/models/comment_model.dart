class CommentModel {
  final int id;
  final String content;
  final String userName;
  final String? userImage;
  final String createdAt;

  CommentModel({
    required this.id,
    required this.content,
    required this.userName,
    this.userImage,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> j) {
    return CommentModel(
      id: j['id'],
      content: j['content'],
      userName: j['user']['name'],
      userImage: j['user']['avatar_url'],
      createdAt: j['createdAt'].toString(),
    );
  }
}
