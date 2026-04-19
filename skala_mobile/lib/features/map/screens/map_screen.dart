import 'package:flutter/material.dart'; // ئەمە زۆر گرنگە بۆ Icon و Colors و StatelessWidget
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ئەم کڵاسە وەک نموونە لێرە دادەنێم بۆ ئەوەی ئیرۆری 'complaints' نەمێنێت
class Complaint {
  final double? latitude;
  final double? longitude;
  final String status;
  Complaint({this.latitude, this.longitude, required this.status});
}

class MapScreen extends StatelessWidget {
  // لێرەدا وەک نموونە لیستێک دروست دەکەین، لە داهاتوودا دەتوانیت لە سێرڤەرەوە بیهێنیت
  final List<Complaint> complaints = [
    Complaint(latitude: 35.5617, longitude: 45.4329, status: 'PENDING'),
    Complaint(latitude: 35.5650, longitude: 45.4400, status: 'RESOLVED'),
  ];

  MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // باشترە لەناو Scaffold بێت بۆ ئەوەی ڕەنگ و بارەکەی ڕێک بێت
      appBar: AppBar(title: const Text('نەخشەی سكاڵاکان')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(35.5617, 45.4329), // سلێمانی
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:
                'com.example.skala_mobile', // ناوی پاکێجی ئەپەکەت بنووسە
          ),
          MarkerLayer(
            markers: complaints
                .where((c) =>
                    c.latitude != null &&
                    c.longitude != null) // دڵنیابوون لەوەی نۆڵ نییە
                .map((c) => Marker(
                      point: LatLng(c.latitude!, c.longitude!),
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_pin,
                        color: _getStatusColor(c.status),
                        size: 40,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

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
