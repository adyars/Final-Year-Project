import 'package:flutter/material.dart';
import 'package:news_wiz/screens/article_screen.dart';
import 'package:news_wiz/screens/home_screen.dart';
import '../model/user_model.dart';
import '../screens/admin_screen.dart';
import '../screens/user_screen.dart';
import '../model/admin_model.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    Key? key,
    required this.index,
    required this.loggedInUser,
  }) : super(key: key);

  final int index;
  final UserModel loggedInUser;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      showSelectedLabels: false,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black.withAlpha(100),
      items: [
        BottomNavigationBarItem(
          icon: Container(
            margin: const EdgeInsets.only(left: 0),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, HomeScreen.routeName);
              },
              icon: const Icon(Icons.home),
            ),
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, ArticleScreen.routeName);
            },
            icon: const Icon(Icons.search),
          ),
          label: "Search",
        ),
        BottomNavigationBarItem(
          icon: Container(
            margin: const EdgeInsets.only(right: 0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserScreen(
                      username: loggedInUser.username,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person),
            ),
          ),
          label: "Profile",
        ),
      ],
    );
  }
}
