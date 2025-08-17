import 'package:get/get.dart';
import 'package:newdawn/globals.dart' as globals;

class AdminLogsController extends GetxController {
  var logs = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  Future<void> fetchLogs({String? userId, String? logType, String? startDate, String? endDate}) async {
  isLoading.value = true;
  logs.clear();

  try {
    // Fetch logs from the server
    List<dynamic> results = await globals.fetchStaffLogs(
      userId: userId ?? '',
      logType: logType,
      startDate: startDate,
      endDate: endDate,
    );
    
    // Parse results and update the logs list
    logs.addAll(results.cast<Map<String, dynamic>>());
    
    // Collect unique user IDs from the logs
    final userIds = logs
        .map((log) => log['userId'].toString()) // Extract `userId` as a string
        .toSet() // Convert to a set to ensure uniqueness
        .toList(); // Convert back to a list

    // Fetch guild members for these unique user IDs
    await globals.fetchGuildMembers(userIds);
  } catch (e) {
    print("Error fetching logs: $e");
  } finally {
    isLoading.value = false;
  }
}

}
