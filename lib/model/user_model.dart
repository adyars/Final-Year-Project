class UserModel {
  String? uid;
  String? email;
  String username;
  String? profilePictureUrl; // Add this property for the profile picture URL

  UserModel(
      {this.uid, this.email, required this.username, this.profilePictureUrl});

  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      username: map['username'],
      profilePictureUrl: map['profilePictureUrl'] as String?, // Cast to String?
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'profilePictureUrl': profilePictureUrl, // Make sure to add this line
    };
  }
}
