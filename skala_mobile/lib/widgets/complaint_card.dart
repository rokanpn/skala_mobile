import 'package:flutter/material.dart';

class ComplaintCard extends StatelessWidget {
  final String userName;
  final String userImage;
  final String timeAgo;
  final String content;
  final String? mediaUrl;
  final int supportCount;
  final VoidCallback onSupport;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const ComplaintCard({
    super.key,
    required this.userName,
    required this.userImage,
    required this.timeAgo,
    required this.content,
    this.mediaUrl,
    required this.supportCount,
    required this.onSupport,
    this.onComment,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(userImage),
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ✅ ڕیزی 68 - Container گۆڕدرا بە SizedBox
            const SizedBox(height: 10),

            // Content
            Text(
              content,
              style: const TextStyle(fontSize: 14),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),

            // Media if exists
            if (mediaUrl != null && mediaUrl!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  mediaUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Actions
            Row(
              children: [
                // Support Button
                Expanded(
                  child: TextButton.icon(
                    onPressed: onSupport,
                    // ✅ ڕیزی 70 - const زیاد کرا
                    icon: const Icon(Icons.thumb_up_outlined, size: 20),
                    // ✅ ڕیزی 71 - const زیاد کرا
                    label: Text('$supportCount'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),

                // Comment Button
                if (onComment != null)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onComment,
                      icon: const Icon(Icons.comment_outlined, size: 20),
                      label: const Text('کۆمێنت'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                    ),
                  ),

                // Share Button
                if (onShare != null)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.share_outlined, size: 20),
                      label: const Text('هاوبەشکردن'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
