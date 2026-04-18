import 'package:flutter/material.dart';
import 'package:skala_mobile/features/feed/models/complaint_post.dart';

class ComplaintCard extends StatefulWidget {
  final ComplaintPost post;
  final VoidCallback onSupport;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const ComplaintCard({
    super.key,
    required this.post,
    required this.onSupport,
    required this.onComment,
    required this.onShare,
  });

  @override
  State<ComplaintCard> createState() => _ComplaintCardState();
}

class _ComplaintCardState extends State<ComplaintCard> {
  late bool _isSupported;
  late int _supportCount;

  @override
  void initState() {
    super.initState();
    _isSupported = widget.post.isSupportedByMe;
    _supportCount = widget.post.supportCount;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'RESOLVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: widget.post.author.avatarUrl != null
                  ? NetworkImage(widget.post.author.avatarUrl!)
                  : null,
              child: widget.post.author.avatarUrl == null
                  ? Text(widget.post.author.name[0].toUpperCase())
                  : null,
            ),
            title: Text(
              widget.post.author.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              children: [
                Text(widget.post.createdAt,
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor(widget.post.status),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.post.status,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on,
                    color: Colors.amber, size: 16),
                Text('${widget.post.author.coins}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.post.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (widget.post.imageUrls.isNotEmpty)
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: widget.post.imageUrls.length,
                itemBuilder: (_, i) => Image.network(
                  widget.post.imageUrls[i],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isSupported = !_isSupported;
                        _supportCount += _isSupported ? 1 : -1;
                      });
                      widget.onSupport();
                    },
                    icon: Icon(
                      _isSupported ? Icons.thumb_up : Icons.thumb_up_outlined,
                      color: _isSupported ? Colors.blue : Colors.grey,
                    ),
                    label: Text(
                      '$_supportCount پشتیوانی',
                      style: TextStyle(
                        color: _isSupported ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: widget.onComment,
                    icon:
                        const Icon(Icons.comment_outlined, color: Colors.grey),
                    label: Text(
                      '${widget.post.commentCount} کۆمێنت',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: widget.onShare,
                    icon: const Icon(Icons.share_outlined, color: Colors.grey),
                    label: const Text(
                      'هاوبەشکردن',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
