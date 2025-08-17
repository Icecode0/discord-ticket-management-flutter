import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:newdawn/dashboard.dart';
import 'package:newdawn/login.dart';
import 'package:newdawn/oauth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Color definitions
Color logoBlue = const Color.fromARGB(255, 96, 230, 249);
Color themeDarkBlue = const Color.fromARGB(255, 17, 85, 94);
Color discordPurple = const Color.fromARGB(255, 114, 137, 218);
Color themeWhite = const Color.fromARGB(255, 237, 241, 241);
Color themeUIGrey = const Color.fromARGB(255, 33, 37, 46);

// Discord and User Management
String discCode = '';
String discAccessToken = '';
String discRefreshToken = '';
DateTime discExpiresIn = DateTime.now();
Map<String, dynamic> getUserResponse = {};
List getUserGuildsResponse = [];
List<String> guildRoles = [];
bool userResponse = false;
String? staffLevel = null;
bool isStaff = false;
Map<String, Map<String, String>> guildMembers = {};

const String apiBaseUrl = 'https://api.a-new-dawn.net';

// Navigation using GoRouter
GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Login(),
    ),
    GoRoute(
      path: '/Process_Oauth',
      builder: (context, state) => const Oauth(),
    ),
    GoRoute(
      path: '/Dashboard',
      builder: (context, state) => const Dashboard(),
    ),
  ],
);

String getAstrologicalSign(DateTime date) {
  int day = date.day;
  int month = date.month;

  if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
    return "Aquarius";
  } else if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) {
    return "Pisces";
  } else if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
    return "Aries";
  } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
    return "Taurus";
  } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
    return "Gemini";
  } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
    return "Cancer";
  } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
    return "Leo";
  } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
    return "Virgo";
  } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
    return "Libra";
  } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
    return "Scorpio";
  } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
    return "Sagittarius";
  } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
    return "Capricorn";
  } else {
    return "Unknown";
  }
}

String generateToken(String userId) {
  // Ensure user ID has enough characters
  if (userId.length < 8) {
    throw Exception("User ID must be at least 8 characters long.");
  }

  // Extract user-specific characters
  String userPart = userId[1] + userId[5] + userId[2] + userId[7];

  // Get astrological sign based on the current date
  DateTime now = DateTime.now();
  String astrologicalSign = getAstrologicalSign(now);
  String signPart = astrologicalSign.substring(1, 3); // Take the 2nd and 3rd characters

  // Generate timestamp part
  String timestampPart = now.millisecondsSinceEpoch.toString();

  // Combine all parts to form the token
  String token = "${userPart[0]}${signPart[0]}${userPart[1]}${signPart[1]}${userPart[2]}${userPart[3]}$timestampPart";

  return token;
}

Future<void> loadStoredData(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print("Loading Store Data");
  print(discAccessToken);
  discAccessToken = prefs.getString('access_token') ?? '';
  discRefreshToken = prefs.getString('refresh_token') ?? '';
  String? expiresInString = prefs.getString('expires_in');
  if (expiresInString != null) {
    discExpiresIn = DateTime.parse(expiresInString);
  }

  // Load user info if available
  String? userInfoString = prefs.getString('user_info');
  if (userInfoString != null) {
    getUserResponse = jsonDecode(userInfoString);
    userResponse = true;
  }

  // Check if the token is still valid
  if (DateTime.now().isAfter(discExpiresIn)) {
    await refreshToken(); // Refresh token if needed
  }

  if (discAccessToken.isNotEmpty) {
    // Proceed with loading your app's main content
    GoRouter.of(context).go('/Dashboard');
  } else {
    // Redirect to login if no valid token is found
    GoRouter.of(context).go('/');
  }
}


