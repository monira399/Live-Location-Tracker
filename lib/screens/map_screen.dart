
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../provider/location_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  bool _hasMovedToCurrentLocation = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LocationProvider>().startTracking();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location Tracker'),
        centerTitle: true,
      ),
      body: Consumer<LocationProvider>(
        builder: (context, provider, child) {
          final position = provider.currentPosition;

          if (position != null && !_hasMovedToCurrentLocation) {
            _hasMovedToCurrentLocation = true;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              _mapController.move(
                LatLng(position.latitude, position.longitude),
                16,
              );
            });
          }

          final currentPoint = position == null
              ? null
              : LatLng(position.latitude, position.longitude);

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(23.8103, 90.4125),
                  initialZoom: 12,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.live_location_tracker',
                  ),

                  if (provider.routePoints.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: provider.routePoints,
                          strokeWidth: 4,
                          color: Colors.blue,
                        ),
                      ],
                    ),

                  if (currentPoint != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentPoint,
                          width: 150,
                          height: 75,
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet<void>(
                                context: context,
                                builder: (context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'My current location',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Latitude: ${position!.latitude}',
                                        ),
                                        Text(
                                          'Longitude: ${position.longitude}',
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 42,
                                ),
                                Text(
                                  'My location',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              if (provider.isLoading && position == null)
                const Center(child: CircularProgressIndicator()),

              if (provider.errorMessage != null)
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ),

              Positioned(
                right: 16,
                bottom: 24,
                child: FloatingActionButton(
                  onPressed: () {
                    if (currentPoint != null) {
                      _mapController.move(currentPoint, 16);
                    } else {
                      provider.startTracking();
                    }
                  },
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
