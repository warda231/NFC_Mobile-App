// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, unnecessary_nullable_for_final_variable_declarations, library_private_types_in_public_api

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Views.dart/Scannings.dart';
import 'package:flutter_application_1/Views.dart/loginScreen.dart';
import 'package:http/http.dart' as http;
import 'package:nfc_manager/nfc_manager.dart';

class CheckInScreen extends StatefulWidget {
  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  String? nfcId;
  bool checkin=false;
  bool checkout=false;
  

  Future<void> makeCheckInRequest() async {
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
           if(checkin==true)
        await sendCheckInRequest();
           if(checkout==true)
            await sendCheckOutRequest();


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



Future<void> sendCheckOutRequest() async {
  Navigator.pop(context);

  try {
    final String apiUrl = 'http://192.168.100.75:8084/api/User/CheckOut';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: '{"nfcId": "$nfcId"}',
    );

    if (response.statusCode == 200) {
      print('Check-out successful');
      checkout = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check-out successful'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      print('Check-out failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (error) {
    print('Error during check-out request: $error');
  }
}

Future<void> sendCheckInRequest() async {
  Navigator.pop(context);

  try {
    final String apiUrl = 'http://192.168.100.75:8084/api/User/CheckIn';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: '{"nfcId": "$nfcId"}',
    );

    if (response.statusCode == 200) {
      print('Check-in successful');
      checkin = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check-in successful'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      print('Check-in failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (error) {
    print('Error during check-in request: $error');
  }
}

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
            'Check-In App',
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
            onPressed: () {
              
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
            onPressed: () {
              showProfileMenu();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
        
          children: [
            if(checkin==false )
            ElevatedButton(
              onPressed: () {
                checkin=true;
                makeCheckInRequest();
              },
               style: ElevatedButton.styleFrom(
          fixedSize: Size(200, 60),
          primary: Colors.blue,  
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), 
          ),
        ),
              child: Text('Check-In',style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),),
            ),
                        if(checkin==true)

                       ElevatedButton(
              onPressed: () {
                checkout=true;
                checkin=false;
                makeCheckInRequest();
              },
               style: ElevatedButton.styleFrom(
          fixedSize: Size(200, 60),
          primary: Colors.blue,  
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), 
          ),
        ),
              child: Text('Check-Out',style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),),
            ),
        
          ],
        ),
      ),
    );
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
