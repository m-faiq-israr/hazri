import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


import '../global/topBar.dart';

class AttendanceScreen extends StatelessWidget {
  final String courseId;
  final String sessionDocumentId;

  const AttendanceScreen({super.key, required this.courseId, required this.sessionDocumentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(screenName: "TEACHER"),
      floatingActionButton: FloatingActionButton(
          tooltip: 'Print Document',
          onPressed: () async {
            Uint8List pdfBytes = await buildPdf();
            await savePdf(pdfBytes);
            // Handle the generated PDF data as needed (e.g., save it, send it, etc.)
            // For now, you can print the length of the generated PDF data
            print('PDF Length: ${pdfBytes.length}');
            },
          child: const Icon(Icons.print),
        ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .doc('SE-312')
            .collection('session')
            .doc(sessionDocumentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Loading indicator while data is being fetched
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text('No data found'); // Handle the case where the document doesn't exist
          }

          // Access the attendance data from the snapshot
          Map<String, dynamic> attendanceData = snapshot.data!.data() as Map<String, dynamic>;

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
}

  //generate the pdf
  Future<Uint8List> buildPdf() async {
    // Create the Pdf document
    final pw.Document doc = pw.Document();

    // Add one page with centered text "Hello World"
    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.ConstrainedBox(
            constraints: const pw.BoxConstraints.expand(),
            child: pw.FittedBox(
              child: pw.Text('Hello World'),
            ),
          );
        },
      ),
    );

    // Build and return the final Pdf file data
    return await doc.save();
  }

  //save the pdf using provider in system path
  Future<void> savePdf(Uint8List pdfBytes) async {
     // Get the list of external storage directories
      List<Directory>? directories = await getExternalStorageDirectories();

      // Check if there's a valid directory in the list
      if (directories != null && directories.isNotEmpty) {
        // Use the first directory in the list
        final Directory directory = directories[0];
        final String path = '${directory.path}/attendance_report.pdf';

        // Save the Pdf file
        final File file = File(path);
        await file.writeAsBytes(pdfBytes);


        print('PDF saved at: $path');
      } else {
        print('Error: Unable to find external storage directory.');
      }
  }
