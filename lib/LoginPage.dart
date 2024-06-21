import 'dart:convert';
import 'dart:ui';
import 'package:digital_society/CommitteeMembers.dart';
import 'package:digital_society/Members.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key});

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  bool _passwordVisible = true;
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
    } catch (e) {}
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    fetchRecord();
  }

  Future<void> checkpassword() async {
    
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
                  builder: (context) => MembersPage(name: element["familyname"],
                    id: element["houseno"]),
                ));
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
           color: Colors.blue
          ),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,  
          children: [
          Center(
            child: Text("DIGITAL SOCIETY",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.w600)),
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 300,
            height: 60,
            child: TextField(
              controller: _idController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white) , borderRadius: BorderRadius.circular(25)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(25)),
                labelText: 'USERNAME',
                prefixIcon: Icon(Icons.person),
                prefixIconColor: Colors.white,
            ),
          )),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 300,
            height: 60,
            child: TextField(
              style: TextStyle(color: Colors.white),
              controller: _passwordController,
              obscureText: _passwordVisible,
              decoration: InputDecoration(
                prefixIconColor: Colors.white,
                labelText: 'PASSWORD',
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(25)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(25)),
                labelStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white,
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
          SizedBox(
            height: 40,
          ),
          ElevatedButton(
            onPressed: () {
              checkpassword();
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "LOGIN",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white),
          ),
                ],
              ),
        ));
  }
}
