import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user.dart';

// Updated getMatchups function to return a list of Map<String, dynamic>
Future<List<Map<String, dynamic>>> getMatchups(User user) async {
  final url = Uri.parse('http://localhost:8000/matchups/${user.sleeper_id}');
  final headers = {'Content-Type': 'application/json'};

  final response = await http.get(url, headers: headers);

  return parseMatchups(response.body);
}

// Parse the response JSON and return a list of Map<String, dynamic>
List<Map<String, dynamic>> parseMatchups(String responseBody) {
  final parsed = jsonDecode(responseBody);

  List<Map<String, dynamic>> matchups = [];
  for (var matchup in parsed) {
    matchups.add({
      'league_name': matchup['league_name'],
      'user_name': matchup['user_name'],
      'user_score': matchup['user_score'],
      'opp_name': matchup['opp_name'],
      'opp_score': matchup['opp_score'],
    });
  }

  return matchups;
}

class Dashboard extends StatefulWidget {
  final User user;

  Dashboard({required this.user});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<List<Map<String, dynamic>>>? matchups;

  @override
  void initState() {
    super.initState();
    _refreshMatchups();
  }

  // Function to refresh matchups
  Future<void> _refreshMatchups() async {
    setState(() {
      matchups = getMatchups(widget.user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          margin: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _header(context),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: matchups,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No matchups available.');
                  } else {
                    return _scores(context, snapshot.data!);
                  }
                },
              ),
              ElevatedButton(
                onPressed: _refreshMatchups, // Refresh button
                child: Text('Refresh Scores'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _header(context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Text(
            "Week 1 Matchups",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _scores(context, List<Map<String, dynamic>> matchups) {
    return Expanded(
      child: ListView.builder(
        itemCount: matchups.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(
                'League: ${matchups[index]['league_name']}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${matchups[index]['user_name']}: ${matchups[index]['user_score']}',
                      style: TextStyle(fontSize: 18)),
                  Text(
                      '${matchups[index]['opp_name']}: ${matchups[index]['opp_score']}',
                      style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
