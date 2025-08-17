import 'package:get/get.dart';
import 'package:newdawn/globals.dart' as globals;

class LogsController extends GetxController {
  var logResults = <Map<String, dynamic>>[].obs; // Change to hold JSON data as Map
  var isLoading = false.obs;

  // Fetch logs based on presence of date and/or steamId
  Future<void> fetchLogs({required String version, String? date, String? steamId}) async {
    isLoading.value = true;
    logResults.clear();

    try {
      List<Map<String, dynamic>> logs;
      if (steamId != null && steamId.isNotEmpty) {
        // Fetch logs by Steam ID
        logs = await globals.fetchLogsBySteamId(version, date ?? '', steamId);
      } else if (date != null && date.isNotEmpty) {
        // Fetch logs by date only
        logs = await globals.fetchLogsByDate(version, date);
      } else {
        throw Exception("Either date or Steam ID must be provided.");
      }
      logResults.addAll(logs); // Add fetched logs to the observable list
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
