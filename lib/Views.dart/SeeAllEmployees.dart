import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Employees extends StatelessWidget {
  Future<List<Map<String, dynamic>>> fetchData() async {
    final response = await http.get(
      Uri.parse('http://192.168.100.75:8084/api/User/GetAllEmployeeData'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
              backgroundColor: Colors.black,

        title: Center(
          child: Text('All Employees Data',style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Map<String, dynamic>> data = snapshot.data!;
              return DataTable(
                columns: [
                  DataColumn(label: Text('ID', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('NFC ID', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Name', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold))),
                ],
                rows: data
                    .map(
                      (row) => DataRow(
                        cells: [
                          DataCell(Text(
                            row['id'].toString(),
                            style: TextStyle(color: Colors.white),
                          )),
                          DataCell(Text(
                            row['nfcId'].toString(),
                            style: TextStyle(color: Colors.white),
                          )),
                          DataCell(Text(
                            row['name'].toString(),
                            style: TextStyle(color: Colors.white),
                          )),
                        ],
                      ),
                    )
                    .toList(),
              );
            }
          },
        ),
      ),
    );
  }
}
