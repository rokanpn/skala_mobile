import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../services/complaint_service.dart';
import '../models/complaint_model.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import 'complaint_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // بۆ Flutter Map
  List<latlong.LatLng> _points = [];
  List<dynamic> _complaints = [];
  List<ComplaintModel> _serviceComplaints = [];
  bool _isLoading = true;

  final ApiClient _apiClient = ApiClient();

  // پۆتانی بنەڕەتی بۆ سلێمانی
  static const _sulaymaniyahLat = 35.5629;
  static const _sulaymaniyahLng = 45.4222;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadComplaintsFromService(),
        _loadComplaintsFromApi(),
      ]);

      if (mounted) {
        _extractPoints();
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading map data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadComplaintsFromService() async {
    try {
      final complaints = await ComplaintService.getAll();
      if (mounted) {
        setState(() {
          _serviceComplaints = complaints;
        });
      }
    } catch (e) {
      debugPrint("Error from ComplaintService: $e");
    }
  }

  Future<void> _loadComplaintsFromApi() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.mapComplaints);
      if (mounted && response.data != null) {
        setState(() {
          _complaints = response.data;
        });
      }
    } catch (e) {
      debugPrint("Error from API: $e");
    }
  }

  void _extractPoints() {
    final List<latlong.LatLng> points = [];

    // خاڵەکان لە API نوێ
    for (final complaint in _complaints) {
      final lat = complaint['latitude'];
      final lng = complaint['longitude'];
      if (lat != null && lng != null) {
        points.add(latlong.LatLng(
          (lat as num).toDouble(),
          (lng as num).toDouble(),
        ));
      }
    }

    // خاڵەکان لە ComplaintService
    for (final complaint in _serviceComplaints) {
      if (complaint.latitude != null && complaint.longitude != null) {
        points.add(latlong.LatLng(
          complaint.latitude!,
          complaint.longitude!,
        ));
      }
    }

    setState(() {
      _points = points;
    });
  }

  Color _getMarkerColor(String? status) {
    switch (status) {
      case 'RESOLVED':
        return Colors.green;
      case 'IN_PROGRESS':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'RESOLVED':
        return 'چارەسەر کراوە';
      case 'IN_PROGRESS':
        return 'لە جێبەجێکردندایە';
      case 'REJECTED':
        return 'ڕەتکراوەتەوە';
      default:
        return 'چاوەڕوان';
    }
  }

  void _showComplaintDetails(Map<String, dynamic> complaint) {
    final status = complaint['status'] ?? 'PENDING';
    final statusColor = _getMarkerColor(status);
    final statusLabel = _getStatusLabel(status);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    complaint['title'] ?? 'سکاڵا',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              complaint['description'] ?? 'باس نەکراوە',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('داخستن'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ComplaintDetailScreen(
                            complaintId: complaint['id'],
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('زانیاری زیاتر'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceComplaintDetails(ComplaintModel complaint) {
    final statusColor = _getMarkerColor(complaint.status);
    final statusLabel = _getStatusLabel(complaint.status);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    complaint.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              complaint.description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  complaint.userName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.favorite, size: 16, color: Colors.red[300]),
                const SizedBox(width: 4),
                Text(
                  '${complaint.supportCount}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('داخستن'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ComplaintDetailScreen(
                            complaintId: complaint.id,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('زانیاری زیاتر'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // دروستکردنی مارکەرەکان لە هەموو سکاڵاکان
    final List<Marker> markers = [];

    // مارکەرەکان لە API
    for (final complaint in _complaints) {
      final lat = complaint['latitude'];
      final lng = complaint['longitude'];
      if (lat != null && lng != null) {
        final complaintId = complaint['id'];
        final status = complaint['status'] ?? 'PENDING';
        markers.add(
          Marker(
            point: latlong.LatLng(
              (lat as num).toDouble(),
              (lng as num).toDouble(),
            ),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showComplaintDetails(complaint),
              child: Icon(
                Icons.location_pin,
                color: _getMarkerColor(status),
                size: 36,
                shadows: const [
                  Shadow(blurRadius: 4, color: Colors.black45),
                ],
              ),
            ),
          ),
        );
      }
    }

    // مارکەرەکان لە ComplaintService
    for (final complaint in _serviceComplaints) {
      if (complaint.latitude != null && complaint.longitude != null) {
        markers.add(
          Marker(
            point: latlong.LatLng(
              complaint.latitude!,
              complaint.longitude!,
            ),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showServiceComplaintDetails(complaint),
              child: Icon(
                Icons.location_pin,
                color: _getMarkerColor(complaint.status),
                size: 36,
                shadows: const [
                  Shadow(blurRadius: 4, color: Colors.black45),
                ],
              ),
            ),
          ),
        );
      }
    }

    // ئەگەر هیچ مارکەرێک نەبوو، مارکەری سلێمانی زیاد بکە
    if (markers.isEmpty) {
      markers.add(
        Marker(
          point: const latlong.LatLng(_sulaymaniyahLat, _sulaymaniyahLng),
          width: 40,
          height: 40,
          child: const Icon(
            Icons.location_pin,
            color: Colors.blue,
            size: 36,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'نەخشەی سکاڵاکان',
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
            icon: const Icon(Icons.refresh, color: Color(0xFF1976D2)),
            onPressed: _loadData,
            tooltip: 'نوێکردنەوە',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1976D2)),
                  SizedBox(height: 16),
                  Text('بارکردنی نەخشە و سکاڵاکان...'),
                ],
              ),
            )
          : FlutterMap(
              options: MapOptions(
                initialCenter:
                    const latlong.LatLng(_sulaymaniyahLat, _sulaymaniyahLng),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.skala.app',
                ),
                MarkerLayer(
                  markers: markers,
                ),
              ],
            ),
    );
  }
}
