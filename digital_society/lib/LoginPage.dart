import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:digital_society/CommitteeMembers.dart';
import 'package:digital_society/Members.dart';

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key});

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  bool _passwordVisible = false;
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  List<dynamic> myData = [];

  Future<dynamic> fetchRecord() async {
    try {
      var response = await http.get(
          Uri.parse("https://theseaside.000webhostapp.com/HouseDetails.php"));
      if (response.statusCode == 200) {
        setState(() {
          myData = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print("Failed to load data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRecord();
  }

  Future<void> checkPassword() async {
    for (var element in myData) {
      if (element["houseno"] == _idController.text.toString()) {
        if (element["password"] == _passwordController.text.toString()) {
          if (element["familyname"] == "Chairman" ||
              element["familyname"] == "Secretary" ||
              element["familyname"] == "Treasurer") {
            await Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CommitteePage(
                    name: element["familyname"],
                    id: element["houseno"],
                  ),
                ));
          } else {
            await Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MembersPage(
                    name: element["familyname"],
                    id: element["houseno"],
                  ),
                ));
          }
          return;
        }
      }
    }

    // Show error message if login fails
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Login Failed"),
          content: Text("Incorrect username or password."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "DIGITAL SOCIETY",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: TextField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: checkPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  "LOGIN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
