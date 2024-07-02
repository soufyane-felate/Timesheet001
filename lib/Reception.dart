/*import 'package:flutter/material.dart';
import 'package:timesheet_001/btnButtomFeatures/time/time.dart';
import 'package:timesheet_001/second.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:timesheet_001/btnButtomFeatures/invoice.dart';
import 'package:timesheet_001/models/showModel.dart';

class Reception extends StatefulWidget {
  const Reception({Key? key}) : super(key: key);

  @override
  State<Reception> createState() => _ReceptionState();
}

class _ReceptionState extends State<Reception> {
  var domaine = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Image.asset("images/logo.png"),
              Text("Saisir le nom du domaine avant de continuer"),
              TextField(
                controller: domaine,
                decoration: InputDecoration(
                  icon: Icon(Icons.home),
                  prefixText: "http://",
                  hintText: "127.0.0.1:8000",
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        domaine.clear();
                      },
                      child: Text("Supprimer"),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        String domain = domaine.text.trim();
                        if (domain.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Time(domaine: domain),
                            ),
                          );
                        }
                      },
                      child: Text("Enregistrer"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
*/