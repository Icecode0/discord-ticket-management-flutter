import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tickets_controller.dart';
import '../globals.dart' as globals;

class AdminTicketPage extends StatelessWidget {
  final TicketsController controller = Get.put(TicketsController());
  final Map<String, dynamic> ticket;
  final Function() onTicketClosed;


  AdminTicketPage({Key? key, required this.ticket, required this.onTicketClosed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            return isPortrait ? buildMobileView(context) : buildDesktopView(context);
          }
        }),
      ),
    );
  }

  Widget buildMobileView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildTicketDetails(context, controller.ticket),
                buildAdminActions(context),
                buildChatLog(controller),
              ],
            ),
          ),
        ),
        buildMessageInput(controller),
      ],
    );
  }

  Widget buildDesktopView(BuildContext context) {
    return Column(
      children: [
        buildTicketDetails(context, controller.ticket),
        buildAdminActions(context),
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
        mainAxisSize: MainAxisSize.min,
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

  Widget buildAdminActions(BuildContext context) {
    final claimedByCurrentUser = ticket['ClaimedBy'] == globals.getUserResponse['id'].toString();
    final isUnclaimed = ticket['ClaimedBy'] == '' || ticket['ClaimedBy'] == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isUnclaimed || claimedByCurrentUser)
            ElevatedButton(
              onPressed: () {
                if (isUnclaimed) {
                  controller.claimTicket(ticket['ticket_number']);
                } else if (claimedByCurrentUser) {
                  controller.unclaimTicket(ticket['ticket_number']);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isUnclaimed ? Colors.green : Colors.orange,
              ),
              child: Text(isUnclaimed ? 'Claim' : 'Unclaim'),
            ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              controller.closeTicket(ticket['ticket_number']);
              onTicketClosed();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Close Ticket'),
          ),
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
                    final member = globals.guildMembers[userId];
                    final avatarUrl = member != null
                        ? 'https://cdn.discordapp.com/avatars/$userId/${member['avatar']}.png?size=64'
                        : null;

                    return ListTile(
                      leading: avatarUrl != null
                          ? CircleAvatar(backgroundImage: NetworkImage(avatarUrl))
                          : CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                        '${member?['username'] ?? 'Unknown User'} ($userId)',
                        style: TextStyle(color: Color.fromARGB(255, 221, 221, 221)),
                      ),
                      subtitle: Text(chat['Content'] ?? '', style: TextStyle(color: const Color.fromARGB(255, 136, 151, 170))),
                      trailing: userId == globals.getUserResponse['id'].toString()
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
                    );
                  },
                )
              : Center(child: Text('No chat logs available', style: TextStyle(color: const Color.fromARGB(255, 136, 151, 170)))),
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
