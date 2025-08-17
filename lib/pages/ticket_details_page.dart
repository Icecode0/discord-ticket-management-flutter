import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../globals.dart' as globals;
import '../controllers/tickets_controller.dart';

class TicketDetailsPage extends StatelessWidget {
  final Map<String, dynamic> ticket;

  TicketDetailsPage({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TicketsController controller = Get.find<TicketsController>();
    controller.loadTicketDetails(ticket);

    final width = MediaQuery.of(context).size.width;
    final isPortrait = width < MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 22, 27, 33),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          } else {
            return isPortrait ? buildMobileView(context, controller) : buildDesktopView(context, controller);
          }
        }),
      ),
    );
  }

  Widget buildMobileView(BuildContext context, TicketsController controller) {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildTicketDetails(context, controller.ticket),
          buildChatLog(controller),
          buildMessageInput(controller),
        ],
      ),
    );
  }

  Widget buildDesktopView(BuildContext context, TicketsController controller) {
    return Column(
      children: [
        buildTicketDetails(context, controller.ticket),
        Expanded(
          flex: 1,
          child: buildChatLog(controller),
        ),
        buildMessageInput(controller),
      ],
    );
  }

  Widget buildTicketDetails(BuildContext context, Map<String, dynamic> ticket) {
    final double width = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: globals.themeUIGrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Reason: ${ticket['Reason'] ?? 'No reason provided'}",
                  style: TextStyle(color: Colors.white, fontSize: width * 0.015),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  "Opened By: ${globals.guildMembers[ticket['OpenedBy']?.toString()]?['username'] ?? ticket['OpenedBy']}",
                  style: TextStyle(color: Colors.white, fontSize: width * 0.015),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  "Open Time: ${ticket['OpenTime'] ?? 'No time provided'}",
                  style: TextStyle(color: Colors.white, fontSize: width * 0.015),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "Steam ID: ${ticket['SteamId'] ?? 'No Steam ID provided'}",
            style: TextStyle(color: Colors.white, fontSize: width * 0.015),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Location: ${ticket['Location'] ?? 'No location provided'}",
                  style: TextStyle(color: Colors.white, fontSize: width * 0.015),
                ),
              ),
              Expanded(
                child: Text(
                  "Timestamp: ${ticket['Timestamp'] ?? 'No timestamp provided'}",
                  style: TextStyle(color: Colors.white, fontSize: width * 0.015),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (ticket['EvidenceLinks'] != null && ticket['EvidenceLinks'].isNotEmpty) ...[
            Text(
              "Evidence Links:",
              style: TextStyle(color: Colors.white, fontSize: width * 0.015),
            ),
            ...ticket['EvidenceLinks'].map<Widget>((link) {
              return Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                child: GestureDetector(
                  onTap: () {
                    // Logic for opening link
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
    );
  }

  Widget buildChatLog(TicketsController controller) {
    return Obx(() => Expanded(
          child: (controller.chatLog ?? []).isNotEmpty
              ? ListView.builder(
                  itemCount: controller.chatLog.where((chat) => !chat['Deleted']).length,
                  itemBuilder: (context, index) {
                    final filteredChatLog = controller.chatLog.where((chat) => !chat['Deleted']).toList();
                    final chat = filteredChatLog[index];
                    final userId = chat['Author'].toString();
                    final isStaffMessage = userId != globals.getUserResponse['id'].toString();
                    final avatarUrl = isStaffMessage
                        ? 'assets/images/LogoCharacter.png'
                        : (globals.guildMembers[userId]?['avatar'] != null
                            ? 'https://cdn.discordapp.com/avatars/$userId/${globals.guildMembers[userId]!['avatar']}.png?size=64'
                            : null);
                    final username = isStaffMessage ? "ND Staff" : globals.guildMembers[userId]?['username'] ?? 'Unknown User';

                    return Container(
                      color: globals.themeUIGrey,
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      child: ListTile(
                        leading: avatarUrl != null
                            ? CircleAvatar(backgroundImage: isStaffMessage ? AssetImage("LogoCharacter.png") : NetworkImage(avatarUrl))
                            : CircleAvatar(child: Icon(Icons.person, color: Colors.white)),
                        title: Text(
                          username,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          chat['Content'] ?? '',
                          style: TextStyle(color: Colors.grey),
                        ),
                        trailing: !isStaffMessage
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.yellow),
                                    onPressed: () {
                                      controller.messageText.value.text = chat['Content'];
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Edit Message'),
                                            content: TextField(
                                              controller: controller.messageText.value,
                                              decoration: InputDecoration(hintText: "Edit your message"),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  controller.editMessage(chat['MessageId'], controller.messageText.value.text);
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Save'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      controller.deleteMessage(chat['MessageId']);
                                    },
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                )
              : Center(child: Text('No chat logs available', style: TextStyle(color: Colors.grey))),
        ));
  }

  Widget buildMessageInput(TicketsController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onEditingComplete: () => controller.sendMessage(controller.ticket['ticket_number']),
              controller: controller.messageText.value,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black54,
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: globals.logoBlue),
            onPressed: () => controller.sendMessage(controller.ticket['ticket_number']),
          ),
        ],
      ),
    );
  }
}
