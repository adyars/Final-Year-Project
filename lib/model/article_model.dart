import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:news_wiz/model/result_model.dart';

class Article extends Equatable {
  final String title;
  final String imageUrl;
  final String link;
  final int tag;

  const Article({
    required this.title,
    required this.imageUrl,
    required this.link,
    required this.tag,
  });

  static List<Article> articles = [];

  // Method to fetch articles from multiple collections in Firestore and populate the articles list
  static Future<void> fetchArticlesFromFirestore() async {
    // In this example, we use the cloud_firestore library to fetch data from Firestore

    // List of collection names to fetch data from
    List<String> collectionNames = [
      'Bencana',
      'Consumer',
      'Crime',
      'Economy',
      'Education',
      'Gov',
      'Health',
      'Safety',
      'Transport',
    ];

    // Fetch data from each collection and merge the results
    List<Future<QuerySnapshot>> futures = [];
    for (String collectionName in collectionNames) {
      CollectionReference collection =
          FirebaseFirestore.instance.collection(collectionName);
      futures.add(collection.get());
    }

    // Wait for all the queries to complete
    List<QuerySnapshot> snapshots = await Future.wait(futures);

    // Merge the results and update the articles list
    List<Article> mergedArticles = [];
    for (var snapshot in snapshots) {
      List<Article> collectionArticles = snapshot.docs.map((documentSnapshot) {
        Map<String, dynamic> articleData =
            documentSnapshot.data() as Map<String, dynamic>;
        return Article(
          title: articleData['Title'] as String,
          imageUrl: articleData['Image'] as String,
          link: articleData['Link'] as String,
          tag: articleData['Tag'] as int,
        );
      }).toList();
      mergedArticles.addAll(collectionArticles);
    }

    // Update the static articles list
    articles = mergedArticles;
  }

  @override
  List<Object?> get props => [title, imageUrl, link, tag];
}

Future<List<Article>> fetchSavedData() async {
  List<Article> savedData = [];
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<dynamic> results = data['results'];
      results.forEach((result) {
        Article article = Article(
          title: result['title'] as String,
          imageUrl: result['imageUrl'] as String,
          link: result['link'] as String,
          tag: result['tag'] as int,
        );
        savedData.add(article);
      });
    });
  } catch (e) {
    print('Error fetching saved data: $e');
  }

  return savedData;
}
