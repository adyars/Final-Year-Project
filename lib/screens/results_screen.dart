import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:news_wiz/model/result_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultsScreen extends StatelessWidget {
  final List<ResultData> results;
  final String textTitle;
  const ResultsScreen(
      {Key? key, required this.results, required this.textTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              saveDataToFirebase(textTitle, results);
              Future.delayed(Duration(seconds: 2), () {
                saveHistoryDataToFirebase(textTitle, results);
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              String link = results[index].link;
              _launchURL(link);
            },
            child: Container(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    results[index].image,
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      results[index].title,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Text(results[index].score.toString()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _launchURL(String link) async {
    Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $link';
    }
  }
}

Future<void> saveDataToFirebase(String title, List<ResultData> results) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;

      // Firestore instance
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Reference to the collection under the user's ID
      CollectionReference userCollection =
          firestore.collection('saved_collection');

      // Create a new document with a unique ID
      DocumentReference documentRef = await userCollection.add({
        'title': title,
        'uid': uid,
        'results': results.map((result) => result.toJson()).toList(),
      });

      Fluttertoast.showToast(msg: 'Data saved successfully!');
    } else {
      Fluttertoast.showToast(msg: 'User not logged in');
    }
  } catch (e) {
    Fluttertoast.showToast(msg: 'Failed to save data: $e');
  }
}

Future<void> saveHistoryDataToFirebase(
    String title, List<ResultData> results) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;

      // Firestore instance
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Reference to the document under the user's ID in the 'users' collection
      DocumentReference userDocument = firestore.collection('users').doc(uid);

      // Reference to the subcollection 'saved_news' under the user's document
      CollectionReference userCollection =
          userDocument.collection('saved_news');

      // Create a new document with a unique ID
      DocumentReference documentRef = await userCollection.add({
        'title': title,
        'uid': uid,
        'results': results.map((result) => result.toJson()).toList(),
      });

      Fluttertoast.showToast(msg: 'Data History saved successfully!');
    } else {
      Fluttertoast.showToast(msg: 'User not logged in');
    }
  } catch (e) {
    Fluttertoast.showToast(msg: 'Failed to save data: $e');
  }
}
