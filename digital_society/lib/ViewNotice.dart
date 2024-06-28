import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ViewNoticePage extends StatefulWidget {
  String? name;
  String? id;
  ViewNoticePage({super.key, required this.name, required this.id});

  @override
  State<ViewNoticePage> createState() => _ViewNoticePageState();
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

class _ViewNoticePageState extends State<ViewNoticePage> {
  List<Notice> myFutureData = [];

  Future<List<Notice>> fetchData() async {
    var response = await http
        .get(Uri.parse("https://theseaside.000webhostapp.com/GetNotice.php"));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Notice> Notices =
          jsonData.map((json) => Notice.fromJson(json)).toList();
      return Notices;
      // return Notice.fromJson(jsonDecode(response.body));
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("View Notice"),
        ),
        body: ListView.builder(
          itemCount: myFutureData.length,
          itemBuilder: (context, index) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("Head: ${myFutureData[index].Head}"),
                          SizedBox(
                            width: 25,
                          ),
                          Text("Date: ${myFutureData[index].Date}"),
                          IconButton(
                              onPressed: () {
                                
                          }, icon: Icon(Icons.more_vert))
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(),
                      SizedBox(
                        height: 5,
                      ),
                      Text("${myFutureData[index].Content}"),
                      SizedBox(
                        height: 5,
                      ),
                      Text("IssueBy: ${myFutureData[index].IssueBy}"),
                      SizedBox(
                        height: 10,
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
