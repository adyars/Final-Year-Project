class AdminModel {
  String? adminUid;
  String? adminEmail;
  String adminUsername;
  String? profilePictureUrl;

  AdminModel(
      {this.adminUid,
      this.adminEmail,
      required this.adminUsername,
      this.profilePictureUrl});

  factory AdminModel.fromMap(map) {
    return AdminModel(
      adminUid: map['adminUid'],
      adminEmail: map['adminEmail'],
      adminUsername: map['adminUsername'],
      profilePictureUrl: map['profilePictureUrl'], // Assign isAdmin property
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adminUid': adminUid,
      'adminEmail': adminEmail,
      'adminUsername': adminUsername,
      'profilePictureUrl': profilePictureUrl, // Include isAdmin in toMap method
    };
  }
}
