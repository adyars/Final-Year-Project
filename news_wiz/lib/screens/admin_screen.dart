import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:news_wiz/model/admin_model.dart';
import 'package:news_wiz/screens/reported_news.dart';

import '../widgets/custom_drawer.dart';
import 'login_screen.dart';

class AdminScreen extends StatelessWidget {
  final String adminUsername;
  AdminModel loggedInAdmin = AdminModel(adminUsername: '');

  AdminScreen({required this.adminUsername});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Profile'),
      ),
      drawer: CustomDrawer(
        onLogout: () => logout(context),
        profilePictureUrl: loggedInAdmin.profilePictureUrl,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
              backgroundColor:
                  Colors.grey, // You can change the background color if needed
            ),
            SizedBox(height: 20),
            Text(
              adminUsername,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportedNewsList(),
                  ),
                );
              },
              child: Text('Reported News'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
}
