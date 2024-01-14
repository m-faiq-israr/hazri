import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import '../global/styles.dart';
import '../global/topBar.dart';
import '../utils/PermissionHelper.dart';

class AttendanceScreen extends StatefulWidget {
  final String courseCode;
  final String sessionDocumentId;

  const AttendanceScreen({super.key, required this.courseCode, required this.sessionDocumentId});

  @override
  AttendanceScreenState createState() => AttendanceScreenState();
}

class AttendanceScreenState extends State<AttendanceScreen> {
  late Future<DocumentSnapshot<Map<String, dynamic>>>  attendanceData;

  @override
  void initState() {
    attendanceData = getAttendanceData();
    super.initState();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getAttendanceData() async {
    return FirebaseFirestore.instance
            .collection('attendance')
            .doc(widget.courseCode)
            .collection('session')
            .doc(widget.sessionDocumentId)
            .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(screenName: "TEACHER"),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Print Document',
        onPressed: () async {
          // Wait for the attendanceData Future to complete
          DocumentSnapshot<Map<String, dynamic>> snapshot = await attendanceData;
          print('attendance: $attendanceData.size');
          final courseCode = widget.courseCode;
          // Check if the snapshot contains data
          if (snapshot.exists) {
            Uint8List pdfBytes = await buildPdf(snapshot, courseCode);
            await savePdf(pdfBytes);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No data found'),
              duration: Duration(seconds: 5) ,
              )
            );
          }
        },
        child: const Icon(Icons.print),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: attendanceData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Loading indicator while data is being fetched
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {

            return const Text('No data found'); // Handle the case where the document doesn't exist
          }
          // Access the attendance data from the snapshot
            final attendanceData = snapshot.data!.data()!;

          // Extract the required fields from the attendanceData
          List<String> absentStudents = List<String>.from(attendanceData['absentStudents'] ?? []);
          List<String> presentStudents = List<String>.from(attendanceData['presentStudents'] ?? []);
          String section = attendanceData['section'] ?? '';
          DateTime date = attendanceData['date'].toDate();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Section: $section'),
              Text('Session Date: ${date.toLocal()}'), // Convert to local time
              Text('Absent Students: ${absentStudents.join(', ')}'),
              Text('Present Students: ${presentStudents.join(', ')}'),
            ],
          );
        },
      ),
    );
  }

  // generate the pdf
  Future<Uint8List> buildPdf(DocumentSnapshot<Map<String, dynamic>> attendanceData, String courseCode) async {
    // Create the Pdf document
    final pw.Document doc = pw.Document();

    // Load the image from assets
    final Uint8List imageList = (await rootBundle.load('assets/ned_logo.png')).buffer.asUint8List();
    // Add one page with centered text "Hello World"
    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section with Logo and Title
              pw.Row(
                children: [
                  pw.Image(pw.MemoryImage(imageList), width: 100, height: 100),
                  pw.SizedBox(width: 20),
                  pw.Text('Attendance Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 20),

              // Attendance Information
              pw.Text('Course: $courseCode', style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Section: ${attendanceData['section']}', style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Session Date: ${attendanceData['date'].toDate().toLocal()}', style: const pw.TextStyle(fontSize: 16)),

              pw.SizedBox(height: 20),

              // Table with Absent and Present Students
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.IntrinsicColumnWidth(),
                  1: const pw.IntrinsicColumnWidth(),
                },
                children: [
                  pw.TableRow(children: [
                    pw.Text('Absent Students', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Present Students', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ]),
                  pw.TableRow(children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: (attendanceData['absentStudents'] as List<dynamic>)
                                  .map((dynamic student) {
                                    return pw.Text(student.toString());
                                  })
                                  .toList(),
                            ),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: (attendanceData['presentStudents'] as List<dynamic>)
                                  .map((dynamic student) {
                                    return pw.Text(student.toString());
                                  })
                                  .toList(),
                            ),
                          ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Build and return the final Pdf file data
    return await doc.save();
  }

  // save the pdf using provider in system path
  Future<void> savePdf(Uint8List pdfBytes) async {
    final granted = await PermissionHelper.requestStoragePermissions();
    if (!granted) {
      // Get the list of external storage directories
      Directory? directories = await getApplicationDocumentsDirectory();
      Directory generalDownloadDir = Directory('/storage/emulated/0/Download'); // THIS WORKS for android only !!!!!!

      // Check if there's a valid directory in the list
      // if (directories != null && directories.isNotEmpty) {
      // Use the first directory in the list
      // final Directory directory = directories[0];
      final String path = '${generalDownloadDir.path}/attendance_report.pdf';

      // Save the Pdf file
      final File file = File(path);
      await file.writeAsBytes(pdfBytes);

      // Show a notification
      showNotification(path);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved at: $path'),
            duration: Duration(seconds: 5) ,
          )
      );

    } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Writing Permission Denied, Allow from Settings'),
              duration: Duration(seconds: 5) ,
            )
        );
      }
    }
  }

  Future<void> showNotification(String pdfPath) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'basic_channel',
        title: 'PDF Generated',
        body: 'Tap to Open!',
        actionType: ActionType.Default,
        notificationLayout: NotificationLayout.BigText,
        payload: {'pdfPath': pdfPath},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'openPdfAction',
          label: 'Open PDF',
        ),
      ],
    );
  }

