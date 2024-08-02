import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                String email = _emailController.text;
                String password = _passwordController.text;

                if (email == 'giantwolfs@com' && password == '123') {
                  // Successful login, navigate to HomePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                } else {
                  // Invalid credentials
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text('Invalid email or password'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _entries = [];
  List<Map<String, String>> _filteredEntries = [];

  // Google Sheets credentials and spreadsheet ID
  static const _credentials = r'''
    {
     
  "type": "service_account",
  "project_id": "adminplant",
  "private_key_id": "75554c2eed6062eb9fc5eea5a9bfe2132aebbc5a",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC1P8IJmwfL3QA9\njFgzE9IJCqyPCAUyB4cxNvc0A5Wj7IvvjPZs+Ub3syAhkrliXqNyG08fo4rGGbzd\nIm9oN7WJQ3deWehNAoanms6hqDK1QKsFmChiv4Kc3t3YYd7QrpQzPrUj/3L7+xiu\nPt8idEoIq0MXAV5HfrfIqMGikg7RJw9JT2r1gaI0B/4gHO1ZoMkyx0EyHTmxVhtD\nm6Adov77l5nxcdW6OHfpo3soqf+tDZpia0Fn02orsKaMFQPHHHM+SzsY4VQtvg32\nfNZldC3BPhZnChwEat1Kp9i5EyB0SwMNRx2ZlqlaWVyKUyZDE9gkZPn1dEoO2WAj\nx9ORqKk1AgMBAAECggEACTWeJGLOOJuYIYh6Cs5dA7yZHANqUCp1whhq4yezeMrS\nKW/eLZdU9c0SOuJ7rPXmFCwzDwZ+TKaOJCZVxtPd04WsEQ08cn1IXkfNbAVh3jfU\n+MnMc4gLmPDyEMaYTb4xJZFwHs4iB4+wp1nmeJe0E1CwbgDRy4wyxm1cuWf2fMYL\nF5La4jjK9DM1X/syBWe+LoQ1IonhfmFprKxEX7id67VhtSAE06Jf9BzfH7MPNg5R\nxL//yElGlrQbgef9W0Yd105SISr/flsVD3hlevYN3/dExI5IeOJxab5MLJM8v8y1\nFmmBPH+7sCdrA5uJ64lURsfUOgSIif1zOy1ter0nmQKBgQD/4xbJe7cR09bJWS8U\nnJ1AR8b3ZbIpCCXcdPeK1uf3J7koVuflgEE8JS6/8MTRBkhcMnVFo/dhQeFK05wh\nx/Wsgaldgzull1mj3Vw0OVDWS/ceX5nwh7vrUJVqZ0Rwncl9pe5OOq9+x4U4MnSk\nOhmpnnISkeX8lKgPO4d5hAxBpwKBgQC1VDxwf9ACOyAEtuUVHgzyEMtsfU+Kae0M\n/AC3VWovAoKLPdip/NVJG0NvX7QQlW6xa6KbpaR2YzjRL/o/Ewa1tu5TF3uAqi6l\nQDkB20yjGnl/WIoTQghoMvuuhYONn/cTFB7fNQHnswgsuImsFLhjtq5Ak+4MZjSa\n0IXMR4cBwwKBgQDHcK/qCkr90iaueJyBbDAEUe16FgFuibM4yNHHnQjfUk62akYE\nUpqFzlVJtNcyM7tiYNGWnd3KKBb4w0YF7lxFQCpJgGeVAQoU9gtPiPzAiiTpv4m0\nN5b4Ka7LaAGn5NOO4y2CO6tdHRVwX6MZ/U7TLXOrlZuz6gmzFarZw1nqMQKBgQCf\nWt8e0wR/4WwbGIysiVNBLMdJmbrcXojoP1N1ywfdNmx5aCnQAhWDAQW7jDTX2iuE\nmp42AVVOgZZ+KJbY9aSQ76n0tg9gnK8PpSg0XIC2Wl7qLmpx0DdJM30B++4H+cwO\nJUGYUaJR+IG3o5nB9Bez8eijch3jIbMbVyQuybF5NwKBgQC9NI0cKKcI0moG4iOX\noI/FmoesaWGdEOih/cwxcHgU5tA1n1BdmT/ksx8tadvY9lZgbPbd8iOH4ctqmcr4\nPFRuikNcWxQGGwUe/oOBnQEjTyoF6m7o1QKp0ICh0MCJw5Odco1gmrx9BT6vgzsB\ntak2Snw1rpHry3wlx3CHTU+CLA==\n-----END PRIVATE KEY-----\n",
  "client_email": "adminplant@adminplant.iam.gserviceaccount.com",
  "client_id": "106547054241153517398",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/adminplant%40adminplant.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
    }
    ''';
  static const _spreadsheetId =
      '1Mlvz7FSJiTHhhM2RwUlfbLEXMOOL9EdNd_DSBeUR-Jc'; // Replace with your actual spreadsheet ID

  GSheets _gsheets = GSheets(_credentials);
  Worksheet? _worksheet;

  @override
  void initState() {
    super.initState();
    _fetchDataFromGoogleSheet();
  }

  Future<void> _fetchDataFromGoogleSheet() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Sheet1');

    if (_worksheet != null) {
      final List<List<String>> rows = await _worksheet!.values.allRows();
      if (rows.isNotEmpty) {
        setState(() {
          _entries = rows
              .map((row) => {
                    'title': row.length > 0 ? row[0] : '',
                    'text': row.length > 1 ? row[1] : '',
                  })
              .toList();
          _filteredEntries = List.from(
              _entries); // Initialize filtered entries with all entries
        });
      } else {
        // Handle case where no rows are fetched
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data found in Google Sheet')),
        );
      }
    } else {
      // Handle case where sheet is not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sheet not found')),
      );
    }
  }

  void _searchEntries(String query) {
    setState(() {
      _filteredEntries = _entries
          .where((entry) =>
              entry['title']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _addEntry() async {
    String title = _titleController.text;
    String text = _textController.text;

    if (_worksheet != null) {
      await _worksheet!.values.appendRow([title, text]);

      setState(() {
        _entries.add({
          'title': title,
          'text': text,
        });

        _filteredEntries = List.from(_entries); // Update filtered entries
      });

      // Clear text fields after adding entry
      _titleController.clear();
      _textController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Worksheet not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      labelText: 'Text',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _addEntry,
                  child: Text('Add'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _searchController,
              onChanged: _searchEntries,
              decoration: InputDecoration(
                labelText: 'Search by Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredEntries.length,
                itemBuilder: (context, index) {
                  final entry = _filteredEntries[index];
                  return ListTile(
                    title: Text(entry['title'] ?? ''),
                    subtitle: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(entry['text'] ?? ''),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
