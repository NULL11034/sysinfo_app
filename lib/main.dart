import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'System Info Viewer',
      theme: ThemeData.dark(),
      home: const DeviceInfoScreen(),
    );
  }
}

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  late Future<String> _deviceInfoFuture;

  static const platform = MethodChannel('com.null11034.device/root');

  @override
  void initState() {
    super.initState();
    _deviceInfoFuture = loadDeviceInfo();
  }

  Future<String> loadDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if (Platform.isIOS) {
        final ios = await deviceInfoPlugin.iosInfo;
        return '''
📱 Device: ${ios.name}
🧬 Model: ${ios.utsname.machine}
🛠️ System: ${ios.systemName} ${ios.systemVersion}
🔒 Physical Device: ${ios.isPhysicalDevice}
''';
      } else if (Platform.isAndroid) {
        final android = await deviceInfoPlugin.androidInfo;
        final isRooted = await checkRootStatus();
        return '''
🏭 Manufacturer: ${android.manufacturer}
📱 Model: ${android.model}
🛠️ Android Version: ${android.version.release} (SDK ${android.version.sdkInt})
🔒 Is Physical Device: ${android.isPhysicalDevice}
📡 Supported ABIs: ${android.supportedAbis.join(', ')}
🧩 Root Status: ${isRooted ? 'Rooted' : 'Not Rooted'}
''';
      } else {
        return '❌ Unsupported platform';
      }
    } catch (e) {
      return '⚠️ Error loading device info: $e';
    }
  }

  Future<bool> checkRootStatus() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool result = await platform.invokeMethod('isRooted');
      return result;
    } catch (e) {
      debugPrint('Root check failed: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Info"),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.deepPurpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<String>(
          future: _deviceInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Icon(Icons.devices, size: 50, color: Colors.deepPurple),
                            ),
                            const SizedBox(height: 16),
                            const Center(
                              child: Text(
                                "System Info",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              snapshot.data ?? 'No info available',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
