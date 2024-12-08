import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const CompassApp());
}

class CompassApp extends StatelessWidget {
  const CompassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Compass App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black)),
      ),
      home: const CompassScreen(),
    );
  }
}

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  _CompassScreenState createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  double? _heading = 0;
  late StreamSubscription<CompassEvent> _compassStream;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  @override
  void dispose() {
    _compassStream.cancel();
    super.dispose();
  }

  // Request permission to use location services
  Future<void> _requestPermissions() async {
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      _compassStream = FlutterCompass.events!.listen((event) {
        setState(() {
          _heading = event.heading;
        });
      });
    } else {
      _showPermissionDeniedMessage();
    }
  }

  // Show message if permission is denied
  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Permission Denied. Location access is needed for the compass.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compass"),
        centerTitle: true,
      ),
      body: Center(
        child: _heading == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildCompass(),
                  const SizedBox(height: 20),
                  _buildHeadingText(),
                  const SizedBox(height: 20),
                  _buildDirectionText(),
                ],
              ),
      ),
    );
  }

  // Build rotating compass UI
  Widget _buildCompass() {
    return Transform.rotate(
      angle: (_heading! * (3.14159 / 180) * -1),
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 8, color: Colors.blue),
          boxShadow: [
            BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 12)
          ],
        ),
        child: const Center(
          child: Icon(Icons.navigation, color: Colors.blue, size: 100),
        ),
      ),
    );
  }

  // Display heading in degrees
  Widget _buildHeadingText() {
    return Text(
      "${_heading!.toStringAsFixed(0)}°",
      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
    );
  }

  // Display the direction based on the heading
  Widget _buildDirectionText() {
    String direction = '';
    if (_heading! >= 345 || _heading! < 15) {
      direction = 'North';
    } else if (_heading! >= 15 && _heading! < 75) {
      direction = 'East';
    } else if (_heading! >= 75 && _heading! < 165) {
      direction = 'South';
    } else if (_heading! >= 165 && _heading! < 255) {
      direction = 'West';
    } else if (_heading! >= 255 && _heading! < 345) {
      direction = 'North';
    }

    return Text(
      direction,
      style: const TextStyle(
          fontSize: 24, fontWeight: FontWeight.w500, color: Colors.blue),
    );
  }
}
