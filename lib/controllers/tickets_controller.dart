import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../globals.dart' as globals;
import 'package:newdawn/dashboard.dart' as dash;

enum TicketPageType { TicketsPage, ClosedTicketsPage, AdminsTicketsPage }

class TicketsController extends GetxController {
  var tickets = <dynamic>[].obs; // Observable list for open tickets
  var closedTickets = <dynamic>[].obs; // Observable list for closed tickets
  var isLoading = true.obs; // Loading state
  var showClosed = false.obs; // Toggle for showing closed tickets
  var searchQuery = ''.obs; // Search query
  var chatLog = <Map<String, dynamic>>[].obs; // Observable list for chat log
  var ticket = <String, dynamic>{}.obs; // Observable map for current ticket details
  var messageText = TextEditingController().obs; // Observable TextEditingController for input
  var ticketsLoaded = false.obs; // Observable to track if tickets are already loaded

  @override
  void onInit() {
    super.onInit();
  }

Future<void> fetchTickets(TicketPageType pageType, String userId) async {
    if (ticketsLoaded.value && !showClosed.value) return;

    isLoading.value = true;
    try {
        List<dynamic> fetchedTickets;

        // Fetch tickets based on the page type
        if (pageType == TicketPageType.AdminsTicketsPage) {
            fetchedTickets = await globals.fetchAllTickets();
        } else {
            fetchedTickets = await globals.fetchTicketsByUser(userId);
        }

        final userIds = <String>{globals.getUserResponse['id'].toString()};
        for (var ticket in fetchedTickets) {
            userIds.add(ticket['OpenedBy'].toString());
            if (ticket.containsKey('ClosedBy') && ticket['ClosedBy'] != null) {
                userIds.add(ticket['ClosedBy'].toString());
            }
            if (ticket.containsKey('ChatLog')) {
                for (var chat in ticket['ChatLog']) {
                    userIds.add(chat['Author'].toString());
                }
            }
        }

        // Fetch guild members for all unique user IDs
        await globals.fetchGuildMembers(userIds.toList());

        // Filter tickets based on `showClosed` for StaffTickets only
        List<dynamic> filteredTickets = fetchedTickets;
        if (pageType == TicketPageType.AdminsTicketsPage && !showClosed.value) {
            // Filter out closed tickets; assume tickets without `Closed` are open
            filteredTickets = fetchedTickets.where((ticket) => ticket['Closed'] != true).toList();
        }

        // Sorting and debugging logic: claimed by current user -> unclaimed -> others, then by ticket number
        List<dynamic> sortedTickets = filteredTickets..sort((a, b) {
            final currentUserId = globals.getUserResponse['id'];

            final aIsClaimedByUser = a['ClaimedBy'] == currentUserId;
            final bIsClaimedByUser = b['ClaimedBy'] == currentUserId;

            // Debugging: Print ticket numbers claimed by the current user
            if (aIsClaimedByUser) {
                print("Ticket claimed by current user (a): ${a['ticket_number']}");
            }
            if (bIsClaimedByUser) {
                print("Ticket claimed by current user (b): ${b['ticket_number']}");
            }

            // Determine if tickets are unclaimed, handling null cases
            final aIsUnclaimed = a['ClaimedBy'] == null || (a['ClaimedBy'] is String && a['ClaimedBy'].isEmpty);
            final bIsUnclaimed = b['ClaimedBy'] == null || (b['ClaimedBy'] is String && b['ClaimedBy'].isEmpty);

            // Prioritize claimed by current user first
            if (aIsClaimedByUser && !bIsClaimedByUser) return -1;
            if (!aIsClaimedByUser && bIsClaimedByUser) return 1;

            // Unclaimed tickets come next
            if (aIsUnclaimed && !bIsUnclaimed) return -1;
            if (!aIsUnclaimed && bIsUnclaimed) return 1;

            // Otherwise, sort by ticket number
            return int.parse(a['ticket_number']).compareTo(int.parse(b['ticket_number']));
        });

        // Debugging: Print the list of ticket numbers after sorting
        print("Sorted ticket numbers:");
        for (var ticket in sortedTickets) {
            print("Ticket number: ${ticket['ticket_number']}, ClaimedBy: ${ticket['ClaimedBy']}");
        }

        // Assign sorted tickets to the respective list based on the page type
        if (pageType == TicketPageType.AdminsTicketsPage) {
            tickets.value = sortedTickets;
            closedTickets.clear();
        } else if (pageType == TicketPageType.TicketsPage) {
            tickets.value = sortedTickets.where((ticket) => ticket['Closed'] != true).toList();
            closedTickets.clear();
        } else if (pageType == TicketPageType.ClosedTicketsPage) {
            closedTickets.value = sortedTickets.where((ticket) => ticket['Closed'] == true).toList();
            tickets.clear();
        }

        ticketsLoaded.value = true;
    } catch (e) {
        print("Error fetching tickets: $e");
        tickets.clear();
        closedTickets.clear();
    } finally {
        isLoading.value = false;
    }
}



