// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_application_1/Views.dart/Scannings.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:http/http.dart' as http;
class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
   TextEditingController userNameController = TextEditingController();
  String? nfcId;


  Future<void> addEmployee() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanningScreen()),
    );

    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (isAvailable) {
        print('NFC is available on this device');

        NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
          try {
            Uint8List identifier =
                Uint8List.fromList(tag.data["mifareultralight"]['identifier']);
            final String? id = identifier
                .map((e) => e.toRadixString(16).padLeft(2, '0'))
                .join(':');
            setState(() {
              nfcId = id;
            });
            print('tag id#########:${id}');
            NfcManager.instance.stopSession();
                Navigator.pop(context);

          } catch (error) {
            print('Error reading NFC tag: $error');
          }
        });

        return;
      } else {
        print('NFC is not available on this device');
      }
    } catch (error) {
      print('Error during NFC session: $error');
    }
  }

   Future<void> sendEmployeeData() async {

    try {
      final String apiUrl = 'http://192.168.100.75:8084/api/User/AddEmployee';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: '''
          {
            "nfcId": "$nfcId",
            "name": "${userNameController.text}"
          }
        ''',
      );

      if (response.statusCode == 200) {
        print('Employee added successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Employee added successfully'),
            duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,

          ),
        );
      } else {
        print('Failed to add employee with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
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
    } catch (error) {
      print('Error during employee addition request: $error');
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
       backgroundColor: Colors.black,
      appBar: AppBar(
         iconTheme: IconThemeData(
    color: Colors.white, // Set the color of the icons
    size: 24.0, // Set the size of the icons
  ),
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            'Add New Employee!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
     body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    TextField(
      controller: userNameController,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Enter User Name',
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    ),
    SizedBox(height: 20),
    Text(
      'NFC ID: ${nfcId ?? 'Scan NFC to get ID'}',
      style: TextStyle(color: Colors.white),
    ),
    SizedBox(height: 20),
    ElevatedButton(
      onPressed: () => addEmployee(),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(150, 60),
        primary: Colors.blue, // Set your preferred button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: const Text(
        'Scan NFC',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
    SizedBox(height: 20),
    ElevatedButton(
      onPressed: () => sendEmployeeData(),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(200, 60),
        primary: Colors.green, // Set your preferred button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: const Text(
        'Add Employee',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  ],
)

      ),
    );
  }
}