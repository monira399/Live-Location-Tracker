
import 'package:flutter/material.dart';
import 'package:live_location_tracker/provider/location_provider.dart';
import 'package:live_location_tracker/screens/map_screen.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocationProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MapScreen(),
      ),
    );
  }
}
