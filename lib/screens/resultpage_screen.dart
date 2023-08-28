import 'package:flutter/material.dart';
import 'package:news_wiz/model/result_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultsPage extends StatelessWidget {
  final String textTitle;
  final List<ResultData> results;

  ResultsPage({required this.textTitle, required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(textTitle)),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          ResultData resultData = results[index];
          return ListTile(
            leading: Container(
              width: 80, // Specify the width of the box here
              height: 80, // Specify the height of the box here
              child: Image.network(
                resultData.image,
                fit: BoxFit.cover, // Adjust the image to fit the box
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(resultData.title),
                ),
                Text('${resultData.score}%'),
              ],
            ),
            onTap: () {
              String link = resultData.link;
              _launchURL(link);
            },
          );
        },
      ),
    );
  }

  void _launchURL(String link) async {
    Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $link';
    }
  }
}
