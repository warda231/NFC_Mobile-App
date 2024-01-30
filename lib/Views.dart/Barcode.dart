// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, avoid_print, prefer_const_declarations, library_private_types_in_public_api, use_key_in_widget_constructors

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'package:qr_flutter/qr_flutter.dart';

class CheckInOutScreen extends StatefulWidget {
  @override
  _CheckInOutScreenState createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen> {
  //storing returned value of generateQRCode() function
  String currentQRCode = generateQRCode();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        currentQRCode = generateQRCode();
        updateQrCodeInBackend(currentQRCode);
      });
    });

    Timer.periodic(Duration(minutes: 5), (timer) {
      setState(() {
        currentQRCode = generateQRCode();
        updateQrCodeInBackend(currentQRCode);
      });
    });
  }

  static String generateQRCode() {
    double companyLatitude = 32.5630;
    double companyLongitude = 74.0801;

//creating a map with string keys and dynamic values
    Map<String, dynamic> qrCodeData = {
      //current time in milliseconds
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      'companyLocation': {'latitude': companyLatitude, 'longitude': companyLongitude},
    };

    // Convert the map to a JSON string
    String qrCodeDataJson = jsonEncode(qrCodeData);

    return qrCodeDataJson;
  }

  Future<void> updateQrCodeInBackend(String qrCode) async {
    try {
      // Extract timestamp from the QR code data
      Map<String, dynamic> qrCodeData = json.decode(qrCode);
      String timestamp = qrCodeData['timestamp'];

      // Send only the timestamp to the backend
      final String apiUrl = 'http://localhost:8084/api/BarcodeApp/AddQrCode';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'qrCode': timestamp}),
      );

      if (response.statusCode == 200) {
        print('QRcode Added successful');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QRcode Added successfully'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error during Adding QRcode request: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            'QR Code View',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: currentQRCode,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ],
        ),
      ),
    );
  }
}
