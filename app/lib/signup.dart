// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:app/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user.dart';

Future<void> createUser(User user) async {
  final url = Uri.parse('http://127.0.0.1:8000/users/');
  final headers = {'Content-Type': 'application/json'};
  final body = json.encode({
    'username': user.username, // Replace with actual username input
    'email': user.email, // Replace with actual email input
    'password': user.password, // Replace with actual password input
    'sleeper_id': user.sleeper_id,
  });

  http.post(url, headers: headers, body: body);
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState(); // Added constructor
}

class _SignUpPageState extends State<SignUpPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final sleeperIDController = TextEditingController();

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
              _inputField(context),
            ],
          ),
        ),
      ),
    );
  }

  _header(context) {
    return Column(
      children: [
        Text(
          "Sign Up",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text(
          "Mkae sure to include your Sleeper ID!",
          style: TextStyle(
              fontSize: 17, color: const Color.fromARGB(255, 111, 111, 111)),
        ),
      ],
    );
  }

  _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
              hintText: "Username",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              filled: true,
              prefixIcon: Icon(Icons.person)),
        ),
        SizedBox(height: 10),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
              hintText: "Email",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              filled: true,
              prefixIcon: Icon(Icons.person)),
        ),
        SizedBox(height: 10),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(Icons.person),
          ),
          obscureText: true,
        ),
        SizedBox(height: 10),
        TextField(
          controller: sleeperIDController,
          decoration: InputDecoration(
            hintText: "Sleeper ID",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(Icons.person),
          ),
          obscureText: true,
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // Create a User object from the entered data
            final user = User(
              username: usernameController.text,
              email: emailController.text,
              password: passwordController.text,
              sleeper_id: sleeperIDController.text,
            );

            // Call the createUser function to send the POST request
            createUser(user);

            // Navigate to the dashboard page
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Dashboard(user: user)));
          },
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            "Sign Up",
            style: TextStyle(fontSize: 20),
          ),
        )
      ],
    );
  }
}