// OAuth2 token exchange and get user data
Future<void> oauth(String code) async {
  final url = '$apiBaseUrl/oauth/discord?code=$code';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      discAccessToken = data['access_token'];
      discRefreshToken = data['refresh_token'];
      discExpiresIn = DateTime.now().add(Duration(seconds: data['expires_in']));

      // Store tokens and expiration time in shared_preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', discAccessToken);
      await prefs.setString('refresh_token', discRefreshToken);
      await prefs.setString('expires_in', discExpiresIn.toIso8601String());

      // You can also store user info if needed
      await prefs.setString('user_info', jsonEncode(data['user_info']));
    } else {
      throw Exception('Failed to exchange code for token');
    }
  } catch (e) {
    print('Error during OAuth: $e');
  }
}


Future<void> getUser() async {
  final url = '$apiBaseUrl/user-profile/${getUserResponse['id']}';

  try {
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $discAccessToken',
    });

    if (response.statusCode == 200) {
      getUserResponse = jsonDecode(response.body);
      userResponse = true;

      // After getting the user profile, check the staff level
      await checkStaffLevel(getUserResponse['id'].toString());
    } else {
      throw Exception('Failed to get user data');
    }
  } catch (e) {
    print('Error fetching user data: $e');
  }
}

Future<void> checkStaffLevel(String discordId) async {
  final url = '$apiBaseUrl/staff/check/$discordId';
  String token = generateToken(discordId);
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
          'Content-Type': 'application/json',
          'X-Custom-Token': token,
          'X-UserId': getUserResponse['id'].toString(),
        },
      );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String staffCategory = data['category'];
      staffLevel = staffCategory;
      print('User staff category: $staffCategory');
      isStaff = true; // Set to true if user is found in any staff category
    } else if (response.statusCode == 404) {
      print('User not found in any staff category');
      isStaff = false; // User is not staff
    } else {
      throw Exception('Failed to check staff level');
    }
  } catch (e) {
    print('Error checking staff level: $e');
    isStaff = false; // Error means user is not recognized as staff
  }
}


Future<void> getUserRoles() async {
  final url = '$apiBaseUrl/user-roles/${getUserResponse['id']}';
  
  try {
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $discAccessToken',
    });


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      guildRoles = List<String>.from(data['roles']);
    } else {
      throw Exception('Failed to get user roles');
    }
  } catch (e) {
    print('Error fetching user roles: $e');
  }
}

// Fetch all tickets from the Flask API
Future<List<dynamic>> fetchAllTickets() async {
  final url = '$apiBaseUrl/all-tickets';
  String token = generateToken(getUserResponse['id'].toString(),);
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
          'Content-Type': 'application/json',
          'X-Custom-Token': token,
          'X-UserId': getUserResponse['id'].toString(),
        },);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch all tickets');
    }
  } catch (e) {
    print('Error fetching all tickets: $e');
    return [];
  }
}

// Fetch tickets by user ID from the Flask API
Future<List<dynamic>> fetchTicketsByUser(String userId) async {
  final url = '$apiBaseUrl/tickets?opened_by=$userId';
  String token = generateToken(getUserResponse['id'].toString(),);
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
          'Content-Type': 'application/json',
          'X-Custom-Token': token,
          'X-UserId': getUserResponse['id'].toString(),
        },);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch tickets by user');
    }
  } catch (e) {
    print('Error fetching tickets by user: $e');
    return [];
  }
}

// Sending a message
Future<void> sendMessage(String ticketNumber, String content, String messageId) async {
  final url = '$apiBaseUrl/ticket/$ticketNumber/message/send';
  final DateTime now = DateTime.now();
  String token = generateToken(getUserResponse['id'].toString(),);
  final Map<String, dynamic> newMessage = {
    'Author': getUserResponse['id'].toString(), // Ensure Author is a string
    'Content': content,
    'MessageId': messageId, // Use the passed MessageId
    'Time': now.toIso8601String(),
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
          'Content-Type': 'application/json',
          'X-Custom-Token': token,
          'X-UserId': getUserResponse['id'].toString(),
        },
      body: jsonEncode(newMessage),
    );

    if (response.statusCode == 200) {
      print('Message sent successfully');
    } else {
      throw Exception('Failed to send message');
    }
  } catch (e) {
    print('Error sending message: $e');
  }
}


