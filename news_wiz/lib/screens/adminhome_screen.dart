import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:news_wiz/model/admin_model.dart';
import 'package:news_wiz/model/home_display_model.dart';
import 'package:news_wiz/model/result_model.dart';
import 'package:news_wiz/screens/resultpage_screen.dart';
import 'package:news_wiz/screens/user_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/bottom_nav_bar_admin.dart';
import '../widgets/custom_drawer.dart';
import 'package:news_wiz/screens/validate_screen.dart';

List<HomeResult> savedData = [];

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  static const routeName = '/HomeScreen';
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  User? admin = FirebaseAuth.instance.currentUser;
  AdminModel loggedInUser = AdminModel(adminUsername: '');

  Future<void> _deleteNewsArticle(String articleTitle) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Reference to the 'saved_collection' collection
      CollectionReference userCollection =
          firestore.collection('saved_collection');

      // Find the document corresponding to the article title
      QuerySnapshot querySnapshot =
          await userCollection.where('title', isEqualTo: articleTitle).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot docSnapshot = querySnapshot.docs.first;
        await userCollection.doc(docSnapshot.id).delete();

        // Refresh savedData after deletion
        _refreshData();
      }
    } catch (e) {
      print('Error deleting news article: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("admin")
        .doc(admin!.uid)
        .get()
        .then((value) {
      this.loggedInUser = AdminModel.fromMap(value.data());
      setState(() {});
    });

    // Fetch and populate the savedData list from the Firestore 'user_data' collection
    fetchSavedData().then((data) {
      setState(() {
        savedData = data;
      });
    });
  }

  Future<bool> hasLikedArticle(String articleTitle) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        final FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Reference to the 'Liked_news' collection under the user's ID
        CollectionReference likedNewsCollection =
            firestore.collection('users').doc(uid).collection('Liked_news');

        // Check if there is a document with the given article title
        QuerySnapshot querySnapshot = await likedNewsCollection
            .where('title', isEqualTo: articleTitle)
            .get();

        return querySnapshot.docs.isNotEmpty;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking liked article: $e');
      return false;
    }
  }

  Future<void> _refreshData() async {
    // Fetch and populate the savedData list from the Firestore 'user_data' collection
    List<HomeResult> refreshedData = await fetchSavedData();

    setState(() {
      savedData = refreshedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: CustomDrawer(
        onLogout: () => logout(context),
        profilePictureUrl: loggedInUser.profilePictureUrl,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ValidateScreen(),
            ),
          );
        },
        tooltip: 'Validate News',
        child: Icon(Icons.search),
      ),
      bottomNavigationBar: BottomNavBar(
        index: 0,
        loggedInAdmin: loggedInUser,
      ),
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          itemCount: savedData.length,
          itemBuilder: (context, index) {
            HomeResult homeResult = savedData[index];
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ListTile(
                title: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultsPage(
                          textTitle: homeResult.displaytitle,
                          results: homeResult.results,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          homeResult.displaytitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: FutureBuilder<bool>(
                                future:
                                    hasLikedArticle(homeResult.displaytitle),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Icon(
                                      Icons.favorite_border,
                                      color: Colors.grey,
                                    );
                                  } else if (snapshot.hasError) {
                                    return Icon(
                                      Icons.favorite_border,
                                      color: Colors.grey,
                                    );
                                  } else {
                                    final bool isLiked = snapshot.data ?? false;
                                    return Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isLiked ? Colors.red : Colors.grey,
                                    );
                                  }
                                },
                              ),
                              onPressed: () async {
                                bool hasLiked = await hasLikedArticle(
                                    homeResult.displaytitle);
                                setState(() {
                                  if (hasLiked) {
                                    homeResult.likes -= 1;
                                  } else {
                                    homeResult.likes += 1;
                                  }
                                });

                                // Update likes to the database
                                updateLikesInDatabase(homeResult);
                                createLikedNewsCollection(homeResult);
                              },
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(
                                      context,
                                      homeResult.displaytitle,
                                    );
                                  },
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    // Implement report functionality here
                                    reportArticle(homeResult.displaytitle);
                                  },
                                  icon: Icon(Icons.report),
                                  label: Text('Report'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String title) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete News Article'),
          content: Text('Are you sure you want to delete this news article?'),
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
                await _deleteNewsArticle(title);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> reportArticle(String articleTitle) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Reference to the 'reported_articles' collection
      CollectionReference reportedArticlesCollection =
          firestore.collection('reported_news');

      // Find the document corresponding to the article title
      QuerySnapshot querySnapshot = await reportedArticlesCollection
          .where('title', isEqualTo: articleTitle)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Add the report data to the 'reported_articles' collection
        await reportedArticlesCollection.add({
          'title': articleTitle,
          'reportCount': 1, // Initialize report count to 1
        });
      } else {
        DocumentSnapshot docSnapshot = querySnapshot.docs.first;
        int reportCount = docSnapshot['reportCount'] as int? ?? 0;

        // Increment the report count and update the document
        await reportedArticlesCollection
            .doc(docSnapshot.id)
            .update({'reportCount': reportCount + 1});
      }
    } catch (e) {
      print('Error reporting article: $e');
    }
  }

  Future<void> createLikedNewsCollection(HomeResult homeResult) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        final FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Reference to the 'Liked_news' collection under the user's ID
        CollectionReference likedNewsCollection =
            firestore.collection('users').doc(uid).collection('Liked_news');

        // Find the document corresponding to the homeResult
        QuerySnapshot querySnapshot = await likedNewsCollection
            .where('title', isEqualTo: homeResult.displaytitle)
            .get();

        if (querySnapshot.docs.isEmpty) {
          // Convert the results list to a format that can be stored in Firestore
          List<Map<String, dynamic>> resultsData = homeResult.results
              .map((result) => result.toJson()) // Convert ResultData to JSON
              .toList();

          // Add the liked news data to the 'Liked_news' collection
          await likedNewsCollection.add({
            'title': homeResult.displaytitle,
            'likes': homeResult.likes,
            'results': resultsData, // Store the results list
          });
        }
      }
    } catch (e) {
      print('Error updating likes: $e');
    }
  }

  Future<void> updateLikesInDatabase(HomeResult homeResult) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Reference to the 'saved_collection' collection under the user's ID
        CollectionReference userCollection =
            firestore.collection('saved_collection');

        // Find the document corresponding to the homeResult
        QuerySnapshot querySnapshot = await userCollection
            .where('title', isEqualTo: homeResult.displaytitle)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot docSnapshot = querySnapshot.docs.first;
          Map<String, dynamic> docData =
              docSnapshot.data() as Map<String, dynamic>;

          // Update the likes count in the document
          docData['likes'] = homeResult.likes;

          // Convert the results list to a format that can be stored in Firestore
          List<Map<String, dynamic>> resultsData = homeResult.results
              .map((result) => result.toJson()) // Convert ResultData to JSON
              .toList();
          docData['results'] = resultsData;

          // Update the document in the 'saved_collection' collection
          await userCollection.doc(docSnapshot.id).update(docData);
        }
      }
    } catch (e) {
      print('Error updating likes: $e');
    }
  }

  Future<List<HomeResult>> fetchSavedData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        final FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Reference to the 'user_data' collection under the user's ID
        CollectionReference userCollection =
            firestore.collection('saved_collection');

        // Get the documents from the 'user_data' collection
        QuerySnapshot querySnapshot = await userCollection.get();

        List<HomeResult> homeResultsList = [];

        // Loop through the documents
        querySnapshot.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Retrieve 'title' from the data
          String disptitle = data['title'] as String? ?? '';
          String userUid = data['uid'] as String? ?? '';

          // Retrieve 'results' list from the data
          List<dynamic> resultsData = data['results'];

          if (resultsData != null) {
            // Convert 'resultsData' to a List<ResultData>
            List<ResultData> results = resultsData
                .map((result) => ResultData(
                      score: result['score'] as int? ?? 0,
                      title: result['title'] as String? ?? '',
                      link: result['link'] as String? ?? '',
                      image: result['image'] as String? ?? '',
                    ))
                .toList();

            // Create a new HomeResult instance from the data and add it to the list
            HomeResult homeResult = HomeResult(
              displaytitle: disptitle,
              userUid: userUid,
              results: results,
            );
            homeResultsList.add(homeResult);
          }
        });

        return homeResultsList;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching saved data: $e');
      return []; // Return an empty list in case of an error
    }
  }
}
