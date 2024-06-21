import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ViewMembersPage extends StatefulWidget {
  const ViewMembersPage({super.key});

  @override
  State<ViewMembersPage> createState() => _ViewMembersPageState();
}

class Members {
  String? houseno;
  String? familyname;
  List<Family> family;

  Members(
      {required this.houseno, required this.familyname, required this.family});

  factory Members.fromJson(Map<String, dynamic> json) {
    var familyList = json['family'] as List;
    List<Family> family = familyList.map((i) => Family.fromJson(i)).toList();

    return Members(
      houseno: json['houseno'],
      familyname: json['familyname'],
      family: family,
    );
  }
}

class Family {
  String? name;
  String? contactno;
  String? age;
  String? gender;

  Family({
    required this.name,
    required this.contactno,
    required this.age,
    required this.gender,
  });

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      name: json["name"],
      contactno: json["contactno"],
      age: json["age"],
      gender: json["gender"],
    );
  }
}

class _ViewMembersPageState extends State<ViewMembersPage> {
  List<Members> myFutureData = [];
  Future<List<Members>> fetchData() async {
    var response = await http
        .get(Uri.parse("https://theseaside.000webhostapp.com/AllDetails.php"));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Members> Memberss =
          jsonData.map((json) => Members.fromJson(json)).toList();
      return Memberss;
      // return Members.fromJson(jsonDecode(response.body));
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
          backgroundColor: Colors.blue[400],
          title: Text("Display Members"),
        ),
        body: ListView.builder(
          itemCount: myFutureData.length,
          itemBuilder: (context, index) {
            return ExpansionTile(
              title: Text("${myFutureData[index].familyname}"),
              leading: Text("${myFutureData[index].houseno}", style: TextStyle(fontWeight: FontWeight.w700),),
              children: [
                for (var familyMember in myFutureData[index].family)
                  ListTile(
                    title: Text("${familyMember.name}"),
                    subtitle: Row(
                      children: [
                        IconButton(onPressed: () {  
                        }, icon: Icon(Icons.call)),
                        Text("Contact: ${familyMember.contactno}"),
                      ],
                    ),
                  ),
              ],
            );
          },
        ));
  }
}
