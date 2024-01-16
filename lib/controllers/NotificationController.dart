/*
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:share_plus/share_plus.dart';

class NotificationController {

  @pragma("vm:entry-point")
  Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyInput == 'openPdfAction') {
      // The user tapped the "Open PDF" action button
      String? pdfPath = receivedAction.payload?['pdfPath'];

      // Handle opening the PDF file
      // You can use a PDF viewer library or any other method to open the PDF
      // For simplicity, let's assume you have a method to open PDF using a package
      openPdfFile(pdfPath!);
    }
  }

  Future<void> openPdfFile(String pdfPath) async {
    // Use a PDF viewer library or open the file using a suitable viewer app
    try {
      await Share.shareFiles([pdfPath], text: 'Share PDF');
    } catch (e) {
      print('Error opening PDF: $e');
    }
  }
}*/
