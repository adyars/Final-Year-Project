class ResultData {
  final int score;
  final String title;
  final String link;
  final String image;

  ResultData({
    required this.score,
    required this.title,
    required this.link,
    required this.image,
  });

  factory ResultData.fromJson(Map<String, dynamic> json) {
    return ResultData(
      score: json['Score'],
      title: json['Title'],
      link: json['link'],
      image: json['image'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'title': title,
      'link': link,
      'score': score,
      // Add other properties you want to include in the JSON representation
    };
  }
}
