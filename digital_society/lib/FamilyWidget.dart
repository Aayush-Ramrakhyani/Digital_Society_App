import 'package:digital_society/controller.dart';
import 'package:flutter/material.dart';


Widget myfamilywidget(Controller controller) {
  return Container(
    color: Colors.blue[400],
    margin: EdgeInsets.all(10),
    child: Column(
      children: [
        TextField(
                    controller: controller.namecontroller,  
                    decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.black),
                    labelText: 'Members Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
        TextField(
                    controller: controller.contactcontroller,
                    decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.black),
                    labelText: 'Contact Number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                ),
        TextField(
                    controller: controller.agecontroller,
                    decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.black),
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.assist_walker_sharp),
                    border: OutlineInputBorder(),
                  ),
                ),
        TextField(
                    controller: controller.gendercontroller,
                    decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.black),
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.transgender),
                    border: OutlineInputBorder(),
                  ),
                ),
       
      ],
    ),
  );
}
