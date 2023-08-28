import 'package:news_wiz/screens/admin_screen.dart';
import 'package:news_wiz/screens/article_screen.dart';
import 'package:news_wiz/screens/home_screen.dart';
import 'package:news_wiz/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:news_wiz/screens/registration_screen.dart';
import 'package:news_wiz/screens/results_screen.dart';
import 'package:news_wiz/screens/validate_screen.dart';
import 'firebase_options.dart';
import 'model/result_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);

  runApp(MyApp(
    results: const [],
  ));
}

class MyApp extends StatelessWidget {
  final List<ResultData> results;

  MyApp({required this.results});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NewsWiz',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      // debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegistrationScreen.routeName: (context) => const RegistrationScreen(),
        ValidateScreen.routeName: (context) => const ValidateScreen(),
        ArticleScreen.routeName: (context) => const ArticleScreen(),
      },
    );
  }
}
