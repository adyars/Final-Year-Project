// import 'package:flutter/material.dart';
// import 'package:news_wiz/widgets/custom_tag.dart';
// import 'package:news_wiz/widgets/image_container.dart';

// import '../model/article_model.dart';

// class NewsOftheDay extends StatelessWidget {
//   const NewsOftheDay({
//     Key? key,
//     required this.article,
//   }) : super(key: key);

//   final Article article;

//   @override
//   Widget build(BuildContext context) {
//     return ImageContainer(
//       height: MediaQuery.of(context).size.height * 0.45,
//       width: double.infinity,
//       imageUrl: article.imageUrl,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CustomTag(backgroundColor: Colors.grey.withAlpha(150), children: [
//             Text(
//               'News of the Day',
//               style: Theme.of(context).textTheme.headlineSmall!.copyWith(
//                   fontWeight: FontWeight.bold,
//                   height: 1.25,
//                   color: Colors.white),
//             )
//           ]),
//           Text(
//             article.title,
//             style: Theme.of(context)
//                 .textTheme
//                 .bodyMedium!
//                 .copyWith(color: Colors.white),
//           ),
//           TextButton(
//             onPressed: () {},
//             style: TextButton.styleFrom(padding: EdgeInsets.zero),
//             child: Row(
//               children: [
//                 Text(
//                   'Learn More',
//                   style: Theme.of(context).textTheme.bodyLarge!.copyWith(
//                         color: Colors.white,
//                       ),
//                 ),
//                 const SizedBox(width: 10),
//                 const Icon(
//                   Icons.arrow_right_alt,
//                   color: Colors.white,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
