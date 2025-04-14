import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(home: InfoPage());
}

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});
  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  String info = 'Loading...';

  @override
  void initState() {
    super.initState();
    loadInfo();
  }

  Future<void> loadInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final ios = await deviceInfo.iosInfo;

    setState(() {
      info = '''
Device: ${ios.name}
Model: ${ios.model}
System: ${ios.systemName} ${ios.systemVersion}
Physical: ${ios.isPhysicalDevice}
    ''';
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("iOS Info")),
        body: Center(child: Text(info)),
      );
}
