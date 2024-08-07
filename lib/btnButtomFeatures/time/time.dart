import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/services.dart';
import 'package:timesheet_001/btnButtomFeatures/invoice.dart';
import 'package:timesheet_001/models/showModel.dart';
import 'package:timesheet_001/second.dart';

class Time extends StatefulWidget {
  @override
  _TimeState createState() => _TimeState();
}

class _TimeState extends State<Time> {
  late List<ShowModel> timeRecords = [];
  String dropdownValue = 'year';
  late DateTime startDate = DateTime.now();
  late DateTime endDate = DateTime.now();
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  List<Color> colorList = [
    const Color.fromARGB(255, 139, 230, 236),
    const Color.fromARGB(255, 95, 155, 97),
    const Color.fromARGB(255, 255, 255, 255),
    const Color.fromARGB(255, 236, 226, 133),
    const Color.fromARGB(255, 235, 70, 5),
    const Color.fromARGB(255, 3, 98, 110)
  ];

  @override
  void initState() {
    super.initState();
    fetchTimeRecords();
  }

  Future<void> fetchTimeRecords() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.12:8000/api/time_show'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)['data'];

        setState(() {
          timeRecords =
              data.map((record) => ShowModel.fromJson(record)).toList();
        });
      } else {
        print('Failed to load time records: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching time records: $error');
    }
  }

  Future<void> exportToExcel() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.12:8000/api/export'));

      if (response.statusCode == 200) {
        if (response.bodyBytes.isEmpty) {
          print('Invalid response: Empty Excel data');
          return;
        }

        if (await Permission.storage.request().isGranted) {
          final directory = await getExternalStorageDirectory();
          if (directory == null) {
            print('Error: Failed to get external storage directory');
            return;
          }

          final filePath = '${directory.path}/time_records.xlsx';
          final file = File(filePath);

          await file.writeAsBytes(response.bodyBytes);

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Export Successful'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time records exported to Excel successfully.'),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        OpenFile.open(filePath);
                      },
                      child: Text('Open Excel'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          print('Error: Storage permission not granted');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Storage Permission Required'),
                content: Text(
                    'This app needs storage permission to export Excel files. Please grant permission and try again.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        print('Failed to export time records: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Export Failed'),
              content: Text('Failed to export time records to Excel.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Error exporting time records: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Export Failed'),
            content: Text('Failed to export time records to Excel.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> deleteItem(int index) async {
    int itemId = timeRecords[index].id;

    setState(() {
      timeRecords.removeAt(index);
    });

    try {
      final response = await http.delete(
          Uri.parse('http://192.168.1.12:8000/api/time_delete/$itemId'));

      if (response.statusCode == 200) {
        print('Item deleted successfully');
      } else {
        print('Failed to delete item: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting item: $error');
    }
  }

  void navigateToInvoicePage(String client) {
    List<ShowModel> filteredRecords =
        timeRecords.where((record) => record.client == client).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoicePage(filteredRecords),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 15, 15, 15),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Second()),
            );
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            DropdownButton<String>(
              dropdownColor: Colors.black,
              value: dropdownValue,
              items: const [
                DropdownMenuItem(
                    child: Text('Year', style: TextStyle(color: Colors.white)),
                    value: 'year'),
                DropdownMenuItem(
                    child: Text('Month', style: TextStyle(color: Colors.white)),
                    value: 'month'),
                DropdownMenuItem(
                    child: Text('Semi-Month',
                        style: TextStyle(color: Colors.white)),
                    value: 'semi-month'),
                DropdownMenuItem(
                    child: Text('Quarter-Week',
                        style: TextStyle(color: Colors.white)),
                    value: 'quarter-week'),
                DropdownMenuItem(
                    child:
                        Text('Bi-Week', style: TextStyle(color: Colors.white)),
                    value: 'bi-week'),
                DropdownMenuItem(
                    child: Text('Week', style: TextStyle(color: Colors.white)),
                    value: 'week'),
                DropdownMenuItem(
                    child: Text('Day', style: TextStyle(color: Colors.white)),
                    value: 'day'),
              ],
              onChanged: (String? value) {
                setState(() {
                  dropdownValue = value!;
                  if (value == 'year') {
                    startDate = DateTime(DateTime.now().year, 1, 1);
                    endDate = DateTime(DateTime.now().year, 12, 31);
                  } else if (value == 'month') {
                    startDate =
                        DateTime(DateTime.now().year, DateTime.now().month, 1);
                    endDate = DateTime(
                        DateTime.now().year, DateTime.now().month + 1, 0);
                  } else if (value == 'semi-month') {
                    if (DateTime.now().day <= 15) {
                      startDate = DateTime(
                          DateTime.now().year, DateTime.now().month, 1);
                      endDate = DateTime(
                          DateTime.now().year, DateTime.now().month, 15);
                    } else {
                      startDate = DateTime(
                          DateTime.now().year, DateTime.now().month, 16);
                      endDate = DateTime(
                          DateTime.now().year, DateTime.now().month + 1, 0);
                    }
                  } else if (value == 'quarter-week' ||
                      value == 'bi-week' ||
                      value == 'week') {
                    int daysUntilNextMonday = 8 - DateTime.now().weekday;
                    startDate = DateTime.now()
                        .subtract(Duration(days: daysUntilNextMonday - 1));
                    endDate = startDate.add(Duration(days: 6));
                  } else if (value == 'day') {
                    startDate = DateTime.now();
                    endDate = startDate;
                  }
                });
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.file_download,
              color: Colors.white,
            ),
            onPressed: () {
              exportToExcel();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey,
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Text(" ${startDate.month}-${startDate.day}"),
                Text(" - ${endDate.day}-${endDate.month}-${endDate.year}"),
              ],
            ),
          ),
          Container(
            color: Colors.grey,
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Text(" ${DateTime.now().day}-${DateTime.now().month}"),
                Text(" ${daysOfWeek[DateTime.now().weekday - 1]}"),
              ],
            ),
          ),
          if (timeRecords.isEmpty)
            Center(
              child: CircularProgressIndicator(),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: timeRecords.length,
                itemBuilder: (context, index) {
                  final record = timeRecords[index];
                  final color = colorList[index % colorList.length];

                  return GestureDetector(
                    onTap: () {
                      navigateToInvoicePage(record.client);
                    },
                    child: Card(
                      elevation: 1.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: ListTile(
                        isThreeLine: true,
                        leading: Container(
                          width: 10,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        title: Text(
                          '${record.selectedProject} - ${record.client}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'In: ${record.timeIn} - Out: ${record.timeOut}',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            Text(
                              'Break: ${record.timebreak} - Hours: ${record.workingHours}',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            Text('${record.description}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteItem(index);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
