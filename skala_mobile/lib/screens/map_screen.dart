import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نەخشەی سکاڵاکان')),
      body: const GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(35.5629, 45.4222), // پۆتانەکانی سلێمانی وەک نموونە
          zoom: 12,
        ),
      ),
    );
  }
}
