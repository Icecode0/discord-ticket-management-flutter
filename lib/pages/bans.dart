import 'package:flutter/material.dart';
import 'package:newdawn/globals.dart' as globals;

class BansPage extends StatefulWidget {
  @override
  _BansPageState createState() => _BansPageState();
}

class _BansPageState extends State<BansPage> {
  final _steamIdController = TextEditingController();
  final _reasonController = TextEditingController();
  String _selectedServer = 'Legacy';

  bool _isLoading = false;

  // Ban a user
  Future<void> _banUser() async {
    final steamId = _steamIdController.text;
    final reason = _reasonController.text;

    if (steamId.isNotEmpty && reason.isNotEmpty) {
      setState(() => _isLoading = true);
      await globals.banUser(steamId, reason, _selectedServer);
      setState(() => _isLoading = false);
      _showMessage('User banned successfully');
    } else {
      _showMessage('Steam ID and reason are required');
    }
  }

  // Unban a user
  Future<void> _unbanUser() async {
    final steamId = _steamIdController.text;

    if (steamId.isNotEmpty) {
      setState(() => _isLoading = true);
      await globals.unbanUser(steamId, _selectedServer);
      setState(() => _isLoading = false);
      _showMessage('User unbanned successfully');
    } else {
      _showMessage('Steam ID is required');
    }
  }

  // Helper function to show messages
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bans',
          style: TextStyle(
            fontFamily: 'Anton',
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        color: Colors.grey[900],
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _steamIdController,
              decoration: InputDecoration(
                labelText: 'Steam ID',
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Reason',
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              dropdownColor: Colors.grey[850],
              value: _selectedServer,
              items: ['Legacy', 'Deathmatch'].map((String server) {
                return DropdownMenuItem<String>(
                  value: server,
                  child: Text(
                    server,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedServer = value!;
                });
              },
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _banUser,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        child: Text('Ban User'),
                      ),
                      ElevatedButton(
                        onPressed: _unbanUser,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: Text('Unban User'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _steamIdController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}
