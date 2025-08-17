import 'package:flutter/material.dart';
import 'dart:html' as html; // For opening evidence links in a new tab
import '../globals.dart' as globals;

Widget closedTicketPage(BuildContext context, Map<String, dynamic> ticket) {
  final double height = MediaQuery.of(context).size.height;
  final double width = MediaQuery.of(context).size.width;

  return Scaffold(
    body: Container(
      color: globals.themeUIGrey,
      child: Column(
        children: [
          // Ticket details container
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: globals.themeUIGrey,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ticket Type: ${ticket['TicketType'] ?? 'Non-Website'}",
                  style: TextStyle(color: Colors.white, fontSize: width * 0.015),
                ),
                SizedBox(height: height * 0.01),
                Text(
                  "Reason: ${ticket['Reason'] ?? 'No reason provided'}",
                  style: TextStyle(color: Colors.white, fontSize: width * 0.015),
                ),
                SizedBox(height: height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Opened By: ${globals.guildMembers[ticket['OpenedBy'].toString()]?['username'] ?? 'Unknown User'}",
                      style: TextStyle(color: Colors.white, fontSize: width * 0.015),
                    ),
                    SizedBox(width: width * 0.02),
                    Text(
                      "Opened On: ${ticket['OpenTime'] ?? 'No time provided'}",
                      style: TextStyle(color: Colors.white, fontSize: width * 0.015),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.01),
                Text(
                  "Closed On: ${ticket['CloseTime'] ?? 'No time provided'}",
                  style: TextStyle(color: Colors.white, fontSize: width * 0.015),
                ),
                SizedBox(height: height * 0.01),
                if (ticket["EvidenceLinks"] != null && ticket["EvidenceLinks"].isNotEmpty) ...[
                  Text(
                    "Evidence Links:",
                    style: TextStyle(color: Colors.white, fontSize: width * 0.015),
                  ),
                  ...ticket["EvidenceLinks"].map<Widget>((link) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                      child: GestureDetector(
                        onTap: () {
                          html.window.open(link, '_blank'); // Open link in a new tab
                        },
                        child: Text(
                          link,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                            fontSize: width * 0.015,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
          SizedBox(height: 10),
          // Chat log
          Expanded(
            child: ticket['ChatLog'] != null && ticket['ChatLog'].isNotEmpty
                ? ListView.builder(
                    itemCount: ticket['ChatLog'].where((chat) => !chat['Deleted']).length,
                    itemBuilder: (context, index) {
                      final filteredChatLog = ticket['ChatLog'].where((chat) => !chat['Deleted']).toList();
                      final chat = filteredChatLog[index];
                      final userId = chat['Author'].toString();
                      final member = globals.guildMembers[userId];
                      final avatarUrl = member != null
                          ? 'https://cdn.discordapp.com/avatars/$userId/${member['avatar']}.png?size=64'
                          : null;

                      return ListTile(
                        leading: avatarUrl != null
                            ? CircleAvatar(backgroundImage: NetworkImage(avatarUrl))
                            : CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                        title: Text(
                          '${member != null ? member['username'] : 'Unknown User'} ($userId)',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          chat['Content'] ?? '',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'No chat logs available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
          )

        ],
      ),
    ),
  );
}
