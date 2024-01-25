// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Views.dart/Scannings.dart';
import 'package:nfc_manager/nfc_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _textEditingController = TextEditingController();
  String _nfcTagData = '';
  ValueNotifier<dynamic> result = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 144, 192, 232),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 144, 192, 232),
        title: Center(
          child: Text(
            'NFC Reader',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    body: Padding(
  padding: const EdgeInsets.only(top: 120.0),
  child: Column(
    children: [
      Center(
        child: ElevatedButton(
          onPressed: () => _tagRead(context),
          style: ElevatedButton.styleFrom(
            fixedSize: Size(200, 60), 
          ),
          child: const Text(
            'Start NFC Reading',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 41, 133, 208),
            ),
          ),
        ),
      ),
      SizedBox(height: 20), 
      Center(
        child: ElevatedButton(
          onPressed: () => _showTextInputDialog(context),
          style: ElevatedButton.styleFrom(
            fixedSize: Size(200, 60), 
          ),
          child: const Text(
            'Start NFC Writing',
            style: TextStyle(
                            fontSize: 18,

              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 41, 133, 208),
            ),
          ),
        ),
      ),
    ],
  ),
),

    );
  }

  void _showTextInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Text'),
          content: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              hintText: 'Type your text here',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _startNFCWriting(context);
              },
              child: Text('Write to NFC'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _tagRead(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanningScreen()),
    );

    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      if (isAvailable) {
        print('NFC is available');
        NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
          result.value = tag.data;
          print(result.value);
         _showScannedData(context);

          NfcManager.instance.stopSession();
          _textEditingController.clear();
        });
      } else {
        debugPrint('NFC not available.');
      }
    } catch (e) {
      debugPrint('Error reading NFC: $e');
    }
  }

  void _showScannedData(BuildContext context) {
    Navigator.pop(context);

    try {
      dynamic tagData = result.value;
      Map<Object?, Object?> ndefData = tagData['ndef'];

      if (ndefData != null && ndefData['cachedMessage'] != null) {
        dynamic cachedMessage = ndefData['cachedMessage'];

        if (cachedMessage != null && cachedMessage['records'] != null) {
          List<Object?> records = cachedMessage['records']!;

          if (records.isNotEmpty) {
            dynamic record = records[0];

            if (record != null && record['payload'] != null) {
              List<Object?> payload = record['payload']! as List<Object?>;

              
              String payloadText = String.fromCharCodes(payload.cast<int>());

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('NFC Tag Data'),
                    content: SizedBox(
                      height: 70,
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Text('Payload: $payloadText'),
                        ],
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error processing NFC data: $e');
    }
  }

 void _startNFCWriting(BuildContext context) async {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ScanningScreen()),
  );

  try {
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (isAvailable) {
      String userText = _textEditingController.text;

      if (userText.isNotEmpty) {
        print('NFC is enabled');
        NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
          try {
            NdefMessage message = NdefMessage([
              NdefRecord.createMime('text/plain', utf8.encode(userText)),
            ]);

            await Ndef.from(tag)?.write(message);
            debugPrint('Data emitted successfully');

            Uint8List payload = message.records.first.payload;
            String payloadText = utf8.decode(payload);
            debugPrint("Written data: $payloadText");

            NfcManager.instance.stopSession();
            _textEditingController.clear();
            Navigator.of(context).pop();
            Navigator.pop(context);

            // Show SnackBar when data is successfully written
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Data written to NFC tag successfully'),
                duration: Duration(seconds: 2), // Adjust duration as needed
              ),
            );

          } catch (e) {
            if (e is PlatformException) {
              debugPrint('PlatformException: ${e.message ?? "Unknown error"}');
            } else {
              debugPrint('Error emitting NFC data: $e');
            }
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter text to write to NFC.'),
          ),
        );
      }
    } else {
      debugPrint('NFC not available.');
    }
  } catch (e) {
    debugPrint('Error writing to NFC: $e');
  }
}

}
