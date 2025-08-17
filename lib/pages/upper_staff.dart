import 'package:flutter/material.dart';
import 'package:newdawn/controllers/adminLogs_controller.dart';
import "package:newdawn/globals.dart" as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';

class UpperStaffPage extends StatefulWidget {
  @override
  _UpperStaffPageState createState() => _UpperStaffPageState();
}

class _UpperStaffPageState extends State<UpperStaffPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _logUserIdController = TextEditingController();
  final TextEditingController _logTypeController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  final AdminLogsController logsController = Get.put(AdminLogsController());
  String _statusMessage = '';

  // Fetch logs on page load with default search
  @override
  void initState() {
    super.initState();
    logsController.fetchLogs();
  }



  @override
  Widget build(BuildContext context) {
    
    final double height = globals.getHeight(context);
    final double width = globals.getWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Upper Staff",
          style: TextStyle(fontFamily: "Anton", color: const Color.fromARGB(255, 133, 214, 214), fontSize: width * 0.03),
        ),
        backgroundColor: const Color.fromARGB(255, 28, 29, 31),
      ),
      body: Container(
        color: globals.themeUIGrey,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildAdminSection(width, height),
            SizedBox(height: height * 0.04),
            buildLogSearchSection(context, width, height),
            Expanded(child: buildLogResultsSection()),
          ],
        ),
      ),
    );
  }

  Widget buildAdminSection(double width, double height) {
    return Column(
      children: [
        Text(
          "Manage Staff",
          style: TextStyle(color: Colors.white, fontSize: width * 0.02, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: height * 0.02),
        TextField(
          controller: _userIdController,
          decoration: InputDecoration(
            labelText: "Enter User ID",
            labelStyle: TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(),
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: addAdmin, child: Text("Add Admin"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green)),
            SizedBox(width: width * 0.05),
            ElevatedButton(onPressed: removeAdmin, child: Text("Remove Admin"), style: ElevatedButton.styleFrom(backgroundColor: Colors.red)),
          ],
        ),
        SizedBox(height: height * 0.03),
        Text(_statusMessage, style: TextStyle(color: Colors.white, fontSize: width * 0.02)),
      ],
    );
  }

  Widget buildLogSearchSection(BuildContext context, double width, double height) {
    return Column(
      children: [
        Text(
          "Admin Logs Viewer",
          style: TextStyle(color: Colors.white, fontSize: width * 0.02, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: height * 0.02),
        Row(
          children: [
            Expanded(child: buildTextField(_logUserIdController, "User ID")),
            SizedBox(width: 8),
            Expanded(child: buildTextField(_logTypeController, "Log Type")),
            SizedBox(width: 8),
            Expanded(child: buildTextField(_startDateController, "Start Date (YYYY-MM-DD)")),
            SizedBox(width: 8),
            Expanded(child: buildTextField(_endDateController, "End Date (YYYY-MM-DD)")),
          ],
        ),
        SizedBox(height: height * 0.02),
        ElevatedButton(
          onPressed: () => logsController.fetchLogs(
            userId: _logUserIdController.text,
            logType: _logTypeController.text,
            startDate: _startDateController.text,
            endDate: _endDateController.text,
          ),
          child: Text("Search Logs"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
        ),
      ],
    );
  }

  TextField buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(),
      ),
      style: TextStyle(color: Colors.white),
    );
  }

  Widget buildLogResultsSection() {
    return Obx(() {
      if (logsController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      } else if (logsController.logs.isEmpty) {
        return Center(child: Text("No logs found", style: TextStyle(color: Colors.grey)));
      } else {
        return ListView.builder(
          itemCount: logsController.logs.length,
          itemBuilder: (context, index) {
            return LogsListWidget(log: logsController.logs[index]);
          },
        );
      }
    });
  }

  Future<void> addAdmin() async { /* Add admin logic as before */ }
  Future<void> removeAdmin() async { /* Remove admin logic as before */ }
}


class LogsListWidget extends StatelessWidget {
  final Map<String, dynamic> log;

  const LogsListWidget({Key? key, required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "User: ${globals.guildMembers[log["userId"].toString()]?['username'] ?? log["userId"].toString()}",
                style: TextStyle(color: Colors.grey, fontSize: width * 0.015),
              ),
            ],
          ),
          buildLogDetail("Log Type", log["logType"].toString(), width),
          buildLogDetail("Description", log["logDesc"].toString(), width),
          buildLogDetail("Date", log["date"].toString(), width),
          buildLogDetail("Affected User", log["affUser"]?.toString() ?? "N/A", width),
        ],
      ),
    );
  }

  Widget buildLogDetail(String label, String value, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: width * 0.01)),
          Text(value, style: TextStyle(color: Colors.white, fontSize: width * 0.01)),
        ],
      ),
    );
  }
}

