import 'package:flutter/material.dart';
import 'package:news_wiz/widgets/custom_tag.dart';
import 'package:news_wiz/model/article_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({Key? key});

  static const routeName = '/article';

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Article> articles = [];
  List<int> tags = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  @override
  void initState() {
    super.initState();
    // Fetch articles from Firestore and update the articles list
    Article.fetchArticlesFromFirestore().then((_) {
      setState(() {
        articles = Article.articles;
      });
    });
  }

  void filterArticles(String query) {
    setState(() {
      articles = Article.articles
          .where((article) =>
              article.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Wiz'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: ArticleSearchDelegate(),
              );
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tagId = tags[index];
          final categoryArticles =
              articles.where((article) => article.tag == tagId).toList();
          return _CategoryArticles(
            categoryTag: tagId,
            categoryArticles: categoryArticles,
          );
        },
      ),
    );
  }
}

class _ArticleItem extends StatelessWidget {
  const _ArticleItem({Key? key, required this.article}) : super(key: key);

  final Article article;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _launchURL(article.link);
      },
      child: Container(
        width: MediaQuery.of(context).size.width *
            0.8, // Set a fixed width for each article item
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                article.imageUrl,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTag(
                    backgroundColor: Colors.grey.withAlpha(150),
                    children: [
                      const SizedBox(height: 10),
                      Flexible(
                        child: Text(
                          article.title,
                          maxLines:
                              2, // Allow title to occupy at most two lines
                          overflow: TextOverflow
                              .ellipsis, // Show ellipsis if text overflows
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    height: 1.25,
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to launch URL in the browser
  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class _CategoryArticles extends StatelessWidget {
  const _CategoryArticles({
    Key? key,
    required this.categoryTag,
    required this.categoryArticles,
  }) : super(key: key);

  final int categoryTag;
  final List<Article> categoryArticles;

  @override
  Widget build(BuildContext context) {
    final categoryName = _getCategoryName(categoryTag);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            categoryName,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final article in categoryArticles)
                _ArticleItem(article: article),
            ],
          ),
        ),
      ],
    );
  }

  String _getCategoryName(int tagId) {
    switch (tagId) {
      case 1:
        return 'Bencana';
      case 2:
        return 'Ekonomi';
      case 3:
        return 'Keselamatan';
      case 4:
        return 'Pendidikan';
      case 5:
        return 'Pengangkutan';
      case 6:
        return 'Kerajaan';
      case 7:
        return 'Jenayah';
      case 8:
        return 'Kesihatan';
      case 9:
        return 'Produk';
      default:
        return '';
    }
  }
}

class ArticleSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement the search results UI based on the query
    // Here, we'll filter the articles based on the search query and display them as search results.
    final List<Article> searchResults = Article.articles
        .where((article) =>
            article.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final article = searchResults[index];
        return _ArticleItem(article: article);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement the suggestions UI based on the query
    // Here, we'll provide a simple ListView of ListTile widgets with suggested search queries.
    final List<String> suggestedQueries = [
      'Bencana',
      'Ekonomi',
      'Keselamatan',
      'Pendidikan',
      'Pengangkutan',
      'Kerajaan',
      'Jenayah',
      'Kesihatan',
      'Produk',
    ];

    final List<String> filteredSuggestions = suggestedQueries
        .where((suggestion) =>
            suggestion.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) {
        final suggestion = filteredSuggestions[index];
        return ListTile(
          title: Text(suggestion),
          onTap: () {
            // When a suggestion is tapped, fill the search query with the selected suggestion
            query = suggestion;
          },
        );
      },
    );
  }
}
