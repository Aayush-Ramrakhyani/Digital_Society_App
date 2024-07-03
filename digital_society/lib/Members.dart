import 'dart:convert';
import 'package:digital_society/AddComplaints.dart';
import 'package:digital_society/LoginPage.dart';
import 'package:digital_society/ViewMembers.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MembersPage extends StatefulWidget {
  String? name;
  String? id;
  MembersPage({super.key, required this.name, required this.id});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class Notice {
  String? ID;
  String? Head;
  String? Content;
  String? IssueBy;
  String? Date;

  Notice(
      {required this.ID,
      required this.Head,
      required this.Content,
      required this.IssueBy,
      required this.Date});

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
        ID: json["ID"],
        Head: json["Head"],
        Content: json["Content"],
        IssueBy: json["IssueBy"],
        Date: json["Date"]);
  }
}

class _MembersPageState extends State<MembersPage> {
  List<Notice> myFutureData = [];

  Future<List<Notice>> fetchData() async {
    var response = await http
        .get(Uri.parse("https://theseaside.000webhostapp.com/GetNotice.php"));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Notice> Notices =
          jsonData.map((json) => Notice.fromJson(json)).toList();
      return Notices;
    } else {
      throw Exception("something went wrong");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData().then(
      (value) {
        setState(() {
          myFutureData = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue[400],
          title: Text(
            "Welcome ${widget.name}",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddComplaintsPage(name: widget.name, id: widget.id),
                      ));
                },
                icon: Icon(
                  Icons.error,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewMembersPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.family_restroom,
                  color: Colors.white,
                )),
            IconButton(
              onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MyLoginPage()),
                    (Route<dynamic> route) => false,
                  );
              },
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: myFutureData.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                shadowColor: Colors.blueAccent.withOpacity(0.2),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    gradient: LinearGradient(
                      colors: [Colors.blue[300]!, Colors.blue[400]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Head: ${myFutureData[index].Head}",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            "Date: ${myFutureData[index].Date}",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Divider(
                        color: Colors.white54,
                        thickness: 1.0,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "${myFutureData[index].Content}",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "IssueBy: ${myFutureData[index].IssueBy}",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
