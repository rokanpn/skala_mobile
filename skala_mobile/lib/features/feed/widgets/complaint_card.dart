import 'package:flutter/material.dart';
import '../models/complaint_post.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintPost post;
  final VoidCallback onTap;
  final VoidCallback onSupport;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const ComplaintCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onSupport,
    this.onComment,
    this.onShare,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'RESOLVED':
        return Colors.green;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'PENDING':
        return Colors.red;
      case 'REJECTED':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'چاوەڕوان';
      case 'IN_PROGRESS':
        return 'لە کاردا';
      case 'RESOLVED':
        return 'چارەسەرکراو';
      case 'REJECTED':
        return 'ڕەتکراوە';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- سەرەوەی کارت (ناوی بەکارهێنەر، وێنە، ستەیت) ----
              Row(
                children: [
                  // ئەڤاتار
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF1976D2),
                    backgroundImage: post.author.avatarUrl != null
                        ? NetworkImage(post.author.avatarUrl!)
                        : null,
                    child: post.author.avatarUrl == null
                        ? Text(
                            post.author.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // ناو و کات
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          post.createdAt.length >= 10
                              ? post.createdAt.substring(0, 10)
                              : post.createdAt,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ستەیت (دۆخ)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(post.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _statusColor(post.status),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      _statusLabel(post.status),
                      style: TextStyle(
                        color: _statusColor(post.status),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ---- ناونیشان و وەسفی سکاڵاکە ----
              Text(
                post.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                post.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              // ---- وێنەکان (ئەگەر هەبوون) ----
              if (post.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    itemCount: post.imageUrls.length,
                    itemBuilder: (context, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        post.imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // ---- دوگمەکانی کارلێک (پشتیوانی، کۆمێنت، هاوبەشکردن) ----
              Row(
                children: [
                  // دوگمەی پشتیوانی
                  _buildActionButton(
                    icon: post.isSupportedByMe
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    label: '${post.supportCount}',
                    onPressed: onSupport,
                    isActive: post.isSupportedByMe,
                  ),
                  const SizedBox(width: 16),

                  // دوگمەی کۆمێنت
                  _buildActionButton(
                    icon: Icons.comment_outlined,
                    label: '${post.commentCount}',
                    onPressed: onComment ?? onTap,
                    isActive: false,
                  ),
                  const SizedBox(width: 16),

                  // دوگمەی هاوبەشکردن (ئەگەر هەبوو)
                  if (onShare != null)
                    _buildActionButton(
                      icon: Icons.share_outlined,
                      label: 'هاوبەش',
                      onPressed: onShare!,
                      isActive: false,
                    ),

                  const Spacer(),

                  // خاڵەکانی سکاڵا (Coins)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.author.coins}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    final Color color =
        isActive ? const Color(0xFF1976D2) : Colors.grey.shade600;
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
