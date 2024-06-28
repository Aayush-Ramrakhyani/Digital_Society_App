import 'package:digital_society/CommitteeMembers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class AddNoticeScreen extends StatefulWidget {
  String? name;
  String? id;
  AddNoticeScreen({super.key, required this.name, required this.id});

  @override
  State<AddNoticeScreen> createState() => _AddNoticeScreenState();
}

class _AddNoticeScreenState extends State<AddNoticeScreen> {
  TextEditingController headcontroller = TextEditingController();
  TextEditingController contentcontroller = TextEditingController();
  String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  Future<void> notice() async {
      await http.post(Uri.parse("https://theseaside.000webhostapp.com/AddNotice.php"), body: {
        "Head": headcontroller.text,
        "Content": contentcontroller.text,
        "Date": date,
        "IssueBy": widget.name,
      });

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CommitteePage(
                    name: widget.name,
                    id: widget.id,
                  ),
                ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text("Issue Notice"),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),
            TextField(
              controller: headcontroller,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: "Title of Notice"),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: contentcontroller,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter Content of Notice",
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  notice();
                },
                child: Text("Submit"))
          ],
        ),
      ),
    );
  }
}
