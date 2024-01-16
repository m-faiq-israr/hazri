// @dart=2.9

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hazri/firebase_options.dart';
import 'package:hazri/screens/LoginPage.dart';
//import 'package:share_plus/share_plus.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();


  /*final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  await requestUserPermissions(
    context:  navigatorKey.currentContext!,
    channelKey: 'basic_channel',
    permissionList: [NotificationPermission.Default],
  );*/
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
  if (!isAllowed) {
    // This is just a basic example. For real apps, you must show some
    // friendly dialog box before call the request method.
    // This is very important to not harm the user experience
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
});

  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic notifications',
        defaultColor: const Color(0xFF9DD1F1),
        ledColor: Colors.white,
      ),
    ],
  );



  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( const MyApp(),);
}

/*
Future<void> openPdfFile(String pdfPath) async {
  // Use a PDF viewer library or open the file using a suitable viewer app
  try {
    await Share.shareFiles([pdfPath], text: 'Share PDF');
  } catch (e) {
    print('Error opening PDF: $e');
  }
}
*/

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      // theme: Provider.of<ThemeProvider>(context).themeData
    );
  }
}

