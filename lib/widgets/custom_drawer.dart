import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    Key? key,
    required this.onLogout,
    required this.profilePictureUrl,
  }) : super(key: key);

  final VoidCallback onLogout;
  final String? profilePictureUrl;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  child: profilePictureUrl != null
                      ? Image.network(
                          profilePictureUrl!,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons
                          .person), // Use an icon if no profile picture URL is available
                ),
                SizedBox(height: 10),
                Text(
                  "Welcome",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
