import 'package:digital_society/Members.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class AddComplaintsPage extends StatefulWidget {
  String? name;
  String? id;
  AddComplaintsPage({super.key, required this.name, required this.id});

  @override
  State<AddComplaintsPage> createState() => _AddComplaintsPageState();
}

class _AddComplaintsPageState extends State<AddComplaintsPage> {
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();

  String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> complaints() async {
    await http.post(
        Uri.parse("https://theseaside.000webhostapp.com/AddComplaints.php"),
        body: {
          "houseno": widget.id,
          "Title": titlecontroller.text,
          "Description": descriptioncontroller.text,
          "Date": date,
          "Status": "pending",
        });

    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MembersPage(
                    name: widget.name,
                    id: widget.id,
                  ),
                ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaints"),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),
            TextField(
              controller: titlecontroller,
              decoration: InputDecoration(
                  labelText: "Title", border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: descriptioncontroller,
              maxLines: 5,
              decoration: InputDecoration(
                  labelText: "Description", border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  complaints();
                },
                child: Text("Submit"))
          ],
        ),
      ),
    );
  }
}
