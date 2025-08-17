import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newdawn/controllers/logs_controller.dart';

class gameChatsPage extends StatefulWidget {
  @override
  _gameChatsPageState createState() => _gameChatsPageState();
}

class _gameChatsPageState extends State<gameChatsPage> {
  final _dateController = TextEditingController();
  final _steamIdController = TextEditingController();
  final LogsController logsController = Get.put(LogsController());
  final ScrollController _scrollController = ScrollController();
  String _selectedVersion = 'deathmatch';

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Game Chats',
          style: TextStyle(
            fontFamily: 'Anton',
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.grey[900],
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date (MM.DD.YYYY)',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _steamIdController,
                    decoration: InputDecoration(
                      labelText: 'Steam ID',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  dropdownColor: Colors.grey[850],
                  value: _selectedVersion,
                  items: ['deathmatch', 'legacy'].map((String version) {
                    return DropdownMenuItem<String>(
                      value: version,
                      child: Text(
                        version[0].toUpperCase() + version.substring(1),
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedVersion = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final date = _dateController.text;
                final steamId = _steamIdController.text;
                if (date.isNotEmpty || steamId.isNotEmpty) {
                  logsController.fetchLogs(
                    version: _selectedVersion,
                    date: date.isNotEmpty ? date : null,
                    steamId: steamId.isNotEmpty ? steamId : null,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a Date or Steam ID')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: Text('Fetch Logs'),
            ),
            SizedBox(height: 20),

            // Display Results using Obx with a Scrollbar
            Obx(() {
              return logsController.isLoading.value
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    )
                  : Expanded(
                      child: RawScrollbar(
                        thumbColor: Colors.white,
                        controller: _scrollController, // Attach the controller to the Scrollbar
                        thumbVisibility: true, // Always show the scrollbar thumb
                        thickness: 8.0,
                        radius: Radius.circular(10),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: logsController.logResults.length,
                          itemBuilder: (context, index) {
                            final log = logsController.logResults[index];
                            return LogItemWidget(log: log, width: width);
                          },
                        ),
                      ),
                    );
            }),
          ],
        ),
      ),
    );
  }
}


// Custom widget to display each log entry with a styled container
class LogItemWidget extends StatelessWidget {
  final Map<String, dynamic> log;
  final double width;

  const LogItemWidget({
    Key? key,
    required this.log,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[700],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username and LogTime
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                log['Username'] ?? 'Unknown User',
                style: TextStyle(
                  fontSize: width * 0.01,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                log['LogTime'] ?? 'Unknown Time',
                style: TextStyle(
                  fontSize: width * 0.0075,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),

          // Channel and Message
          Text(
            '${log['Channel'] ?? 'Global'}: ${log['Message'] ?? ''}',
            style: TextStyle(
              fontSize: width * 0.0075,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
