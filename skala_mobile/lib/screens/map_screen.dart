import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/complaint_service.dart';
import '../models/complaint_model.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<ComplaintModel> _complaints = [];
  bool _isLoading = true;

  // بۆ API نوێ
  final _apiClient = ApiClient();
  List<dynamic> _apiComplaints = [];

  // پۆتانی بنەڕەتی بۆ سلێمانی
  static const LatLng _sulaymaniyahLatLng = LatLng(35.5629, 45.4222);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // هەوڵی هێنانی داتا لە هەردوو سەرچاوە
      await Future.wait([
        _loadComplaintsFromService(),
        _loadComplaintsFromApi(),
      ]);
      if (mounted) {
        _createMarkersFromAllComplaints();
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
          _complaints = complaints;
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
          _apiComplaints = response.data;
        });
      }
    } catch (e) {
      debugPrint("Error from API: $e");
    }
  }

  void _createMarkersFromAllComplaints() {
    final Set<Marker> markers = {};

    // مارکەرەکان لە ComplaintService
    for (int i = 0; i < _complaints.length; i++) {
      final complaint = _complaints[i];
      if (complaint.latitude != null && complaint.longitude != null) {
        final marker = Marker(
          markerId: MarkerId('service_${complaint.id}'),
          position: LatLng(complaint.latitude!, complaint.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getStatusHue(complaint.status),
          ),
          infoWindow: InfoWindow(
            title: complaint.title,
            snippet: complaint.description.length > 100
                ? '${complaint.description.substring(0, 100)}...'
                : complaint.description,
            onTap: () => _showComplaintDetails(complaint),
          ),
        );
        markers.add(marker);
      }
    }

    // مارکەرەکان لە API نوێ
    for (int i = 0; i < _apiComplaints.length; i++) {
      final complaint = _apiComplaints[i];
      final lat = complaint['latitude'];
      final lng = complaint['longitude'];

      if (lat != null && lng != null) {
        final marker = Marker(
          markerId: MarkerId('api_${complaint['id']}'),
          position: LatLng(
            (lat as num).toDouble(),
            (lng as num).toDouble(),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getStatusHueFromString(complaint['status']),
          ),
          infoWindow: InfoWindow(
            title: complaint['title'] ?? 'سکاڵا',
            snippet: complaint['description']?.length > 100
                ? '${complaint['description'].substring(0, 100)}...'
                : complaint['description'] ?? '',
            onTap: () => _showApiComplaintDetails(complaint),
          ),
        );
        markers.add(marker);
      }
    }

    // ئەگەر هیچ مارکەرێک نەبوو، مارکەری سلێمانی زیاد بکە
    if (markers.isEmpty) {
      markers.add(
        const Marker(
          markerId: MarkerId('sulaymaniyah'),
          position: _sulaymaniyahLatLng,
          infoWindow: InfoWindow(
            title: 'سلێمانی',
            snippet: 'شارێکی جوانی کوردستان',
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  double _getStatusHue(String? status) {
    switch (status) {
      case 'RESOLVED':
        return BitmapDescriptor.hueGreen;
      case 'IN_PROGRESS':
        return 30.0; // پرتەقاڵی
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  double _getStatusHueFromString(String? status) {
    switch (status) {
      case 'RESOLVED':
        return BitmapDescriptor.hueGreen;
      case 'IN_PROGRESS':
        return 30.0; // پرتەقاڵی
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  void _showComplaintDetails(ComplaintModel complaint) {
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
                    color: _getStatusColor(complaint.status),
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
                _buildStatusChip(complaint.status),
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
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(complaint.createdAt),
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
                      // ئەگەر ویستت بچێتە پەڕەی وردەکاری
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

  void _showApiComplaintDetails(Map<String, dynamic> complaint) {
    final status = complaint['status'] ?? 'PENDING';
    final statusColor = _getStatusColorFromString(status);

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
                _buildStatusChipFromString(status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              complaint['description'] ?? 'باس نەکراوە',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            if (complaint['userName'] != null)
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    complaint['userName'],
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    String label;
    Color color;

    switch (status) {
      case 'RESOLVED':
        label = 'چارەسەر کراوە';
        color = Colors.green;
        break;
      case 'IN_PROGRESS':
        label = 'لە جێبەجێکردندایە';
        color = Colors.orange;
        break;
      default:
        label = 'چاوەڕوان';
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusChipFromString(String status) {
    String label;
    Color color;

    switch (status) {
      case 'RESOLVED':
        label = 'چارەسەر کراوە';
        color = Colors.green;
        break;
      case 'IN_PROGRESS':
        label = 'لە جێبەجێکردندایە';
        color = Colors.orange;
        break;
      default:
        label = 'چاوەڕوان';
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'RESOLVED':
        return Colors.green;
      case 'IN_PROGRESS':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  Color _getStatusColorFromString(String status) {
    switch (status) {
      case 'RESOLVED':
        return Colors.green;
      case 'IN_PROGRESS':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} ڕۆژ لەمەوپێش';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} کاتژمێر لەمەوپێش';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} خولەک لەمەوپێش';
      } else {
        return 'ئێستا';
      }
    } catch (e) {
      return dateString;
    }
  }

  void _animateToCurrentLocation() async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: _sulaymaniyahLatLng,
            zoom: 13,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نەخشەی سکاڵاکان'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Color(0xFF1976D2)),
            onPressed: _animateToCurrentLocation,
            tooltip: 'شوێنی من',
          ),
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
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _sulaymaniyahLatLng,
                zoom: 12,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              compassEnabled: true,
              mapToolbarEnabled: true,
            ),
      floatingActionButton: _markers.length > 10
          ? FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1976D2),
              onPressed: () {
                if (_mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newCameraPosition(
                      const CameraPosition(
                        target: _sulaymaniyahLatLng,
                        zoom: 12,
                      ),
                    ),
                  );
                }
              },
              child: const Icon(Icons.center_focus_strong),
            )
          : null,
    );
  }
}
