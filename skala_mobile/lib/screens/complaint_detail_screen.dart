import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final int complaintId;
  const ComplaintDetailScreen({super.key, required this.complaintId});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  Map<String, dynamic>? _complaint;
  List<dynamic> _comments = [];
  bool _isLoading = true;
  final _commentController = TextEditingController();
  final _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final res = await _apiClient.dio
          .get('${ApiEndpoints.complaintDetail}${widget.complaintId}');
      final commentsRes = await _apiClient.dio
          .get('${ApiEndpoints.complaintDetail}${widget.complaintId}/comments');
      if (mounted) {
        setState(() {
          _complaint = res.data;
          _comments = commentsRes.data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;
    try {
      await _apiClient.dio.post(
        '${ApiEndpoints.complaintDetail}${widget.complaintId}/comments',
        data: {'comment': _commentController.text},
      );
      _commentController.clear();
      _loadDetail();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _support() async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.support.replaceAll('{id}', widget.complaintId.toString()),
      );
      _loadDetail();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'RESOLVED':
        return Colors.green;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'PENDING':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String? status) {
    switch (status) {
      case 'PENDING':
        return 'چاوەڕوان';
      case 'IN_PROGRESS':
        return 'لە کاردا';
      case 'RESOLVED':
        return 'چارەسەرکراو';
      case 'REJECTED':
        return 'ڕەتکراوەتەوە';
      default:
        return status ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('وردەکاری سکاڵا'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // هێڵی ستەیت
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          _statusColor(_complaint?['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _statusColor(_complaint?['status'])),
                    ),
                    child: Text(
                      _statusText(_complaint?['status']),
                      style: TextStyle(
                          color: _statusColor(_complaint?['status']),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _complaint?['title'] ?? '',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _complaint?['description'] ?? '',
                    style: const TextStyle(color: Colors.black87, height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  // پشتیوانی دوگمە
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _support,
                        icon: const Icon(Icons.thumb_up_outlined),
                        label: Text(
                          'پشتیوانی (${_complaint?['support_count'] ?? 0})',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // کۆمێنتەکان
                  Text(
                    'کۆمێنتەکان (${_comments.length})',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._comments.map((c) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['user']?['name'] ?? 'بەکارهێنەر',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976D2)),
                            ),
                            const SizedBox(height: 4),
                            Text(c['comment'] ?? ''),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          // بۆکسی کۆمێنت
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'کۆمێنتەکەت بنووسە...',
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF1976D2),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _addComment,
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
