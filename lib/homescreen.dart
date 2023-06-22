import 'package:attendanceapp/calendarscreen.dart';
import 'package:attendanceapp/profilescreen.dart';
import 'package:attendanceapp/service/location_service.dart';
import 'package:attendanceapp/todayscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = const Color(0xffee444c);

  int currentIndex = 1;

  List<IconData> navigationIcons = [
    FontAwesomeIcons.calendarAlt,
    FontAwesomeIcons.check,
    FontAwesomeIcons.user
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _startLocationService();
    getId();
  }

  void _startLocationService() async {
    LocationService().initialize();

    LocationService().getLongtitude().then((value) {
      setState(() {
        User.lng = value!;
      });
    });

    LocationService().getLatitude().then((value) {
      setState(() {
        User.lat = value!;
      });
    });
  }

  void getId() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .where('id', isEqualTo: User.id)
        .get();

    setState(() {
      User.id = snapshot.docs[0].id;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          new CalendarScreen(),
          new TodayScreen(),
          new ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 24,
        ),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 2),
            )
          ],
        ),
        child: ClipRect(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < navigationIcons.length; i++)
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = i;
                    });
                  },
                  child: Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            navigationIcons[i],
                            color: i == currentIndex ? primary : Colors.black54,
                            size: i == currentIndex ? 30 : 24,
                          ),
                          i == currentIndex
                              ? Container(
                                  margin: EdgeInsets.only(top: 6),
                                  height: 3,
                                  width: 24,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: primary),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ))
            ],
          ),
        ),
      ),
    );
  }
}
