import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_launcher/constants.dart';
import 'package:home_launcher/provider.dart';
import 'package:home_launcher/shares_preferences.dart';
import 'package:provider/provider.dart';

class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  String selectedAlpha = '';
  List<String> favApps = [];
  List<Application> filteredApps = [];

  bool isLoading = true;

  loadFavApps() async {
    favApps = await getFavApps();
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    loadFavApps();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppsProvider>(context);

    final color = Theme.of(context).colorScheme;
    // final size = MediaQuery.of(context).size;

    filteredApps = List.from(provider.apps);

    filteredApps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

    filteredApps.removeWhere((element) => favApps.contains(element.packageName));

    Set<String> alphabets = filteredApps.map((e) => e.appName.substring(0, 1).toUpperCase()).toList().toSet();

    if (selectedAlpha != '') {
      filteredApps = filteredApps.where((element) => element.appName.startsWith(selectedAlpha)).toList();
    }

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder(
                stream: DeviceApps.listenToAppsChanges(),
                builder: (context, snapshot) {
                  if (snapshot.data?.event == ApplicationEventType.uninstalled ||
                      snapshot.data?.event == ApplicationEventType.installed ||
                      snapshot.data?.event == ApplicationEventType.disabled ||
                      snapshot.data?.event == ApplicationEventType.enabled) {
                    provider.getApplications();
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            alphaRow(alphabets),
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: GridView.builder(
                                      itemCount: filteredApps.length,
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                                      reverse: true,
                                      itemBuilder: (context, index) {
                                        final app = filteredApps.elementAt(index);

                                        return appIcon(
                                          color,
                                          app,
                                          onTap: () => appDialog(color: color, app: app),
                                          onLongPress: () => openApp(app),
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
                            alphaRow(alphabets),
                          ],
                        ),
                      ),
                      if (favApps.isNotEmpty)
                        favAppsRow(
                            color, provider.apps.where((element) => favApps.contains(element.packageName)).toList()),
                    ],
                  );
                }),
      ),
    );
  }

  Widget alphaRow(Set<String> alphabets) => Column(
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
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  alphabets.elementAt(index),
                  style: const TextStyle(
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.white, offset: Offset(0, 0)),
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

  Widget appIcon(ColorScheme color, Application app,
          {void Function()? onTap, void Function()? onDoubleTap, void Function()? onLongPress}) =>
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          child: Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: color.primaryContainer.withOpacity(opacity),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CircleAvatar(
                      child: Image.memory(
                        (app as ApplicationWithIcon).icon,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Text(
                    app.appName,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  Widget favAppIcon(ColorScheme color, Application app,
          {void Function()? onTap, void Function()? onDoubleTap, void Function()? onLongPress}) =>
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: CircleAvatar(
              child: Image.memory(
                (app as ApplicationWithIcon).icon,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );

  Widget favAppsRow(ColorScheme color, List<Application> apps) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(apps.length < 5 ? apps.length : 5, (index) {
          apps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
          return favAppIcon(
            color,
            apps.elementAt(index),
            onLongPress: () => DeviceApps.openApp(apps.elementAt(index).packageName),
            onTap: () => appDialog(color: color, app: apps.elementAt(index)),
          );
        }),
      );

  Widget myBtn(ColorScheme color, String title, void Function()? onPressed) => Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: color.background.withOpacity(opacity),
          ),
          child: TextButton(
            onPressed: onPressed,
            child: Text(title, textAlign: TextAlign.center),
          ),
        ),
      );

  void openApp(Application app) {
    DeviceApps.openApp(app.packageName);
    setState(() => selectedAlpha = '');
  }

  Future appDialog({required ColorScheme color, required Application app}) => showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            alignment: Alignment.bottomCenter,
            backgroundColor: color.primaryContainer.withOpacity(0.8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  maxRadius: 30,
                  child: Image.memory((app as ApplicationWithIcon).icon, fit: BoxFit.contain),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: color.background.withOpacity(opacity),
                    ),
                    child: TextButton.icon(
                      onPressed: () => openApp(app),
                      label: Text('${app.appName.toUpperCase()}\n${app.packageName}',
                          textAlign: TextAlign.center, maxLines: 3),
                      icon: const Icon(Icons.open_in_new),
                    ),
                  ),
                ),
              ],
            ),
            content: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                myBtn(color, 'App Settings', () => DeviceApps.openAppSettings(app.packageName)),
                myBtn(
                  color,
                  favApps.contains(app.packageName) ? 'Remove from\nFav' : 'Add to\nFav',
                  () async {
                    Navigator.of(context).pop();
                    favApps.contains(app.packageName) ? favApps.remove(app.packageName) : favApps.add(app.packageName);

                    await setFavApps(favApps);
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        },
      );
}
