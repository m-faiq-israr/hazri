import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hazri/global/styles.dart';

import '../screens/LoginPage.dart';


class TopBar extends StatelessWidget implements PreferredSizeWidget{

  final String screenName;

  const TopBar({super.key, required, required this.screenName});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
            screenName,
            style: GoogleFonts.ubuntu(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.secondaryColor,
          centerTitle: true,
          shadowColor: Colors.blueGrey,
          leading: const Icon(
            Icons.person,
            color: Colors.white,
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                }).onError((error, stackTrace) {
                  print("Error");
                });
              },
            ),
          ],
    );
  }
}


