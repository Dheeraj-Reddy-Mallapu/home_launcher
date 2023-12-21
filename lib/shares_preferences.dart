import 'package:shared_preferences/shared_preferences.dart';

List<String> favApps = [];
String _favAppsKey = 'favAppsKey';

Future<bool> setFavApps(List<String> value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setStringList(_favAppsKey, value);
}

Future<List<String>> getFavApps() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  favApps = prefs.getStringList(_favAppsKey) ?? [];
  return favApps;
}
