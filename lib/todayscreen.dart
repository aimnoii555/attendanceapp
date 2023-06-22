import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';

import 'models/user.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  String checkIn = '--:--';
  String checkOut = '--:--';

  String location = ' ';

  Color primary = const Color(0xffeef444c);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getRecord();
  }

  void _getLocation() async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(User.lat, User.lng);

    setState(() {
      location =
          '${placemark[0].street},${placemark[0].administrativeArea},${placemark[0].postalCode},${placemark[0].country}';
    });
  }

  void _getRecord() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Employee')
          .where('id', isEqualTo: User.id)
          .get();

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Employee')
          .doc(snapshot.docs[0].id)
          .collection('Record')
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();

      setState(() {
        checkIn = documentSnapshot['checkIn'];
        checkOut = documentSnapshot['checkOut'];
      });
    } catch (e) {
      setState(() {
        checkIn = '--:--';
        checkOut = '--:--';
      });
    }
    // print(checkIn);
    // print(checkOut);
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 30),
              alignment: Alignment.centerLeft,
              child: Text(
                'Welcome, ',
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: 'Itim',
                  fontSize: screenWidth / 20,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'Employee ' + User.id!,
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: 'Itim',
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth / 18,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 32),
              alignment: Alignment.centerLeft,
              child: Text(
                "Today's Status",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Itim',
                  fontSize: screenWidth / 18,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 32),
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(2, 2)),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Check In',
                            style: TextStyle(
                              fontFamily: 'Itim',
                              fontSize: screenWidth / 20,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            checkIn,
                            style: TextStyle(
                                fontFamily: 'Itim', fontSize: screenWidth / 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Check Out',
                            style: TextStyle(
                              fontFamily: 'Itim',
                              fontSize: screenWidth / 20,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            checkOut,
                            style: TextStyle(
                                fontFamily: 'Itim', fontSize: screenWidth / 18),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                    text: DateTime.now().day.toString(),
                    style: TextStyle(
                        color: primary,
                        fontFamily: 'Itim',
                        fontSize: screenWidth / 18),
                    children: [
                      TextSpan(
                          text: DateFormat(' MMM yyyy').format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth / 20,
                            fontFamily: 'Itim',
                            fontWeight: FontWeight.bold,
                          ))
                    ]),
              ),
            ),
            StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      DateFormat('hh:mm:ss a').format(DateTime.now()),
                      style: TextStyle(
                        fontFamily: 'Itim',
                        color: Colors.black54,
                        fontSize: screenWidth / 20,
                      ),
                    ),
                  );
                }),
            checkOut == '--:--'
                ? Container(
                    margin: const EdgeInsets.only(top: 32, bottom: 12),
                    child: Builder(
                      builder: (context) {
                        final GlobalKey<SlideActionState> key = GlobalKey();
                        return SlideAction(
                          text: checkIn == '--:--'
                              ? 'Slide to Check In'
                              : 'Slide to Check Out',
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth / 20,
                            fontFamily: 'Itim',
                          ),
                          outerColor: Colors.white,
                          innerColor: primary,
                          key: key,
                          onSubmit: () async {
                            if (User.lat != 0) {
                              _getLocation();

                              // Future.delayed(Duration(milliseconds: 500), () {});
                              QuerySnapshot snapshot = await FirebaseFirestore
                                  .instance
                                  .collection('Employee')
                                  .where('id', isEqualTo: User.employeeId)
                                  .get();

                              DocumentSnapshot documentSnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('Employee')
                                      .doc(snapshot.docs[0].id)
                                      .collection('Record')
                                      .doc(DateFormat('dd MMMM yyyy')
                                          .format(DateTime.now()))
                                      .get();

                              try {
                                String checkIn = documentSnapshot['checkIn'];
                                setState(() {
                                  checkOut = DateFormat('hh:mm')
                                      .format(DateTime.now());
                                });
                                await FirebaseFirestore.instance
                                    .collection('Employee')
                                    .doc(snapshot.docs[0].id)
                                    .collection('Record')
                                    .doc(
                                      DateFormat('dd MMMM yyyy').format(
                                        DateTime.now(),
                                      ),
                                    )
                                    .update({
                                  'date': Timestamp.now(),
                                  'checkIn': checkIn,
                                  'checkOut': DateFormat('hh:mm')
                                      .format(DateTime.now()),
                                  'checkInLocation': location,
                                });
                              } catch (e) {
                                setState(() {
                                  checkIn = DateFormat('hh:mm')
                                      .format(DateTime.now());
                                });
                                await FirebaseFirestore.instance
                                    .collection('Employee')
                                    .doc(snapshot.docs[0].id)
                                    .collection('Record')
                                    .doc(
                                      DateFormat('dd MMMM yyyy').format(
                                        DateTime.now(),
                                      ),
                                    )
                                    .set({
                                  'date': Timestamp.now(),
                                  'checkIn': DateFormat('hh:mm')
                                      .format(DateTime.now()),
                                  'checkOut': '--:--',
                                  'checkOutLocation': location,
                                });
                              }
                              key.currentState!.reset();
                            } else {
                              Timer(const Duration(seconds: 3), () async {
                                _getLocation();

                                // Future.delayed(Duration(milliseconds: 500), () {});
                                QuerySnapshot snapshot = await FirebaseFirestore
                                    .instance
                                    .collection('Employee')
                                    .where('id', isEqualTo: User.employeeId)
                                    .get();

                                DocumentSnapshot documentSnapshot =
                                    await FirebaseFirestore.instance
                                        .collection('Employee')
                                        .doc(snapshot.docs[0].id)
                                        .collection('Record')
                                        .doc(DateFormat('dd MMMM yyyy')
                                            .format(DateTime.now()))
                                        .get();

                                try {
                                  String checkIn = documentSnapshot['checkIn'];
                                  setState(() {
                                    checkOut = DateFormat('hh:mm')
                                        .format(DateTime.now());
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('Employee')
                                      .doc(snapshot.docs[0].id)
                                      .collection('Record')
                                      .doc(
                                        DateFormat('dd MMMM yyyy').format(
                                          DateTime.now(),
                                        ),
                                      )
                                      .update({
                                    'date': Timestamp.now(),
                                    'checkIn': checkIn,
                                    'checkOut': DateFormat('hh:mm')
                                        .format(DateTime.now()),
                                    'checkInLocation': location,
                                  });
                                } catch (e) {
                                  setState(() {
                                    checkIn = DateFormat('hh:mm')
                                        .format(DateTime.now());
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('Employee')
                                      .doc(snapshot.docs[0].id)
                                      .collection('Record')
                                      .doc(
                                        DateFormat('dd MMMM yyyy').format(
                                          DateTime.now(),
                                        ),
                                      )
                                      .set({
                                    'date': Timestamp.now(),
                                    'checkIn': DateFormat('hh:mm')
                                        .format(DateTime.now()),
                                    'checkOut': '--:--',
                                    'checkOutLocation': location,
                                  });
                                }
                                key.currentState!.reset();
                              });
                            }
                          },
                        );
                      },
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.only(top: 32, bottom: 32),
                    child: Text(
                      'You have completed this day!',
                      style: TextStyle(
                        fontFamily: 'Itim',
                        fontSize: screenWidth / 20,
                        color: Colors.black54,
                      ),
                    ),
                  ),
            location != ' '
                ? Text(
                    'Location:' + location,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
