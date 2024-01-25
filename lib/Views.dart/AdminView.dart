// ignore_for_file: prefer_const_constructors, prefer_const_declarations

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Views.dart/AddEmployee.dart';
import 'package:flutter_application_1/Views.dart/SeeAllEmployees.dart';
import 'package:flutter_application_1/Views.dart/loginScreen.dart';
import 'package:http/http.dart' as http;

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool open = false;
  TextEditingController employeeNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 24.0,
        ),
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            'Admin Screen!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.account_circle,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
            onPressed: () {
              showProfileMenu();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 120.0),
        child: Column(
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddEmployeePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(200, 60),
                  primary: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: const Text(
                  'Add New Employee',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Employees()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(200, 60),
                  primary: Colors.blue, // Set the background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        15.0), // Adjust the border radius as needed
                  ),
                ),
                child: const Text(
                  'See All Employees',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  showDeleteEmployeeDialog();
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(200, 60),
                  primary: Colors.blue, // Set the background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        15.0), // Adjust the border radius as needed
                  ),
                ),
                child: const Text(
                  'Delete Employee',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDeleteEmployeeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Employee Name'),
          content: TextField(
            controller: employeeNameController,
            decoration: InputDecoration(hintText: 'Employee Name'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Send delete request to RESTful API
                deleteEmployee();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void deleteEmployee() async {
    String employeeName = employeeNameController.text;

    String apiUrl =
        'http://192.168.100.75:8084/api/User/DeleteEmployee/$employeeName';

    var response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'employeeName': employeeName}),
    );

    if (response.statusCode == 200) {
      print('Employee deleted successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Employee Deleted successfully'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print('Error deleting employee. Status code: ${response.statusCode}');
      final Map<String, dynamic> errorData = json.decode(response.body);

      if (errorData.containsKey('errors')) {
        final errors = errorData['errors'];
        if (errors is Map<String, dynamic>) {
          errors.forEach((key, value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$value'),
                backgroundColor: Colors.red,
              ),
            );
          });
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${errorData['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showProfileMenu() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 80, 0, 0),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ),
      ],
      elevation: 8.0,
    );
  }
}