// Editing a message
Future<void> editMessage(String ticketNumber, String messageId, String newContent) async {
  final url = '$apiBaseUrl/ticket/$ticketNumber/message/$messageId/edit';
  String token = generateToken(getUserResponse['id'].toString(),);
  final Map<String, dynamic> editedMessage = {
    'Content': newContent,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
          'Content-Type': 'application/json',
          'X-Custom-Token': token,
          'X-UserId': getUserResponse['id'].toString(),
        },
      body: jsonEncode(editedMessage),
    );

    if (response.statusCode == 200) {
      print('Message edited successfully');
    } else {
      throw Exception('Failed to edit message');
    }
  } catch (e) {
    print('Error editing message: $e');
  }
}

// Deleting a message
Future<void> deleteMessage(String ticketNumber, String messageId) async {
  final url = '$apiBaseUrl/ticket/$ticketNumber/message/$messageId/delete';
  String token = generateToken(getUserResponse['id'].toString(),);
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
          'Content-Type': 'application/json',
          'X-Custom-Token': token,
          'X-UserId': getUserResponse['id'].toString(),
        },);
    if (response.statusCode == 200) {
      print('Message deleted successfully');
    } else {
      throw Exception('Failed to delete message');
    }
  } catch (e) {
    print('Error deleting message: $e');
  }
}



// Fetch a specific ticket by ticket number from the Flask API
Future<Map<String, dynamic>> fetchTicketByNumber(String ticketNumber) async {
  final url = '$apiBaseUrl/ticket/$ticketNumber';
  String token = generateToken(getUserResponse['id'].toString(),);
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
          'Content-Type': 'application/json',
          'X-Custom-Token': token,
          'X-UserId': getUserResponse['id'].toString(),
        },);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch ticket by number');
    }
  } catch (e) {
    print('Error fetching ticket by number: $e');
    return {};
  }
}

Future<void> submitTicket({
  required String reason,
  required String steamId,
  required List<String> evidence,
  required String ticketType,
  int? offenderDiscordId, // Only for Discord Report
  String? timestamp,      // Optional for Appeal
  String? location,       // Optional for Appeal
}) async {
  // Get the current time for OpenTime
  String openTime = DateTime.now().toIso8601String();
  String token = generateToken(getUserResponse['id'].toString());
  // Construct the JSON payload based on the ticket type
  Map<String, dynamic> ticketData = {
    "OpenedBy": getUserResponse['id'].toString(), // Discord ID of the user
    "OpenTime": openTime,
    "Reason": reason,
    "SteamID": steamId,
    "EvidenceLinks": evidence.isEmpty ? [] : evidence,
    "Closed": false,
    "ClosedBy": "",
    "CloseTime": "",
    "ClaimedBy": "",
    "InAttendance": "",
    "Chatlog": [],
  };

  if (ticketType == 'inGame') {
    // Additional fields for in-game report
    ticketData.addAll({
      "Timestamp": timestamp ?? "",
      "Location": location ?? "",
    });
  } else if (ticketType == 'discord') {
    // Add offender Discord ID for Discord report
    ticketData.addAll({
      "OffenderDiscord": offenderDiscordId.toString(),
    });
  } else if (ticketType == 'appeal') {
    // Add optional timestamp and location for appeal
    ticketData.addAll({
      "Timestamp": timestamp ?? "",
      "Location": location ?? "",
    });
  }

  // Determine the endpoint based on the ticket type
  String endpoint;
  switch (ticketType) {
    case 'inGame':
      endpoint = '/ticket/submit/ingame';
      break;
    case 'discord':
      endpoint = '/ticket/submit/discord';
      break;
    case 'appeal':
      endpoint = '/ticket/submit/appeal';
      break;
    default:
      throw ArgumentError("Invalid ticket type: $ticketType");
  }

  // Construct the full URL (replace 'your_base_url' with your actual base URL)
  String url = '$apiBaseUrl$endpoint';

  // Send the POST request to the API
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Custom-Token': token,
          'X-UserId': getUserResponse['id'].toString(),
      },
      body: jsonEncode(ticketData),
    );

    if (response.statusCode == 200) {
      print('Ticket submitted successfully');
    } else {
      print('Failed to submit ticket: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error submitting ticket: $e');
  }
}


