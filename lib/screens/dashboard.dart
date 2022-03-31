// ignore: file_names
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/app_bar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'settings.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);
  @override
  State<Dashboard> createState() => _DashboardState();
}

void get_data() {
  print("Called");
  var data;
  Future fetchdata() async {
    final response = await http.get(
        Uri.parse('https://drop-count-default-rtdb.firebaseio.com/test.json'));

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  fetchdata().then((value) => print("This is the DATA ==>>" + data.toString()));
  print(data);
}

class _DashboardState extends State<Dashboard> {
  final User? _username = FirebaseAuth.instance.currentUser;

  final _waterSaved = 30;
  var data, isSelected = [true, false, false];

  Future retrieveData() async {
    final response = await http.get(
        Uri.parse('https://drop-count-default-rtdb.firebaseio.com/test.json'));

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    retrieveData();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(children: [
      SafeArea(
          child: Scaffold(
              appBar: const AppNavbar(),
              body: SingleChildScrollView(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      child: Text(
                        'Good Morning',
                        style: GoogleFonts.roboto(
                            fontSize: 32, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      child: Text(
                        _username!.displayName.toString(),
                        style: GoogleFonts.roboto(
                            fontSize: 28, fontWeight: FontWeight.w400),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your Progress',
                        style: GoogleFonts.roboto(
                            fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset: const Offset(0, 3))
                          ]),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text((data != null)
                                  ? data.keys.toList()[0].toString()
                                  : ""),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Great !',
                                  style: GoogleFonts.roboto(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'You saved water for ' +
                                      (_waterSaved / 40).ceil().toString() +
                                      ' houses',
                                  style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                          CircularPercentIndicator(
                            radius: 40.0,
                            lineWidth: 5.0,
                            percent: _waterSaved / 40,
                            center: Text(
                              _waterSaved.toString() + "%",
                              style: GoogleFonts.roboto(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                            progressColor:
                                const Color.fromRGBO(108, 229, 232, 1.0),
                            backgroundColor: Colors.grey.withOpacity(0.2),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromRGBO(245, 245, 245, 1.0),
                      ),
                      child: ToggleButtons(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            child: Text('Daily',
                                style: GoogleFonts.roboto(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Text('Monthly',
                                style: GoogleFonts.roboto(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Text('Weekly',
                                style: GoogleFonts.roboto(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                          ),
                        ],
                        selectedColor: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        constraints: BoxConstraints(
                            minWidth:
                                (MediaQuery.of(context).size.width - 36) / 3,
                            minHeight: 40),
                        fillColor: Colors.blue,
                        highlightColor: Colors.white,
                        onPressed: (int index) {
                          setState(() {
                            for (int buttonIndex = 0;
                                buttonIndex < isSelected.length;
                                buttonIndex++) {
                              if (buttonIndex == index) {
                                isSelected[buttonIndex] = true;
                              } else {
                                isSelected[buttonIndex] = false;
                              }
                            }
                          });
                        },
                        isSelected: isSelected,
                      ),
                    ),
                  ],
                ),
              )))),
      const Settings()
    ]);
  }
}
