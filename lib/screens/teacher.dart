import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hazri/global/DashButton.dart';
import 'package:hazri/global/styles.dart';
import 'package:hazri/global/topBar.dart';
import 'package:hazri/screens/LoginPage.dart';
import 'package:hazri/screens/AttendanceScreen.dart';

class Teacher extends StatefulWidget {
  final String uid;
  const Teacher({super.key, required this.uid});

  @override
  State<Teacher> createState() => _TeacherState();
}

class _TeacherState extends State<Teacher> {
   late Future<DocumentSnapshot<Map<String, dynamic>>> userData;
   //late Future<QuerySnapshot<Map<String, dynamic>>> courseData;

  @override
  void initState() {
    userData = getUserData();
    //courseData = getCourseData();
    super.initState();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    return FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCourseData() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('courses')
        .get();

    return querySnapshot;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: const TopBar(screenName: "TEACHER"),
        body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: userData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  final userData = snapshot.data!.data()!;
                  final userName = userData['name'];

                  return Column(
                    children: [
                      DashWelcome(name: '$userName!', color: AppColors.textColor, ),
                      const SizedBox(
                        height: 10,
                      ),
                        Padding(
                        padding: const EdgeInsets.only(
                            left: 30.0, right: 30.0, top: 20, bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: (){},
                              child: const DashComp(
                                name: "Capture Attendance",
                                icon: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  
                                  size: 60,
                                ),
                                color: AppColors.secondaryColor,
                              ),
                            ),
                            InkWell(
                              onTap: (){},
                              child: const DashComp(
                                name: "Manual Attendance",
                                icon: Icon(
                                  Icons.person_add_alt_outlined,
                                  color: Colors.white,
                                  size: 60,
                                ),
                                color: AppColors.secondaryColor,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                       Padding(
                        padding: const EdgeInsets.only(right: 30, left: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () async{

                                // Fetch courseData inside the onTap callback
                                  QuerySnapshot<Map<String, dynamic>> courseDataSnapshot = await getCourseData();

                                  // Extract the courseCode from the first document in the query result
                                  String courseCode = courseDataSnapshot.docs.isNotEmpty
                                      ? courseDataSnapshot.docs[0].data()['courseCode']
                                      : '';

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) =>
                                    AttendanceScreen(courseCode: courseCode ,sessionDocumentId: "1fb7ph6V9VnA7jMBVzyH" )
                                    ),
                                 );
                              },
                              child: const DashComp(
                                name: "View Attendance",
                                icon: Icon(
                                  Icons.remove_red_eye,
                                  color: Colors.white,
                                  size: 60,
                                ),
                                color: AppColors.secondaryColor,
                              ),
                            ),
                            InkWell(
                              onTap: (){
                              },
                              child: const DashComp(
                                name: "Generate Report",
                                icon: Icon(Icons.receipt_outlined, color: Colors.white, size: 60,),
                                color: AppColors.secondaryColor,
                                
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  );
                }
              })
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}
