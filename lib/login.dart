import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'globals.dart' as globals;

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  static const String route = '/Login';

  @override
  Widget build(BuildContext context) {
    final double height = globals.getHeight(context);
    final double width = globals.getWidth(context);

    bool isPortrait = width < height; // Check if the screen is in portrait mode

    return MaterialApp(
      home: Scaffold(
        body: isPortrait ? buildMobileView(context) : buildDesktopView(context),
      ),
    );
  }

  // Method to build the desktop view
  Widget buildDesktopView(BuildContext context) {
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
              width: width * 0.15,
            ),
            Text(
              "Ticket Panel",
              style: TextStyle(
                fontFamily: "Anton",
                color: const Color.fromARGB(255, 133, 214, 214),
                fontSize: width * 0.03,
              ),
            ),
            SizedBox(
              height: height * 0.05,
            ),
            buildLoginButton(context),
          ],
        ),
      ),
    );
  }

  // Method to build the mobile view
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
              width: width * 0.35, // Adjusted for mobile view
            ),
            SizedBox(
              height: height * 0.01,
            ),
            Text(
              "Ticket Panel",
              style: TextStyle(
                fontFamily: "Anton",
                color: const Color.fromARGB(255, 133, 214, 214),
                fontSize: width * 0.07, // Larger font size for mobile
              ),
            ),
            SizedBox(
              height: height * 0.03,
            ),
            buildLoginButton(context),
          ],
        ),
      ),
    );
  }

  // Method to build the login button
  Widget buildLoginButton(BuildContext context) {
    return TextButton(
      onPressed: () async {
        // Redirect to Discord OAuth login
        html.window.open(
          "https://discord.com/oauth2/authorize?client_id=1270870626797883454&response_type=code&redirect_uri=https%3A%2F%2Fa-new-dawn.net%2FProcess_Oauth&scope=identify+guilds+guilds.members.read",
          "_top",
        );
      },
      child: Container(
        height: 50,
        width: 175,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 88, 101, 242),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.discord_outlined,
              color: Colors.white,
            ),
            SizedBox(width: 5),
            Text(
              "Login with Discord",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}