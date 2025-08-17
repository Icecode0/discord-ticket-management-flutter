import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:newdawn/controllers/tickets_controller.dart';
import 'package:newdawn/pages/admin_ticket_details_page.dart';
import 'package:newdawn/pages/admin_tickets_page.dart';
import 'package:newdawn/pages/bans.dart';
import 'package:newdawn/pages/closed_ticket_detail_page.dart';
import 'package:newdawn/pages/closed_tickets_page.dart';
import 'package:newdawn/pages/economy.dart';
import 'package:newdawn/pages/game_chat.dart';
import 'package:newdawn/pages/home_page.dart';
import 'package:newdawn/pages/ticket_details_page.dart';
import 'package:newdawn/pages/tickets_page.dart';
import 'package:newdawn/pages/upper_staff.dart';
import 'dart:html' as html;
import 'globals.dart' as globals;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  static const String route = '/Dashboard';

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentPageIndex = 0;
  int _previousPageIdex = 0;
  Map<String, dynamic>? _selectedTicket;
  bool _isLoading = true;
  bool showClosed = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await globals.loadStoredData(context);
    await globals.checkStaffLevel(globals.getUserResponse['id'].toString());
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = globals.getHeight(context);
    final double width = globals.getWidth(context);

    bool isPortrait = width < height;

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : isPortrait ? buildMobileView(context) : buildDesktopView(context),
    );
  }

  Widget buildMobileView(BuildContext context) {
    final double height = globals.getHeight(context);
    final double width = globals.getWidth(context);

    return Center(
      child: Container(
        height: height,
        width: width,
        color: const Color.fromARGB(255, 34, 34, 34),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "CenterLogo.png",
              width: width * 0.5,
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Text(
              "Under Construction",
              style: TextStyle(
                fontFamily: "Anton",
                color: const Color.fromARGB(255, 133, 214, 214),
                fontSize: width * 0.05,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDesktopView(BuildContext context) {
    final double height = globals.getHeight(context);
    final double width = globals.getWidth(context);

    return Center(
      child: Container(
        height: height,
        width: width,
        color: globals.themeUIGrey,
        child: Row(
          children: [
            // Sidebar
            Container(
              color: const Color.fromARGB(255, 19, 22, 27),
              width: width * 0.13,
              child: Column(
                children: [
                  Image.asset(
                    "HeaderLogo.png",
                    height: height * 0.05,
                  ),
                  SizedBox(height: height * 0.05),
                  buildSidebarButton(context, Icons.home, "Home", 0),
                  SizedBox(height: height * 0.05),
                  buildSidebarButton(context, Icons.report_gmailerrorred_outlined, "Tickets", 1),
                  if (globals.isStaff) ...[
                    SizedBox(height: height * 0.05),
                    buildSidebarButton(context, Icons.block_outlined, "Bans", 2),
                    SizedBox(height: height * 0.05),
                    buildSidebarButton(context, Icons.speaker_notes_outlined, "Chat Logs", 3),
                    SizedBox(height: height * 0.05),
                    buildSidebarButton(context, Icons.savings_outlined, "Economy", 4),
                  ],
                  if (globals.staffLevel == "UpperStaff" || globals.staffLevel == "Management") ...[
                    SizedBox(height: height * 0.05),
                    buildSidebarButton(context, Icons.shield_outlined, "Upper Staff", 7),
                  ],
                ],
              ),
            ),
            // Page Content
            Expanded(
              child: Container(
                color: globals.themeUIGrey,
                child: buildPageContent(_currentPageIndex),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSidebarButton(BuildContext context, IconData icon, String label, int index) {
    final double width = globals.getWidth(context);

    bool isTicketsRelatedPage = _currentPageIndex == 1 || _currentPageIndex == 5 || _currentPageIndex == 6;

    return Column(
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              _currentPageIndex = index;
              _selectedTicket = null;
            });
          },
          child: Row(
            children: [
              Icon(
                icon,
                size: width * 0.015,
              ),
              SizedBox(width: width * 0.005),
              Text(
                label,
                style: TextStyle(
                  fontFamily: "Anton",
                  color: const Color.fromARGB(255, 133, 214, 214),
                  fontSize: width * 0.015,
                ),
              ),
            ],
          ),
        ),
        if (label == "Tickets" && (index == 1 || isTicketsRelatedPage))
          Padding(
            padding: EdgeInsets.only(left: width * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentPageIndex = 1;
                      _selectedTicket = null;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.inbox,
                        size: width * 0.0125,
                      ),
                      SizedBox(width: width * 0.005),
                      Text(
                        "Open Tickets",
                        style: TextStyle(
                          fontFamily: "Anton",
                          color: const Color.fromARGB(255, 133, 214, 214),
                          fontSize: width * 0.0125,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentPageIndex = 5;
                      _selectedTicket = null;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.archive,
                        size: width * 0.0125,
                      ),
                      SizedBox(width: width * 0.005),
                      Text(
                        "Closed Tickets",
                        style: TextStyle(
                          fontFamily: "Anton",
                          color: const Color.fromARGB(255, 133, 214, 214),
                          fontSize: width * 0.0125,
                        ),
                      ),
                    ],
                  ),
                ),
                if (globals.isStaff)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentPageIndex = 6;
                        _selectedTicket = null;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: width * 0.0125,
                        ),
                        SizedBox(width: width * 0.005),
                        Text(
                          "Staff Tickets",
                          style: TextStyle(
                            fontFamily: "Anton",
                            color: const Color.fromARGB(255, 133, 214, 214),
                            fontSize: width * 0.0125,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildPageContent(int pageIndex) {
    final TicketsController controller = Get.put(TicketsController());

    if (pageIndex != _previousPageIdex) {
      print("Allowing Rescan");
      controller.ticketsLoaded.value = false;
    }

    _previousPageIdex = pageIndex;

    if (_selectedTicket != null) {
      switch (pageIndex) {
        case 1:
          return TicketDetailsPage(ticket: _selectedTicket!);
        case 5:
          return closedTicketPage(context, _selectedTicket!);
        case 6:
          return AdminTicketPage(ticket: _selectedTicket!,
          onTicketClosed: () {
            setState(() {
              _selectedTicket = null;
              _currentPageIndex = 6;
            });
          },);
        default:
          return HomePage();
      }
    }

    switch (pageIndex) {
      case 0:
        return HomePage();
      case 1:
        return TicketsPage(
          title: "Opened Tickets",
          onTicketSelected: (ticket) {
            setState(() {
              print("Loading ticket: ${ticket}");
              _selectedTicket = ticket;
              _currentPageIndex = 1;
            });
          },
        );
      case 2:
        return BansPage();
      case 3:
        return gameChatsPage();
      case 4:
        return economyPage(context);
      case 5:
        return ClosedTicketsPage(
          onTicketSelected: (ticket) {
            setState(() {
              _selectedTicket = ticket;
              _currentPageIndex = 5;
            });
          },
        );
      case 6:
        return AdminTicketsPage(
          onTicketSelected: (ticket) {
            setState(() {
              _selectedTicket = ticket;
              _currentPageIndex = 6;
            });
          },
          
        );
      case 7:
        return UpperStaffPage();
      default:
        return HomePage();
    }
  }
}
