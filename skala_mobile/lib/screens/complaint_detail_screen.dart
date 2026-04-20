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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    try {
      // بارکردنی وردەکاری سکاڵاکە
      final response = await _apiClient.dio
          .get('${ApiEndpoints.complaintDetail}${widget.complaintId}');

      // بارکردنی کۆمێنتەکان - بەکارهێنانی ڕێگای ڕاستەوخۆ
      final commentsResponse = await _apiClient.dio.get(
        '${ApiEndpoints.complaintDetail}${widget.complaintId}/comments',
      );

      if (mounted) {
        setState(() {
          _complaint = response.data;
          _comments = commentsResponse.data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      // ئەگەر هەڵە ڕوویدا
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error loading complaint detail: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('هەڵەیەک ڕووی دا لە بارکردنی وردەکاری سکاڵاکە'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await _apiClient.dio.post(
        '${ApiEndpoints.complaintDetail}${widget.complaintId}/comments',
        data: {'comment': _commentController.text.trim()},
      );
      _commentController.clear();
      _loadDetail();
    } catch (e) {
      debugPrint('Error adding comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('هەڵەیەک ڕووی دا لە زیادکردنی کۆمێنت'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _support() async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.support.replaceAll('{id}', widget.complaintId.toString()),
      );
      _loadDetail();
    } catch (e) {
      debugPrint('Error supporting complaint: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('هەڵەیەک ڕووی دا لە پشتیوانیکردن'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      case 'REJECTED':
        return Colors.red.shade700;
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1976D2),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'وردەکاری سکاڵا',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // هێڵی ستەیت (دۆخ)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _statusColor(_complaint?['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _statusColor(_complaint?['status']),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      _statusText(_complaint?['status']),
                      style: TextStyle(
                        color: _statusColor(_complaint?['status']),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ناونیشان
                  Text(
                    _complaint?['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // وەسف
                  Text(
                    _complaint?['description'] ?? '',
                    style: const TextStyle(
                      color: Colors.black87,
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // پشتیوانی دوگمە
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _support,
                        icon: const Icon(Icons.thumb_up_outlined, size: 18),
                        label: Text(
                          'پشتیوانی (${_complaint?['support_count'] ?? 0})',
                          style: const TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // کۆمێنتەکان
                  Row(
                    children: [
                      const Text(
                        'کۆمێنتەکان',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_comments.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // لیستی کۆمێنتەکان
                  _comments.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'هیچ کۆمێنتێک نییە، یەکەم کۆمێنت تۆ بنووسە',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor:
                                            const Color(0xFF1976D2),
                                        child: Text(
                                          (comment['user']?['name'] ?? 'ب')
                                              .toString()[0]
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        comment['user']?['name'] ??
                                            'بەکارهێنەر',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF1976D2),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _formatDate(
                                            comment['created_at'] ?? ''),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    comment['comment'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // بۆکسی نووسینی کۆمێنت
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'کۆمێنتەکەت بنووسە...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1976D2).withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Color(0xFF1976D2),
                    radius: 24,
                    child: Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    if (dateString.length >= 10) {
      return dateString.substring(0, 10);
    }
    return dateString;
  }
}
