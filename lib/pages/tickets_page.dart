import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tickets_controller.dart';
import "package:newdawn/globals.dart" as globals;

class TicketsPage extends StatelessWidget {
  final String title;
  final TicketsController controller = Get.put(TicketsController());
  final Function(Map<String, dynamic>) onTicketSelected;

  TicketsPage({Key? key, required this.title, required this.onTicketSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    controller.fetchTickets(TicketPageType.TicketsPage, globals.getUserResponse['id'].toString());

    return Scaffold(
      body: Container(
        color:  globals.themeUIGrey,
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          } else if (controller.tickets.isEmpty) {
            return Center(
              child: Text(
                'No tickets found',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return Column(
              children: [
                // Title and search/filter UI
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: "Anton",
                          color: const Color.fromARGB(255, 133, 214, 214),
                          fontSize: width * 0.03,
                        ),
                      ),
                    ],
                  ),
                ),
                // Ticket List
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = controller.tickets[index];
                      return GestureDetector(
                        onTap: () {
                          
                          // Check if `ticket` is a Map<String, dynamic> before passing it
                          if (ticket is Map<String, dynamic>) {
                            onTicketSelected(ticket); // Trigger callback on tap
                          } else {
                            print("Error: Ticket is not a Map<String, dynamic>");
                          }
                        },
                        child: TicketCard(ticket: ticket, isStaffTickets: title == 'Staff Tickets'),
                      );
                    },
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

class TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final bool isStaffTickets;

  const TicketCard({Key? key, required this.ticket, required this.isStaffTickets}) : super(key: key);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Ticket ${ticket['ticket_number'] ?? 'Unknown'}',
                    style: TextStyle(color: Colors.white, fontSize: width * 0.02, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: width*0.02),
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
            ],
          ),
        ),
      ),
    );
  }
}
