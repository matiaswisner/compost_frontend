import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/post_model.dart';
import '../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ApiService apiService = ApiService();

  final Set<Marker> markers = {};

  bool loading = true;

  static const CameraPosition initialPosition =
  CameraPosition(
    target: LatLng(-34.6037, -58.3816),
    zoom: 10,
  );

  @override
  void initState() {
    super.initState();
    loadMarkers();
  }

  Future<void> loadMarkers() async {
    try {
      final posts = await apiService.getPosts();

      for (var post in posts) {
        final marker = Marker(
          markerId: MarkerId(post.id.toString()),
          position: LatLng(post.lat, post.lng),
          infoWindow: InfoWindow(
            title: post.title,
            snippet:
            '${post.materialName} - ${post.quantity.toStringAsFixed(0)} ${post.unit}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            post.type == 'OFFER'
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueRed,
          ),
        );

        markers.add(marker);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa CompostApp'),
        backgroundColor: const Color(0xFF6EC1E4),
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : GoogleMap(
        initialCameraPosition:
        initialPosition,
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}