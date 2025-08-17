import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import "package:newdawn/globals.dart" as globals;

class Oauth extends StatefulWidget {
  const Oauth({Key? key}) : super(key: key);

  static const String route = '/Login';

  @override
  State<Oauth> createState() => _OauthState();
}

class _OauthState extends State<Oauth> {
  @override
  void initState() {
    super.initState();

    callToDiscord();

    setState(() {});
  }

  Future<void> callToDiscord() async {
    try {
      globals.discCode = Uri.base.queryParameters["code"]!;
      print("Oauth");
      print(globals.discCode);
      await globals.oauth(globals.discCode);


      if (mounted) {
        GoRouter.of(context).go('/Dashboard');
      }
    } catch (e) {
      print('OAuth process failed: $e');
      // Handle errors appropriately here, such as showing an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during OAuth: $e')),
        );
      }
    }
  }


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
      child: SingleChildScrollView(
        child: globals.userResponse
            ? Container(
                color: globals.themeUIGrey,
                height: height*1.2,
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Username: " + globals.getUserResponse["username"],
                          style: TextStyle(
                            color: globals.themeWhite,
                            fontSize: width * 0.02,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Container(
                color: globals.themeUIGrey,
                height: height,
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('NDLoading.gif', width: width * 0.1),
                    SizedBox(height: height * 0.02),
                    Text(
                      "Loading...",
                      style: TextStyle(
                        color: globals.themeWhite,
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Method to build the mobile view
  Widget buildMobileView(BuildContext context) {
    final double height = globals.getHeight(context);
    final double width = globals.getWidth(context);

    return Center(
      child: SingleChildScrollView(
        child: globals.userResponse
            ? Container(
                color: globals.themeUIGrey,
                height: height*1.2,
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Username: " + globals.getUserResponse["username"],
                          style: TextStyle(
                            color: globals.themeWhite,
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Container(
                color: globals.themeUIGrey,
                height: height,
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('NDLoading.gif', width: width * 0.3),
                    SizedBox(height: height * 0.05),
                    Text(
                      "Loading...",
                      style: TextStyle(
                        color: globals.themeWhite,
                        fontSize: width * 0.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}