import 'package:flutter/material.dart';
import '../../../services/complaint_service.dart';
import '../../../models/complaint_model.dart';
import '../../../widgets/complaint_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<ComplaintModel> complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() => isLoading = true);
    try {
      final data = await ComplaintService.getAll();
      if (mounted) {
        setState(() {
          complaints = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      debugPrint('Error loading complaints: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فیدی سکاڵاکان'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : complaints.isEmpty
              ? const Center(child: Text('هیچ سکاڵایەک نییە'))
              : ListView.builder(
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    return ComplaintCard(
                      userName: complaint.userName,
                      userImage: complaint.userImage ?? '',
                      timeAgo: complaint.createdAt,
                      content: complaint.title,
                      mediaUrl: complaint.mediaUrl,
                      supportCount: complaint.supportCount,
                      onSupport: () async {
                        await ComplaintService.support(complaint.id);
                        _loadComplaints();
                      },
                    );
                  },
                ),
    );
  }
}