Future<void> claimTicket(String ticketNumber) async {
  final url = '$apiBaseUrl/ticket/$ticketNumber/claim';
  String token = generateToken(getUserResponse['id'].toString());
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Custom-Token': token,
          'X-UserId': getUserResponse['id'].toString(),
      },
      body: jsonEncode({'user_id': getUserResponse['id'].toString()}), // Changed key from 'claimed_by' to 'user_id'
    );



    if (response.statusCode == 200) {
      print('Ticket claimed successfully');
    } else {
      throw Exception('Failed to claim ticket');
    }
  } catch (e) {
    print('Error claiming ticket: $e');
  }
}

Future<void> unclaimTicket(String ticketNumber) async {
  final url = '$apiBaseUrl/ticket/$ticketNumber/unclaim';
  String token = generateToken(getUserResponse['id'].toString());
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Custom-Token': token,
          'X-UserId': getUserResponse['id'].toString(),
      },
      body: jsonEncode({'user_id': getUserResponse['id'].toString()}), // Changed key from 'claimed_by' to 'user_id'
    );

    if (response.statusCode == 200) {
      print('Ticket unclaimed successfully');
    } else {
      throw Exception('Failed to unclaim ticket');
    }
  } catch (e) {
    print('Error unclaiming ticket: $e');
  }
}



Future<void> closeTicket(String ticketNumber) async {
  final url = '$apiBaseUrl/ticket/$ticketNumber/close';
  String token = generateToken(getUserResponse['id'].toString());
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Custom-Token': token,
        'X-UserId': getUserResponse['id'].toString(),
      },
      body: jsonEncode({
        'user_id': getUserResponse['id'].toString(),  // Changed from 'closed_by' to 'user_id'
      }),
    );

    if (response.statusCode == 200) {
      print('Ticket closed successfully');
    } else {
      throw Exception('Failed to close ticket');
    }
  } catch (e) {
    print('Error closing ticket: $e');
  }
}





// Utility functions for screen dimensions
double getWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

// Method to ensure the token is still valid before making requests
Future<void> ensureValidToken() async {
  if (DateTime.now().isAfter(discExpiresIn)) {
    await refreshToken();
  }
}


Future<void> fetchGuildMembers(List<String> userIds) async {
  final url = '$apiBaseUrl/guild-members';
  
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_ids': userIds}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> members = jsonDecode(response.body);
      for (var member in members) {
        final userId = member['id'];
        guildMembers[userId] = {
          'username': member['username'] ?? userId,  // Use userId if username is null
          'avatar': member['avatar'] ?? ''  // Default to empty string if avatar is null
        };
      }
    } else {
      throw Exception('Failed to fetch guild members');
    }
  } catch (e) {
    print('Error fetching guild members: $e');
  }
}

// Refresh token using Flask API
Future<void> refreshToken() async {
  final url = '$apiBaseUrl/refresh-token';

  try {
    final response = await http.post(Uri.parse(url), body: {
      'refresh_token': discRefreshToken,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      discAccessToken = data['access_token'];
      discExpiresIn = DateTime.now().add(Duration(seconds: data['expires_in']));
    } else {
      throw Exception('Failed to refresh token');
    }
  } catch (e) {
    print('Error refreshing token: $e');
  }
}

// Add staff member
Future<void> addStaffMember(String category, String userId) async {
  String token = generateToken(getUserResponse['id'].toString());
  final url = '$apiBaseUrl/staff/add';
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json',
      'X-Custom-Token': token,
      'X-UserId': getUserResponse['id'].toString(),},
      body: jsonEncode({'category': category, 'user_id': userId}),
    );
    if (response.statusCode == 200) {
      print('Staff member added successfully');
    } else {
      print('Failed to add staff member');
    }
  } catch (e) {
    print('Error adding staff member: $e');
  }
}

