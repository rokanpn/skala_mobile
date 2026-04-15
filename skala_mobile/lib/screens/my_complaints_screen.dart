import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  List<ComplaintModel> complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final data = await ComplaintService.getMine();
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
      // لێرە دەتوانیت نامەیەکی ئاگادارکردنەوە نیشان بدەیت ئەگەر کێشەیەک لە سێرڤەر هەبوو
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case "RESOLVED":
        return Colors.green;
      case "IN_PROGRESS":
        return Colors.blue;
      case "REJECTED":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusText(String s) {
    switch (s) {
      case "RESOLVED":
        return "چارەسەر کرا";
      case "IN_PROGRESS":
        return "لە کارکردندایە";
      case "REJECTED":
        return "ڕەتکرایەوە";
      default:
        return "چاوەڕوانە";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("سکاڵاکانم",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : complaints.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: complaints.length,
                    itemBuilder: (ctx, i) {
                      final c = complaints[i];
                      return _buildComplaintCard(c);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "هیچ سکاڵایەکت نەناردووە",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(ComplaintModel c) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    c.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                _buildStatusBadge(c.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              c.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], height: 1.4),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(c.category, style: const TextStyle(fontSize: 10)),
                  backgroundColor: Colors.amber[50],
                  labelStyle: TextStyle(color: Colors.amber[900]),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Spacer(),
                Icon(Icons.calendar_today_outlined,
                    size: 12, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(c.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusText(status),
        style: TextStyle(
          color: _statusColor(status),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    final dateStr = date.toString();
    if (dateStr.length >= 10) {
      return dateStr.substring(0, 10);
    }
    return dateStr;
  }
}
