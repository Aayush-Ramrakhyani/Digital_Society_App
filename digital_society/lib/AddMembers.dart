//import 'package:digital_society/CommitteeMembers.dart';
import 'package:digital_society/CommitteeMembers.dart';
import 'package:digital_society/FamilyWidget.dart';
import 'package:digital_society/controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class AddMembersScreen extends StatefulWidget {
  String? name;
  String? id;
  AddMembersScreen({super.key, required this.name, required this.id});

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  TextEditingController familycontroller = TextEditingController();
  TextEditingController totalcontroller = TextEditingController();
  TextEditingController flatcontroller = TextEditingController();

  Map<String, Controller> mydata = {};

  List<Widget> FamilyList = [];
  int totalmembers = 0;
  bool readonlyy = false;

  Future<void> Members() async {
    for (int i = 0; i < totalmembers; i++) {
      await http.post(Uri.parse("https://theseaside.000webhostapp.com/AddFamilyMembers.php"), body: {
        "houseno": flatcontroller.text,
        "name": mydata["member${i + 1}"]!.namecontroller.text,
        "contactno": mydata["member${i + 1}"]?.contactcontroller.text ?? Null,
        "age": mydata["member${i + 1}"]!.agecontroller.text,
        "gender": mydata["member${i + 1}"]!.gendercontroller.text,
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
    
  }

  Future<void> postfamily() async {
    final response = await http.post(
      Uri.parse("https://theseaside.000webhostapp.com/AddDetails.php"),
      body: {
        "houseno": flatcontroller.text,
        "familyname": familycontroller.text,
        "totalmembers": totalcontroller.text,
        "password": "TSS${flatcontroller.text}"
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        totalmembers = int.parse(totalcontroller.text);
        readonlyy = true;
        FamilyList.clear(); // Clear the list before adding new TextFields

        for (int i = 0; i < totalmembers; i++) {
          mydata["member${i + 1}"] = Controller();
          FamilyList.add(myfamilywidget(mydata["member${i + 1}"]!));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[400],
        title: Text("Add New Family"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "NEW FAMILY",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: flatcontroller,
                readOnly: readonlyy,
                decoration: InputDecoration(
                  labelText: 'Flat Number',
                  prefixIcon: Icon(Icons.house),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: familycontroller,
                readOnly: readonlyy,
                decoration: InputDecoration(
                  labelText: 'Family Name',
                  prefixIcon: Icon(Icons.family_restroom),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: totalcontroller,
                readOnly: readonlyy,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Total Family Members',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  postfamily();
                },
                child: Text(
                  "SUBMIT",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white70,
                  foregroundColor: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              if (FamilyList.isNotEmpty)
                Column(
                  children: [
                    Column(
                      children: FamilyList,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87),
                        onPressed: () {
                          Members();
                        },
                        child: Text(
                          "SUBMIT",
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
