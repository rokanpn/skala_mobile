import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ComplaintCard extends StatelessWidget {
  final String userName;
  final String userImage;
  final String timeAgo;
  final String content;
  final String? mediaUrl;
  final int supportCount;
  final VoidCallback onSupport;

  const ComplaintCard({
    super.key,
    required this.userName,
    required this.userImage,
    required this.timeAgo,
    required this.content,
    this.mediaUrl,
    required this.supportCount,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(userImage)),
            title: Text(userName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(timeAgo, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.more_horiz),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(content,
                style: const TextStyle(fontSize: 15, height: 1.3)),
          ),
          if (mediaUrl != null)
            CachedNetworkImage(
              imageUrl: mediaUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(height: 250, color: Colors.grey[300]),
              errorWidget: (context, url, error) => const SizedBox(),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _btn(Icons.thumb_up_alt_outlined, "پشتگیری ($supportCount)",
                    onSupport),
                _btn(Icons.comment_outlined, "کۆمێنت", () {
                  // لێرە لاپەڕەی کۆمێنتەکان بکەرەوە
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => Container(
                      height: 300,
                      child: Center(
                        child: Text("کۆمێنتەکان - پەرەپێدەدرێت"),
                      ),
                    ),
                  );
                }),
                _btn(Icons.share_outlined, "ناردن", () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: Colors.grey[700], fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
