import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_wiz/model/home_display_model.dart';
import 'package:news_wiz/model/user_model.dart';
import 'package:news_wiz/screens/liked_news.dart';
import 'package:news_wiz/screens/login_screen.dart';
import 'package:news_wiz/screens/saved_news.dart';

class UserScreen extends StatelessWidget {
  final String username;

  UserScreen({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: FutureBuilder(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching data'),
            );
          } else {
            return UserDataLoaded(
              loggedInUser: snapshot.data as UserModel,
            );
          }
        },
      ),
    );
  }

  Future<UserModel> fetchUserData() async {
    try {
      // You may need to adapt this part based on how your user is fetched
      // from Firebase Authentication. Here, I'm assuming you use FirebaseAuth.
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        return UserModel.fromMap(userData.data()!);
      }
      throw Exception('User not found');
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }
}

class UserDataLoaded extends StatefulWidget {
  final UserModel loggedInUser;

  UserDataLoaded({required this.loggedInUser});

  @override
  _UserDataLoadedState createState() => _UserDataLoadedState();
}

class _UserDataLoadedState extends State<UserDataLoaded> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  List<HomeResult> savedResults = []; // Store the saved results

  void saveArticle(HomeResult homeResult) {
    // ... Your existing saveArticle function ...

    // Add the saved article to the savedResults list
    setState(() {
      savedResults.add(homeResult);
    });
  }

  List<HomeResult> likedResults = []; // Store the liked results

  void likeArticle(HomeResult homeResult) {
    // ... Your existing likeArticle function ...

    // Add the liked article to the likedResults list
    setState(() {
      likedResults.add(homeResult);
    });
  }

  void updateUsername(String newUsername) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'username': newUsername,
        });

        // Update the local logged-in user data
        setState(() {
          widget.loggedInUser.username = newUsername;
        });

        // Show a snackbar to inform the user about the update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Username updated successfully!'),
          ),
        );
      }
    } catch (e) {
      print("Error updating username: $e");
    }
  }

  void updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);

        // Show a snackbar to inform the user about the update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password updated successfully!'),
          ),
        );
      }
    } catch (e) {
      print("Error updating password: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
            backgroundColor: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            widget.loggedInUser.username,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // Show a dialog for the user to enter a new username
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Edit Profile'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (newUsername) {
                          widget.loggedInUser.username = newUsername;
                        },
                        decoration: InputDecoration(labelText: 'New Username'),
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        // Close the dialog
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Update the username and close the dialog
                        updateUsername(widget.loggedInUser.username);
                        Navigator.of(context).pop();
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              );
            },
            child: Text('Edit Profile'),
          ),
          ElevatedButton(
            onPressed: () {
              // Show a dialog for the user to enter a new password
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Change Password'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _passwordController,
                        onChanged: (newPassword) {
                          // You can also update the local variable, but it's not necessary in this case
                          // newPassword = newPassword;
                        },
                        decoration: InputDecoration(labelText: 'New Password'),
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        // Close the dialog
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Update the password and close the dialog
                        updatePassword(_passwordController.text);
                        Navigator.of(context).pop();
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              );
            },
            child: Text('Change Password'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedNewsScreen(),
                ),
              );
            },
            child: Text('Saved News'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LikedNewsScreen(),
                ),
              );
            },
            child: Text('Liked News'),
          ),
        ],
      ),
    );
  }
}

Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
}
