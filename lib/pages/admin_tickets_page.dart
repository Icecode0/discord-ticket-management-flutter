import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tickets_controller.dart';
import 'package:newdawn/globals.dart' as globals;

class AdminTicketsPage extends StatelessWidget {
  final TicketsController controller = Get.put(TicketsController());
  final Function(Map<String, dynamic>) onTicketSelected;
  final ScrollController _scrollController = ScrollController();


  AdminTicketsPage({Key? key, required this.onTicketSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.fetchTickets(TicketPageType.AdminsTicketsPage, globals.getUserResponse['id'].toString());
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color:  globals.themeUIGrey,
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          } else if (controller.tickets.isEmpty) {
            return Center(
              child: Text(
                'No staff tickets found',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        "Staff Tickets",
                        style: TextStyle(
                          fontFamily: "Anton",
                          color: const Color.fromARGB(255, 133, 214, 214),
                          fontSize: width * 0.03,
                        ),
                      ),
                      Spacer(),
                      Checkbox(
                        value: controller.showClosed.value,
                        onChanged: (bool? value) {
                          controller.showClosed.value = value ?? false;
                          controller.fetchTickets(TicketPageType.AdminsTicketsPage, globals.getUserResponse['id'].toString());
                        },
                      ),
                      Text(
                        "Show Closed",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Container(
                        width: width * 0.3,
                        child: TextField(
                          onChanged: (query) => controller.updateSearchQuery(query),
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.black54,
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RawScrollbar(
                    thumbColor: Colors.white,
                    controller: _scrollController, // Attach the controller to the Scrollbar
                    thumbVisibility: true, // Always show the scrollbar thumb
                    child: ListView.builder(
                      controller: _scrollController, // Attach the controller to the ListView
                      itemCount: controller.tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = controller.tickets[index];
                        return GestureDetector(
                          onTap: () => onTicketSelected(ticket),
                          child: AdminTicketCard(ticket: ticket),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}


class AdminTicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const AdminTicketCard({Key? key, required this.ticket}) : super(key: key);

  // Method to determine the ticket's status color and icon
  Widget buildStatusIcon() {
    Color statusColor;
    IconData iconData;

    if (ticket['Closed'] == true) {
      statusColor = Colors.red;
      iconData = Icons.check_circle; // Closed icon
    } else if (ticket['ClaimedBy'] != null && ticket['ClaimedBy'] != '') {
      statusColor = Colors.blue;
      iconData = Icons.person; // Claimed icon
    } else {
      statusColor = Colors.yellow;
      iconData = Icons.circle_outlined; // Unclaimed icon
    }

    return CircleAvatar(
      backgroundColor: statusColor,
      child: Icon(iconData, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final String ticketType = ticket['TicketType'] ?? 'Non-Website';
    final bool isClosed = ticket['Closed'] ?? false;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 28, 29, 31),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Status icon on the left
              buildStatusIcon(),
              SizedBox(width: 8),
              // Ticket details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Ticket ${ticket['ticket_number'] ?? 'Unknown'}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * 0.02,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: width * 0.025),
                        Text(
                          "Opened By: ${ticket['OpenedByUsername'] ?? globals.guildMembers[ticket['OpenedBy']]?['username']}",
                          style: TextStyle(color: Colors.grey, fontSize: width * 0.01),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Ticket Type: $ticketType",
                      style: TextStyle(color: Colors.grey, fontSize: width * 0.01),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Reason: ${ticket['Reason'] ?? 'No reason provided'}",
                      style: TextStyle(color: Colors.grey, fontSize: width * 0.01),
                    ),
                    SizedBox(height: 4),
                    if (isClosed) ...[
                      Text(
                        "Closed By: ${ticket['ClosedByUsername'] ?? 'Unknown User'}",
                        style: TextStyle(color: Colors.grey, fontSize: width * 0.01),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Closed On: ${ticket['CloseTime'] ?? 'No time provided'}",
                        style: TextStyle(color: Colors.grey, fontSize: width * 0.01),
                      ),
                    ],
                    SizedBox(height: 4),
                    Text(
                      "Claimed By: ${globals.guildMembers[ticket['ClaimedBy']]?['username'] ?? 'No staff provided'}",
                      style: TextStyle(color: Colors.grey, fontSize: width * 0.01),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
