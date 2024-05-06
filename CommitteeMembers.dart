import 'package:digital_society/AddMembers.dart';
import 'package:digital_society/AddNotice.dart';
import 'package:digital_society/ViewComplaints.dart';
import 'package:digital_society/ViewMembers.dart';
import 'package:digital_society/ViewNotice.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CommitteePage extends StatefulWidget {
  String? name;
  String? id;
  CommitteePage({super.key, required this.name, required this.id});

  @override
  State<CommitteePage> createState() => _CommitteePageState();
}

class _CommitteePageState extends State<CommitteePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text("Welcome ${widget.name}"),
      ),
      drawer: Drawer(
        backgroundColor: Colors.blue[400],
        child: Column(
          children: [
            Container(
              height: 30,
              width: 200,
              child: Text(
                "THE SEASIDE CO-OP",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Divider(
              color: Colors.black,
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewMembersPage(),
                    ));
              },
              leading: Icon(Icons.person, color: Colors.black),
              title: Text(
                "View Members",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ViewNoticePage(name: widget.name, id: widget.id),
                    ));
              },
              leading: Icon(Icons.note_sharp, color: Colors.black),
              title: Text(
                "View Notice",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewComplaintsPage(),
                    ));
              },
              leading: Icon(Icons.report_gmailerrorred, color: Colors.black),
              title: Text(
                "View Complaints",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddMembersScreen(name: widget.name, id: widget.id),
                    ));
              },
              leading: Icon(Icons.person_add, color: Colors.black),
              title: Text(
                "New Member",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddNoticeScreen(name: widget.name, id: widget.id),
                    ));
              },
              leading: Icon(Icons.note_add, color: Colors.black),
              title: Text(
                "Issue Notice",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
