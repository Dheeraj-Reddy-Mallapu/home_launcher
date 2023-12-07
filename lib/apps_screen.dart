import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_launcher/constants.dart';
import 'package:home_launcher/provider.dart';
import 'package:provider/provider.dart';

class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  String selectedAlpha = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppsProvider>(context);

    final color = Theme.of(context).colorScheme;
    // final size = MediaQuery.of(context).size;

    List<Application> filterdApps = provider.apps;

    filterdApps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

    Set<String> alphabets = filterdApps.map((e) => e.appName.substring(0, 1).toUpperCase()).toList().toSet();

    if (selectedAlpha != '') {
      filterdApps = filterdApps.where((element) => element.appName.startsWith(selectedAlpha)).toList();
    }

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          alphaRow(color, alphabets),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    itemCount: filterdApps.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                    reverse: true,
                    itemBuilder: (context, index) {
                      final app = filterdApps.elementAt(index);

                      return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: InkWell(
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: color.primaryContainer.withOpacity(opacity),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    child: Image.memory((app as ApplicationWithIcon).icon, fit: BoxFit.contain),
                                  ),
                                  const SizedBox(height: 5),
                                  Expanded(
                                    child: Text(
                                      app.appName,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12, color: color.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  '${DateTime.fromMillisecondsSinceEpoch(app.updateTimeMillis)}\n(Double Tap to launch)',
                                  textAlign: TextAlign.center),
                              duration: const Duration(milliseconds: 1000),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: color.primary,
                            ));
                          },
                          onDoubleTap: () {
                            DeviceApps.openApp(app.packageName);
                            setState(() => selectedAlpha = '');
                          },
                          onLongPress: () async => await DeviceApps.openAppSettings(app.packageName),
                        ),
                      );
                    },
                  ),
                ),
                if (selectedAlpha != '')
                  ElevatedButton(
                    onPressed: () => setState(() => selectedAlpha = ''),
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          alphaRow(color, alphabets),
        ],
      ),
    );
  }

  Widget alphaRow(ColorScheme color, Set<String> alphabets) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          alphabets.length,
          (index) => Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  alphabets.elementAt(index),
                  style: TextStyle(
                    color: color.inversePrimary,
                    shadows: [
                      Shadow(color: color.primary, offset: const Offset(0, 0)),
                    ],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () => setState(() => selectedAlpha = alphabets.elementAt(index)),
            ),
          ),
        ),
      );
}
