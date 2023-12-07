import 'package:device_apps/device_apps.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_launcher/provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultLightColorScheme = ColorScheme.fromSeed(seedColor: Colors.blueGrey);
    final defaultDarkColorScheme = ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: Brightness.dark);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return ChangeNotifierProvider(
          create: (context) => AppsProvider()..getApplications(),
          child: MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightDynamic ?? defaultLightColorScheme,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkDynamic ?? defaultDarkColorScheme,
            ),
            home: const HomeScreen(),
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SortOptions sortBy = SortOptions.name;
  String selectedAlpha = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppsProvider>(context);

    final color = Theme.of(context).colorScheme;
    // final size = MediaQuery.of(context).size;

    List<Application> filterdApps = provider.apps;

    if (sortBy == SortOptions.name) {
      filterdApps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    } else if (sortBy == SortOptions.updateTime) {
      filterdApps.sort((a, b) => a.updateTimeMillis.compareTo(b.updateTimeMillis));
    }

    Set<String> alphabets = filterdApps.map((e) => e.appName.substring(0, 1).toUpperCase()).toList().toSet();

    if (selectedAlpha != '') {
      filterdApps = filterdApps.where((element) => element.appName.startsWith(selectedAlpha)).toList();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          statusBarColor: Colors.transparent,
        ),
        centerTitle: true,
        title: InkWell(
          child: Text('All Apps', style: TextStyle(color: color.inverseSurface)),
          onLongPress: () => provider.getApplications(),
        ),
        actions: [
          PopupMenuButton(
            iconColor: color.inverseSurface,
            itemBuilder: (context) {
              return [
                PopupMenuItem(value: SortOptions.name, child: Text(SortOptions.name.name)),
                PopupMenuItem(value: SortOptions.updateTime, child: Text(SortOptions.updateTime.name)),
              ];
            },
            onSelected: (value) => setState(() => sortBy = value),
            initialValue: sortBy,
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    itemCount: filterdApps.length,
                    // scrollDirection: Axis.horizontal,
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
                              color: color.primaryContainer.withOpacity(0.8),
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
                                      style: const TextStyle(fontSize: 12),
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
                          onDoubleTap: () => DeviceApps.openApp(app.packageName),
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
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              alphabets.length,
              (index) => InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    alphabets.elementAt(index),
                    style: TextStyle(color: color.inverseSurface),
                  ),
                ),
                onTap: () => setState(() => selectedAlpha = alphabets.elementAt(index)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

enum SortOptions { name, updateTime }
