import 'package:news_wiz/model/result_model.dart';

class HomeResult {
  final String displaytitle;
  final List<ResultData> results;
  final String userUid; // Make sure this is of type String and not String?
  int likes;

  HomeResult({
    required this.displaytitle,
    required this.results,
    required this.userUid, // Make sure this is not nullable
    this.likes = 0,
  });

  factory HomeResult.fromJson(Map<String, dynamic> json) {
    return HomeResult(
      displaytitle: json['title'] ?? '',
      userUid: json['uid'] ?? '',
      results: (json['results'] as List<dynamic>)
          .map((result) => ResultData.fromJson(result))
          .toList(),
      likes: json['likes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': displaytitle,
      'uid': userUid,
      'results': results.map((result) => result.toJson()).toList(),
      'likes': likes
    };
  }

  bool isLikedByCurrentUser(String currentUserId) {
    return userUid == currentUserId && likes > 0;
  }
}
