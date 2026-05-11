import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class SOSEmergencyPage extends StatefulWidget {
  final List<String> emergencyContacts;

  const SOSEmergencyPage({super.key, required this.emergencyContacts});

  @override
  _SOSEmergencyPageState createState() => _SOSEmergencyPageState();
}

class _SOSEmergencyPageState extends State<SOSEmergencyPage> {
  Position? _currentPosition;
  bool _isSendingSOS = false;

  Future<void> _requestSMSPermission() async {
    PermissionStatus status = await Permission.sms.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please grant SMS permission.")),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enable location services.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied.")),
        );
        return;
      }
    }

    _currentPosition = await Geolocator.getCurrentPosition();
  }

  Future<void> _openSMSApp() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not available.")),
      );
      return;
    }

    String locationMessage =
        'https://www.google.com/maps?q=${_currentPosition!.latitude},${_currentPosition!.longitude}';

    String message =
        "Help! I'm in danger. My location: $locationMessage";

    // ✅ Open SMS app (user selects contact)
    final Uri smsUri = Uri(
      scheme: 'sms',
      queryParameters: {
        'body': message,
      },
    );

    try {
      await launchUrl(
        smsUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to open SMS app")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Emergency'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 60),
            const SizedBox(height: 20),
            const Text(
              'Press SOS to send alert.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'This will alert your selected contacts via SMS.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                if (_isSendingSOS) return;

                setState(() => _isSendingSOS = true);

                await _requestSMSPermission();
                await _getCurrentLocation();
                await _openSMSApp();

                setState(() => _isSendingSOS = false);
              },
              child: Text(
                _isSendingSOS ? 'Sending SOS...' : 'SEND SOS',
                style: const TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}