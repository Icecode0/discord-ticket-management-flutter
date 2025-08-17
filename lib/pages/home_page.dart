import 'package:flutter/material.dart';
import '../globals.dart' as globals; // Adjust the import path as needed

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double height = globals.getHeight(context);
    final double width = globals.getWidth(context);

    String userId = globals.getUserResponse['id'];
    String avatarHash = globals.getUserResponse['avatar'];
    String globalName = globals.getUserResponse['global_name'];

    // Construct the avatar URL using Discord's CDN
    String avatarUrl = 'https://cdn.discordapp.com/avatars/$userId/$avatarHash.png?size=1024';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circle Avatar with Discord Profile Picture
          CircleAvatar(
            radius: width * 0.1, // Adjust the size as needed
            backgroundImage: NetworkImage(avatarUrl),
            backgroundColor: Colors.transparent,
          ),
          SizedBox(height: height * 0.02),
          // Display the global_name beneath the avatar
          Text(
            globalName,
            style: TextStyle(
              color: globals.themeWhite,
              fontSize: width * 0.05, // Adjust the font size as needed
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: height * 0.05), // Add spacing between name and buttons

          // Row containing the two containers
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildReportButton(context, "Survival/DM\nReport", Colors.blue, Icons.warning, globals.themeWhite, globals.themeWhite, () {
                _showSubmitReportDialog(context);
              }),
              SizedBox(width: width * 0.025), // Add spacing between the containers

              _buildReportButton(context, "Discord\nReport", Colors.purple, Icons.report, globals.themeWhite, globals.themeWhite, () {
                _showSubmitDiscordReportDialog(context);
              }),

              SizedBox(width: width * 0.025), // Add spacing between the containers

              _buildReportButton(context, "Make an\nAppeal", Colors.red, Icons.campaign, globals.themeWhite, globals.themeWhite, () {
                _showSubmitAppealDialog(context);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget popupModalButton({
  required BuildContext context, // Pass context here
  required String text,
  required Color buttonColor,
  required VoidCallback onPress,
  double widthFactor = 0.1, // Adjust the width factor as needed
}) {
  return GestureDetector(
    onTap: onPress,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: MediaQuery.of(context).size.width * widthFactor, // Now it has access to context
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}


  Widget popupModalTextLine({
    required String title,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required BuildContext context,
    bool showError = false,
    int maxLines = 1, // Default is a single-line text field
    int maxLength = 1000, // Default max length is 1000 characters, can be overridden
  }) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: width * 0.015,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showError)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Required',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: height * 0.01),
            Row(
              children: [
                Icon(icon, color: Colors.grey),
                SizedBox(width: width * 0.01),
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: maxLines,
                    maxLength: maxLength,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: hint,
                      border: OutlineInputBorder(),
                      counterText: '', // Hide the default counter
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${controller.text.length}/$maxLength',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
          ],
        );
      },
    );
  }

  Widget dynamicTextField({
    required TextEditingController controller,
    required VoidCallback onRemove,
    bool isRemovable = true,
    bool showError = false,
    double widthFactor = 0.8, // Adjust this as needed
  }) {
    return Builder(
      builder: (context) {
        final double width = MediaQuery.of(context).size.width * widthFactor;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isRemovable)
                  IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: onRemove,
                  ),
                if (isRemovable) SizedBox(width: width * 0.01),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Enter evidence link',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            if (showError)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Required',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 10), // Spacing between fields
          ],
        );
      },
    );
  }

  // Helper method to create a report button
  Widget _buildReportButton(BuildContext context, String title, Color color, IconData icon, Color textColor, Color iconColor, VoidCallback onPressed) {
    final double height = globals.getHeight(context);
    final double width = globals.getWidth(context);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.04),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: width * 0.05),
            SizedBox(height: height * 0.01),
            Text(
              title,
              style: TextStyle(color: textColor, fontSize: width * 0.03, height: 0.9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

    Future<void> _showSubmitReportDialog(BuildContext context) async {
    final TextEditingController reasonController = TextEditingController();
    final TextEditingController steamIdController = TextEditingController();
    final TextEditingController timestampController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    List<TextEditingController> evidenceControllers = [TextEditingController()];
    List<bool> evidenceErrors = [false];

    bool showReasonError = false;
    bool showSteamIdError = false;
    bool showTimestampError = false;
    bool showLocationError = false;

    void addEvidenceField(StateSetter setState) {
      setState(() {
        if (evidenceControllers.length < 3) {
          evidenceControllers.add(TextEditingController());
          evidenceErrors.add(false);
        }
      });
    }

    void removeEvidenceField(int index, StateSetter setState) {
      setState(() {
        if (evidenceControllers.length > 1) {
          evidenceControllers.removeAt(index);
          evidenceErrors.removeAt(index);
        }
      });
    }

    void validateAndSubmit(StateSetter setState) {
      setState(() {
        showReasonError = reasonController.text.isEmpty;
        showSteamIdError = steamIdController.text.isEmpty;
        showTimestampError = timestampController.text.isEmpty;
        showLocationError = locationController.text.isEmpty;

        for (int i = 0; i < evidenceControllers.length; i++) {
          evidenceErrors[i] = evidenceControllers[i].text.isEmpty;
        }
      });

      if (!showReasonError &&
          !showSteamIdError &&
          !showTimestampError &&
          !showLocationError &&
          evidenceErrors.every((error) => !error)) {
        globals.submitTicket(
          reason: reasonController.text,
          steamId: steamIdController.text,
          evidence: evidenceControllers.map((controller) => controller.text).toList(),
          ticketType: 'inGame',
          timestamp: timestampController.text,
          location: locationController.text,
        );
        Navigator.of(context).pop();
      }
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return AlertDialog(
              title: Center(
                child: Text(
                  'Submit In-Game Report',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.02,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 0.35,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      popupModalTextLine(
                        title: "Reason",
                        hint: "Enter the reason",
                        controller: reasonController,
                        icon: Icons.report_problem,
                        showError: showReasonError,
                        context: context,
                        maxLines: 4,
                        maxLength: 400,
                      ),
                      popupModalTextLine(
                        title: "Steam ID",
                        hint: "Enter your Steam ID",
                        controller: steamIdController,
                        icon: Icons.person,
                        showError: showSteamIdError,
                        context: context,
                        maxLength: 17,
                      ),
                      Row(
                        children: [
                          Text(
                            "Evidence Link(s)",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width * 0.015,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          if (evidenceControllers.length < 3)
                            IconButton(
                              icon: Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () => addEvidenceField(setState),
                            ),
                        ],
                      ),
                      ...List.generate(evidenceControllers.length, (index) {
                        return dynamicTextField(
                          controller: evidenceControllers[index],
                          onRemove: () => removeEvidenceField(index, setState),
                          isRemovable: index != 0,
                          showError: evidenceErrors[index],
                        );
                      }),
                      popupModalTextLine(
                        title: "Timestamp",
                        hint: "Enter the timestamp",
                        controller: timestampController,
                        icon: Icons.access_time,
                        showError: showTimestampError,
                        context: context,
                        maxLength: 12,
                      ),
                      popupModalTextLine(
                        title: "Location",
                        hint: "Enter the location",
                        controller: locationController,
                        icon: Icons.location_on,
                        showError: showLocationError,
                        context: context,
                        maxLength: 50,
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    popupModalButton(
                      context: context,
                      text: 'Cancel',
                      buttonColor: Colors.red,
                      onPress: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    popupModalButton(
                      context: context,
                      text: 'Submit',
                      buttonColor: Colors.green,
                      onPress: () => validateAndSubmit(setState),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

    Future<void> _showSubmitDiscordReportDialog(BuildContext context) async {
    final TextEditingController reasonController = TextEditingController();
    final TextEditingController discordIdController = TextEditingController();
    final TextEditingController offenderDiscordIdController = TextEditingController();
    List<TextEditingController> evidenceControllers = [TextEditingController()];
    List<bool> evidenceErrors = [false];

    bool showReasonError = false;
    bool showDiscordIdError = false;
    bool showOffenderDiscordIdError = false;

    void addEvidenceField(StateSetter setState) {
      if (evidenceControllers.length < 3) {
        setState(() {
          evidenceControllers.add(TextEditingController());
          evidenceErrors.add(false);
        });
      }
    }

    void removeEvidenceField(int index, StateSetter setState) {
      if (evidenceControllers.length > 1) {
        setState(() {
          evidenceControllers.removeAt(index);
          evidenceErrors.removeAt(index);
        });
      }
    }

    void validateAndSubmit(StateSetter setState) {
      setState(() {
        showReasonError = reasonController.text.isEmpty;
        showDiscordIdError = discordIdController.text.isEmpty;
        showOffenderDiscordIdError = offenderDiscordIdController.text.isEmpty;

        for (int i = 0; i < evidenceControllers.length; i++) {
          evidenceErrors[i] = evidenceControllers[i].text.isEmpty;
        }
      });

      if (!showReasonError &&
          !showDiscordIdError &&
          !showOffenderDiscordIdError &&
          evidenceErrors.every((error) => !error)) {
        globals.submitTicket(
          reason: reasonController.text,
          steamId: discordIdController.text,
          evidence: evidenceControllers.map((controller) => controller.text).toList(),
          ticketType: 'discord',
          offenderDiscordId: int.parse(offenderDiscordIdController.text), // Send offender Discord ID
        );
        Navigator.of(context).pop();
      }
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return AlertDialog(
              title: Center(
                child: Text(
                  'Submit Discord Report',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.02,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.3,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      popupModalTextLine(
                        title: "Reason",
                        hint: "Enter the reason",
                        controller: reasonController,
                        icon: Icons.report,
                        showError: showReasonError,
                        context: context,
                        maxLines: 4,
                        maxLength: 400,
                      ),
                      popupModalTextLine(
                        title: "Your Discord ID",
                        hint: "Enter your Discord ID",
                        controller: discordIdController,
                        icon: Icons.person,
                        showError: showDiscordIdError,
                        context: context,
                        maxLength: 19,
                      ),
                      popupModalTextLine(
                        title: "Offender Discord ID", // New Field
                        hint: "Enter Offender's Discord ID",
                        controller: offenderDiscordIdController,
                        icon: Icons.person,
                        showError: showOffenderDiscordIdError, // New error flag
                        context: context,
                        maxLength: 19,
                      ),
                      Row(
                        children: [
                          Text(
                            "Evidence Link(s)",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width * 0.015,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          if (evidenceControllers.length < 3)
                            IconButton(
                              icon: Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () => addEvidenceField(setState),
                            ),
                        ],
                      ),
                      ...List.generate(evidenceControllers.length, (index) {
                        return dynamicTextField(
                          controller: evidenceControllers[index],
                          onRemove: () => removeEvidenceField(index, setState),
                          isRemovable: index != 0,
                          showError: evidenceErrors[index],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    popupModalButton(
                      context: context,
                      text: 'Cancel',
                      buttonColor: Colors.red,
                      onPress: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    popupModalButton(
                      context: context,
                      text: 'Submit',
                      buttonColor: Colors.green,
                      onPress: () => validateAndSubmit(setState),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }



  Future<void> _showSubmitAppealDialog(BuildContext context) async {
    final TextEditingController reasonController = TextEditingController();
    final TextEditingController steamIdController = TextEditingController();
    final TextEditingController timestampController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    List<TextEditingController> evidenceControllers = [TextEditingController()];
    List<bool> evidenceErrors = [false];

    bool showReasonError = false;
    bool showSteamIdError = false;

    void addEvidenceField(StateSetter setState) {
      if (evidenceControllers.length < 3) {
        setState(() {
          evidenceControllers.add(TextEditingController());
          evidenceErrors.add(false);
        });
      }
    }

    void removeEvidenceField(int index, StateSetter setState) {
      if (evidenceControllers.length > 1) {
        setState(() {
          evidenceControllers.removeAt(index);
          evidenceErrors.removeAt(index);
        });
      }
    }

    void validateAndSubmit(StateSetter setState) {
      setState(() {
        showReasonError = reasonController.text.isEmpty;
        showSteamIdError = steamIdController.text.isEmpty;

        for (int i = 0; i < evidenceControllers.length; i++) {
          evidenceErrors[i] = evidenceControllers[i].text.isEmpty;
        }
      });

      if (!showReasonError && !showSteamIdError && evidenceErrors.every((error) => !error)) {
        globals.submitTicket(
          reason: reasonController.text,
          steamId: steamIdController.text,
          evidence: evidenceControllers.map((controller) => controller.text).toList(),
          ticketType: 'appeal',
          timestamp: timestampController.text.isEmpty ? "" : timestampController.text,
          location: locationController.text.isEmpty ? "" : locationController.text,
        );
        Navigator.of(context).pop();
      }
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return AlertDialog(
              title: Center(
                child: Text(
                  'Submit Appeal',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.02,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.35,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      popupModalTextLine(
                        title: "Reason",
                        hint: "Enter the reason",
                        controller: reasonController,
                        icon: Icons.report_problem,
                        showError: showReasonError,
                        context: context,
                        maxLines: 4,
                        maxLength: 400,
                      ),
                      popupModalTextLine(
                        title: "Steam ID",
                        hint: "Enter your Steam ID",
                        controller: steamIdController,
                        icon: Icons.person,
                        showError: showSteamIdError,
                        context: context,
                        maxLength: 17,
                      ),
                      Row(
                        children: [
                          Text(
                            "Evidence Link(s)",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width * 0.015,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          if (evidenceControllers.length < 3)
                            IconButton(
                              icon: Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () => addEvidenceField(setState),
                            ),
                        ],
                      ),
                      ...List.generate(evidenceControllers.length, (index) {
                        return dynamicTextField(
                          controller: evidenceControllers[index],
                          onRemove: () => removeEvidenceField(index, setState),
                          isRemovable: index != 0,
                          showError: evidenceErrors[index],
                        );
                      }),
                      popupModalTextLine(
                        title: "Timestamp (Optional)",
                        hint: "Enter the timestamp",
                        controller: timestampController,
                        icon: Icons.access_time,
                        context: context,
                        maxLength: 12,
                      ),
                      popupModalTextLine(
                        title: "Location (Optional)",
                        hint: "Enter the location",
                        controller: locationController,
                        icon: Icons.location_on,
                        context: context,
                        maxLength: 50,
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    popupModalButton(
                      context: context,
                      text: 'Cancel',
                      buttonColor: Colors.red,
                      onPress: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    popupModalButton(
                      context: context,
                      text: 'Submit',
                      buttonColor: Colors.green,
                      onPress: () => validateAndSubmit(setState),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
