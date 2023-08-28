import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportedNewsScreen extends StatefulWidget {
  @override
  _ReportedNewsScreenState createState() => _ReportedNewsScreenState();
}

class _ReportedNewsScreenState extends State<ReportedNewsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reported News'),
      ),
      body: ReportedNewsList(),
    );
  }
}

class ReportedNewsList extends StatefulWidget {
  @override
  _ReportedNewsListState createState() => _ReportedNewsListState();
}

class _ReportedNewsListState extends State<ReportedNewsList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('reported_news').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No reported news.'),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((reportedNewsDoc) {
            String title = reportedNewsDoc['title'] as String? ?? '';
            int reportCount = reportedNewsDoc['reportCount'] as int? ?? 0;

            return ListTile(
              title: Text(title),
              subtitle: Text('Reports: $reportCount'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmationDialog(context, reportedNewsDoc.id);
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String docId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Reported News'),
          content: Text('Are you sure you want to delete this reported news?'),
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
                await _deleteReportedNews(docId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteReportedNews(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('reported_news')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reported news deleted successfully.')),
      );
    } catch (e) {
      print('Error deleting reported news: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting reported news.')),
      );
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: ReportedNewsScreen(),
  ));
}
