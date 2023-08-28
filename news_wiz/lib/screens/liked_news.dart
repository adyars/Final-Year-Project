import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_wiz/model/result_model.dart';
import 'package:url_launcher/url_launcher.dart';

class LikedNewsScreen extends StatefulWidget {
  @override
  _LikedNewsScreenState createState() => _LikedNewsScreenState();
}

class _LikedNewsScreenState extends State<LikedNewsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liked News'),
      ),
      body: LikedNewsList(),
    );
  }
}

class LikedNewsList extends StatefulWidget {
  @override
  _LikedNewsListState createState() => _LikedNewsListState();
}

class _LikedNewsListState extends State<LikedNewsList> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('Liked_news')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No liked news yet.'),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot likedNewsDoc = snapshot.data!.docs[index];
            Map<String, dynamic> data =
                likedNewsDoc.data() as Map<String, dynamic>;
            String title = data['title'] as String? ?? '';
            int likes = data['likes'] as int? ?? 0;
            List<dynamic> resultsData = data['results'];

            if (resultsData != null) {
              List<ResultData> results = resultsData
                  .map((result) => ResultData(
                        score: result['score'] as int? ?? 0,
                        title: result['title'] as String? ?? '',
                        link: result['link'] as String? ?? '',
                        image: result['image'] as String? ?? '',
                      ))
                  .toList();

              return ListTile(
                leading: Image.network(
                  results[0].image, // Assuming the first result's image is used
                  width: 50,
                  height: 50,
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(title)),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, likedNewsDoc.id);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LikedNewsDetail(
                        title: title,
                        results: results,
                      ),
                    ),
                  );
                },
              );
            }

            return SizedBox.shrink();
          },
        );
      },
    );
  }
}

Future<void> _showDeleteConfirmationDialog(
    BuildContext context, String title) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Liked Saved News'),
        content: Text('Are you sure you want to delete this Liked news?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () async {
              await _deleteSavedNews(title);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> _deleteSavedNews(String docId) async {
  try {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      print('User UID: ${user.uid}');
      print('Deleting document with title: $docId'); // Printing for debugging
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('liked_news')
          .doc(
              docId) // Use the provided 'title' to specify the document to delete
          .delete();
      print('Document deleted successfully');
    }
  } catch (e) {
    print('Error deleting saved news: $e');
  }
}

class LikedNewsDetail extends StatelessWidget {
  final String title;
  final List<ResultData> results;

  LikedNewsDetail({required this.title, required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          ResultData result = results[index];
          return ListTile(
            title: Text(result.title),
            subtitle: Text('Score: ${result.score}'),
            onTap: () {
              String link = result.link;
              _launchURL(link);
            },
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
