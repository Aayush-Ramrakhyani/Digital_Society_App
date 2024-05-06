import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ViewComplaintsPage extends StatefulWidget {
  const ViewComplaintsPage({super.key});

  @override
  State<ViewComplaintsPage> createState() => _ViewComplaintsPageState();
}

class Complaints {
  String? ID;
  String? houseno;
  String? Title;
  String? Description;
  String? Status;
  String? Date;
  String? FinishDate;
  String? Action;
  String? Feedback;

  Complaints(
      {required this.ID,
      required this.houseno,
      required this.Title,
      required this.Description,
      required this.Status,
      required this.Date,
      required this.FinishDate,
      required this.Action,
      required this.Feedback});

  factory Complaints.fromJson(Map<String, dynamic> json) {
    return Complaints(
        ID: json["ID"],
        houseno: json["houseno"],
        Title: json["Title"],
        Description: json["Description"],
        Status: json["Status"],
        Date: json["Date"],
        FinishDate: json["FinishDate"],
        Action: json["Action"],
        Feedback: json["Feedback"]);
  }
}

class _ViewComplaintsPageState extends State<ViewComplaintsPage> {
  List<Complaints> myFutureData = [];
 

  Future<List<Complaints>> fetchData() async {
    var response = await http.get(
        Uri.parse("https://theseaside.000webhostapp.com/ViewComplaints.php"));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Complaints> Complaintss =
          jsonData.map((json) => Complaints.fromJson(json)).toList();
      return Complaintss;
      // return Complaints.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("something went wrong");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
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
      body: ListView.builder(
        itemCount: myFutureData.length,
        itemBuilder: (context, index) {
          return Container(
            child: Card(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Title : ${myFutureData[index].Title}"),
                      Text("By: ${myFutureData[index].houseno}"),
                      Text("Date: ${myFutureData[index].Date}"),
                      Switch(
                        value: myFutureData[index].Status == "pending" ? false : true,
                        onChanged: (value) {
                          setState(() {
                            
                          });
                        },
                      ),
                    ],
                  ),
                  Divider(),
                  Text("Description : ${myFutureData[index].Description}"),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(onPressed: () {
                        
                      }, icon: Icon(Icons.call_to_action)),
                      IconButton(onPressed: () {
                        
                      }, icon: Icon(Icons.feedback)),
                      myFutureData[index].FinishDate != 'Null' ? Text("${myFutureData[index].FinishDate}") : SizedBox(),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