  void loadTicketDetails(Map<String, dynamic> selectedTicket) {
    ticket.assignAll(selectedTicket);
    chatLog.assignAll((selectedTicket['ChatLog'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>());
  }

  void toggleShowClosed() {
    showClosed.toggle();
    fetchTickets(TicketPageType.AdminsTicketsPage, globals.getUserResponse['id'].toString());
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterTickets();
  }

  void sortTickets() {
    tickets.sort((a, b) => int.parse(a['ticket_number']).compareTo(int.parse(b['ticket_number'])));
    closedTickets.sort((a, b) => int.parse(a['ticket_number']).compareTo(int.parse(b['ticket_number'])));
  }

  void filterTickets() {
    final filteredTickets = tickets.where((ticket) =>
        (showClosed.value || ticket['Closed'] == false) &&
        (searchQuery.isEmpty ||
            ticket['OpenedBy'].toString().contains(searchQuery.value) ||
            (ticket['SteamId'] != null && ticket['SteamId'].toString().contains(searchQuery.value)))).toList();
    tickets.assignAll(filteredTickets);
  }

  Future<void> sendMessage(String ticketNumber) async {
    if (messageText.value.text.isEmpty) return;

    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final content = messageText.value.text;

    await globals.sendMessage(ticketNumber, content, messageId);

    chatLog.add({
      'Author': globals.getUserResponse['id'],
      'Content': content,
      'Deleted': false,
      'Edited': false,
      'MessageId': messageId,
      'Time': DateTime.now().toIso8601String(),
    });

    messageText.value.clear();
  }

  Future<void> editMessage(String messageId, String newContent) async {
    await globals.editMessage(ticket['ticket_number'], messageId, newContent);

    final index = chatLog.indexWhere((message) => message['MessageId'] == messageId);
    if (index != -1) {
      chatLog[index]['Content'] = newContent;
      chatLog[index]['Edited'] = true;
      chatLog.refresh();  // Refresh the chatLog to trigger UI update
    }
  }

  Future<void> deleteMessage(String messageId) async {
    await globals.deleteMessage(ticket['ticket_number'], messageId);

    final index = chatLog.indexWhere((message) => message['MessageId'] == messageId);
    if (index != -1) {
      chatLog[index]['Deleted'] = true;
      chatLog.refresh();  // Refresh the chatLog to trigger UI update
    }
  }

  Future<void> claimTicket(String ticketNumber) async {
    await globals.claimTicket(ticketNumber);
    
  }

  Future<void> unclaimTicket(String ticketNumber) async {
    await globals.unclaimTicket(ticketNumber);
    await refreshTicket(ticketNumber);
  }

  Future<void> closeTicket(String ticketNumber) async {
    await globals.closeTicket(ticketNumber);
    await refreshTicket(ticketNumber);
  }

  Future<void> refreshTicket(String ticketNumber) async {
    try {
      final updatedTicket = await globals.fetchTicketByNumber(ticketNumber);
      int index = tickets.indexWhere((t) => t['ticket_number'] == ticketNumber);
      if (index != -1) {
        tickets[index] = updatedTicket;
        if (updatedTicket['Closed'] == true) {
          closedTickets.add(updatedTicket);
        } else {
          closedTickets.removeWhere((t) => t['ticket_number'] == ticketNumber);
        }
      }
    } catch (e) {
      print("Error refreshing ticket: $e");
    }
  }
}
