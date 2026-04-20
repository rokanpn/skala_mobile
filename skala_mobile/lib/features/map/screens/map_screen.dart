import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// مۆدێلی سکاڵا بۆ نەخشە
class Complaint {
  final double? latitude;
  final double? longitude;
  final String status;

  const Complaint({
    this.latitude,
    this.longitude,
    required this.status,
  });
}

/// پەڕەی نەخشە بۆ پیشاندانی شوێنی سکاڵاکان
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  // لیستی سکاڵاکان وەک نموونە
  static const List<Complaint> _complaints = [
    Complaint(latitude: 35.5617, longitude: 45.4329, status: 'PENDING'),
    Complaint(latitude: 35.5650, longitude: 45.4400, status: 'RESOLVED'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نەخشەی سکاڵاکان'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(35.5617, 45.4329), // سلێمانی
          initialZoom: 13.0,
        ),
        children: [
          _buildTileLayer(),
          _buildMarkerLayer(),
        ],
      ),
    );
  }

  /// چینی نەخشە (Tile Layer)
  Widget _buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.skala_mobile',
    );
  }

  /// چینی نیشانکەکان (Marker Layer)
  Widget _buildMarkerLayer() {
    final markers = _getValidMarkers();

    return MarkerLayer(markers: markers);
  }

  /// لیستی نیشانکەکان (Markers) دروست دەکات
  List<Marker> _getValidMarkers() {
    return _complaints
        .where((complaint) => _hasValidLocation(complaint))
        .map((complaint) => _createMarker(complaint))
        .toList();
  }

  /// دڵنیابوون لەوەی کە شوێن (latitude و longitude) هەیە
  bool _hasValidLocation(Complaint complaint) {
    return complaint.latitude != null && complaint.longitude != null;
  }

  /// نیشانکەیەک (Marker) دروست دەکات بۆ هەر سکاڵایەک
  Marker _createMarker(Complaint complaint) {
    return Marker(
      point: LatLng(complaint.latitude!, complaint.longitude!),
      width: 40.0,
      height: 40.0,
      child: _buildMarkerIcon(complaint.status),
    );
  }

  /// ئایکۆنی نیشانکە دروست دەکات بە پێی دۆخی سکاڵاکە
  Widget _buildMarkerIcon(String status) {
    return Icon(
      Icons.location_pin,
      color: _getStatusColor(status),
      size: 40.0,
    );
  }

  /// ڕەنگ بە پێی دۆخی سکاڵاکە دەگەڕێنێتەوە
  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.red;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'RESOLVED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
