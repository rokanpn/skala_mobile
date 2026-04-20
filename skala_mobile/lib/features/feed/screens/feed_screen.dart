import 'package:flutter/material.dart';
import '../../../services/complaint_service.dart';
import '../../../models/complaint_model.dart';
import '../../../widgets/complaint_card.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../screens/complaint_detail_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<ComplaintModel> complaints = [];
  bool isLoading = true;
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() => isLoading = true);
    try {
      // Method 1: هەوڵی بارکردن بە ComplaintService (بۆ پشتگیری کۆدی کۆن)
      final data = await ComplaintService.getAll();
      if (mounted) {
        setState(() {
          complaints = data;
          isLoading = false;
        });
      }
    } catch (e) {
      // Method 2: ئەگەر ComplaintService سەری نەکەوت، هەوڵبدە بە ApiClient
      try {
        final response = await _apiClient.dio.get(ApiEndpoints.complaints);
        final List<ComplaintModel> loadedComplaints = (response.data as List)
            .map((json) => ComplaintModel.fromJson(json))
            .toList();
        if (mounted) {
          setState(() {
            complaints = loadedComplaints;
            isLoading = false;
          });
        }
      } catch (apiError) {
        if (mounted) {
          setState(() => isLoading = false);
        }
        debugPrint('Error loading complaints (both methods): $e, $apiError');
      }
    }
  }

  Future<void> _supportComplaint(int complaintId) async {
    try {
      // Method 1: هەوڵی support کردن بە ComplaintService
      final success = await ComplaintService.support(complaintId);
      if (success) {
        _loadComplaints();
        return;
      }
    } catch (e) {
      // Method 2: ئەگەر ComplaintService سەری نەکەوت، هەوڵبدە بە ApiClient
      try {
        await _apiClient.dio.post(
          ApiEndpoints.support.replaceAll('{id}', complaintId.toString()),
        );
        _loadComplaints();
      } catch (apiError) {
        debugPrint('Support error (both methods): $e, $apiError');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('هەڵەیەک ڕووی دا لە پشتگیریکردن'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _goToComplaintDetail(int complaintId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComplaintDetailScreen(
          complaintId: complaintId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'فیدی سکاڵاکان',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadComplaints,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1976D2),
              ),
            )
          : complaints.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'هیچ سکاڵایەک نییە',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadComplaints,
                  color: const Color(0xFF1976D2),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = complaints[index];
                      return GestureDetector(
                        onTap: () => _goToComplaintDetail(complaint.id),
                        child: ComplaintCard(
                          userName: complaint.userName,
                          userImage: complaint.userImage ??
                              "https://ui-avatars.com/api/?name=${Uri.encodeComponent(complaint.userName)}",
                          timeAgo: complaint.createdAt.length >= 10
                              ? complaint.createdAt.substring(0, 10)
                              : complaint.createdAt,
                          content: complaint.title,
                          mediaUrl: complaint.mediaUrl,
                          supportCount: complaint.supportCount,
                          onSupport: () => _supportComplaint(complaint.id),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
