import 'package:device_apps/device_apps.dart';
import 'package:flutter/foundation.dart';

class AppsProvider extends ChangeNotifier {
  List<Application> apps = [];

  void getApplications() async {
    apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    apps.removeWhere((element) => element.packageName == 'com.dheeru.home_launcher');
    notifyListeners();
  }
}
