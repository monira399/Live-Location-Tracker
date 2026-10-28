
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../service/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  Position? currentPosition;
  final List<LatLng> routePoints = [];

  Timer? _timer;

  bool isLoading = false;
  String? errorMessage;
  bool _isFetching = false;

  bool get isTracking => _timer != null;

  Future<void> startTracking() async {
    if (_timer != null || isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    await _updateLocation();

    isLoading = false;
    notifyListeners();

    if (currentPosition != null && _timer == null) {
      _timer = Timer.periodic(
        const Duration(seconds: 10),
            (_) => _updateLocation(),
      );
    }
  }

  Future<void> _updateLocation() async {
    if (_isFetching) return;

    _isFetching = true;

    try {
      final position = await _locationService.getCurrentLocation();

      currentPosition = position;

      final newPoint = LatLng(
        position.latitude,
        position.longitude,
      );

      // Add a point only when the location has changed.
      if (routePoints.isEmpty ||
          routePoints.last.latitude != newPoint.latitude ||
          routePoints.last.longitude != newPoint.longitude) {
        routePoints.add(newPoint);
      }

      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  void stopTracking() {
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