// Remove staff member
Future<void> removeStaffMember(String category, String userId) async {
  String token = generateToken(getUserResponse['id'].toString());
  final url = '$apiBaseUrl/staff/remove';
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json',
        'X-Custom-Token': token,
        'X-UserId': getUserResponse['id'].toString(),},
      body: jsonEncode({'category': category, 'user_id': userId}),
    );
    if (response.statusCode == 200) {
      print('Staff member removed successfully');
    } else {
      print('Failed to remove staff member');
    }
  } catch (e) {
    print('Error removing staff member: $e');
  }
}

// Helper function to convert date format from MM.DD.YYYY to YYYY.MM.DD
String convertDateToRequiredFormat(String date) {
  final parts = date.split('.');
  if (parts.length == 3) {
    final month = parts[0].padLeft(2, '0');
    final day = parts[1].padLeft(2, '0');
    final year = parts[2];
    return '$year.$month.$day';
  }
  return date; // Return the original if format is incorrect
}

// Fetch logs by date
Future<List<Map<String, dynamic>>> fetchLogsByDate(String version, String date) async {
  String token = generateToken(getUserResponse['id'].toString());
  // Convert date format before sending
  final formattedDate = convertDateToRequiredFormat(date);
  final url = '$apiBaseUrl/log?version=$version&date=$formattedDate';
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Custom-Token': token,
        'X-UserId': getUserResponse['id'].toString(),
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      print('Failed to fetch logs');
      return [];
    }
  } catch (e) {
    print('Error fetching logs by date: $e');
    return [];
  }
}

Future<List<Map<String, dynamic>>> fetchLogsBySteamId(String version, String date, String steamId) async {
  String token = generateToken(getUserResponse['id'].toString());
  // Convert date format before sending
  final formattedDate = convertDateToRequiredFormat(date);
  final url = '$apiBaseUrl/log?version=$version&date=$formattedDate&steam_id=$steamId';
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Custom-Token': token,
        'X-UserId': getUserResponse['id'].toString(),
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      print('Failed to fetch logs by Steam ID');
      return [];
    }
  } catch (e) {
    print('Error fetching logs by Steam ID: $e');
    return [];
  }
}



// Ban user
Future<void> banUser(String steamId, String reason, String server) async {
  String token = generateToken(getUserResponse['id'].toString());
  final url = '$apiBaseUrl/ban';
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json',
        'X-Custom-Token': token,
        'X-UserId': getUserResponse['id'].toString(),},
      body: jsonEncode({'steamid': steamId, 'reason': reason, 'server': server}),
    );
    if (response.statusCode == 200) {
      print('User banned successfully');
    } else {
      print('Failed to ban user');
    }
  } catch (e) {
    print('Error banning user: $e');
  }
}

// Unban user
Future<void> unbanUser(String steamId, String server) async {
  String token = generateToken(getUserResponse['id'].toString());
  
  final url = '$apiBaseUrl/unban';
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json',
        'X-Custom-Token': token,
        'X-UserId': getUserResponse['id'].toString(),},
      body: jsonEncode({'steamid': steamId, 'server': server}),
    );
    if (response.statusCode == 200) {
      print('User unbanned successfully');
    } else {
      print('Failed to unban user');
    }
  } catch (e) {
    print('Error unbanning user: $e');
  }
}

// Fetch staff logs from the Flask API
Future<List<dynamic>> fetchStaffLogs({
  required String userId,
  String? logType,
  String? startDate,
  String? endDate,
}) async {
  final Uri url = Uri.parse('$apiBaseUrl/staff/logs').replace(queryParameters: {
    'user_id': userId,
    if (logType != null) 'log_type': logType,
    if (startDate != null) 'start_date': startDate,
    if (endDate != null) 'end_date': endDate,
  });

  String token = generateToken(getUserResponse['id'].toString());

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Custom-Token': token,
        'X-UserId': getUserResponse['id'].toString(),
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch staff logs');
    }
  } catch (e) {
    print('Error fetching staff logs: $e');
    return [];
  }
}

// Sample dashboard items (Can be populated as needed)
Map<String, dynamic> dashboardItems = {};