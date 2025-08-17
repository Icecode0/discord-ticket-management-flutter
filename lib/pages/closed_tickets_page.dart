import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tickets_controller.dart';
import "package:newdawn/globals.dart" as globals;

class ClosedTicketsPage extends StatelessWidget {
  final TicketsController controller = Get.put(TicketsController());
  final Function(Map<String, dynamic>) onTicketSelected;

  ClosedTicketsPage({Key? key, required this.onTicketSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    controller.fetchTickets(TicketPageType.ClosedTicketsPage, globals.getUserResponse['id'].toString());

    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 22, 27, 33),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          } else if (controller.closedTickets.isEmpty) {
            return Center(
              child: Text(
                'No closed tickets found',
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
                        "Closed Tickets",
                        style: TextStyle(
                          fontFamily: "Anton",
                          color: const Color.fromARGB(255, 133, 214, 214),
                          fontSize: width * 0.03,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.closedTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = controller.closedTickets[index];
                      return GestureDetector(
                        onTap: () => onTicketSelected(ticket),
                        child: ClosedTicketCard(ticket: ticket),
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

class ClosedTicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const ClosedTicketCard({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final String ticketType = ticket['TicketType'] ?? 'Non-Website';

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
                "Opened On: ${ticket['OpenTime'] ?? 'No time provided'}",
                style: TextStyle(color: Colors.grey, fontSize: width * 0.01),
              ),
              SizedBox(height: 4),
              Text(
                "Closed On: ${ticket['CloseTime'] ?? 'No time provided'}",
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
