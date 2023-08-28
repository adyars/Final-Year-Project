import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:news_wiz/model/result_model.dart';
import 'package:news_wiz/screens/results_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ValidateScreen extends StatefulWidget {
  const ValidateScreen({Key? key}) : super(key: key);

  static const routeName = '/validate';

  @override
  State<ValidateScreen> createState() => _ValidateScreenState();
}

class _ValidateScreenState extends State<ValidateScreen> {
  final TextEditingController titleController = TextEditingController();
  int? _dropdownValue;
  List<ResultData> results = [];
  String textTitle = " ";

  void dropdownCallback(int? selectedValue) {
    if (selectedValue is int) {
      setState(() {
        _dropdownValue = selectedValue;
      });
    }
  }

  Future<void> stringSearch(String search, int tag) async {
    final String searchQuery = Uri.encodeComponent(search);
    final String tagQuery = tag.toString();
    final Uri url = Uri.parse(
        'https://newswiz.arfsd.cyou/?search=$searchQuery&tag=$tagQuery');

    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> dataList = jsonDecode(response.body);
      if (dataList != null && dataList.isNotEmpty) {
        List<ResultData> searchResults = dataList
            .map((data) => ResultData.fromJson(data as Map<String, dynamic>))
            .toList();

        setState(() {
          results = searchResults;
        });

        _showResultsScreen(textTitle, results);
        Fluttertoast.showToast(msg: 'Success');
      } else {
        Fluttertoast.showToast(msg: 'No results found');
      }
    } else {
      // Handle any errors or failed requests
      Fluttertoast.showToast(msg: 'Failed to load data');
    }
  }

  void _showResultsScreen(String textTitle, List<ResultData> results) {
    if (results.isEmpty) {
      print('No results found');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          results: results,
          textTitle: textTitle,
        ),
      ),
    );
  }

  // Fetch results from API
  Future<void> fetchResults() async {
    if (titleController.text.isNotEmpty && _dropdownValue != null) {
      textTitle = titleController.text;
      await stringSearch(titleController.text, _dropdownValue!);
    } else {
      // Handle the case when either the title or the dropdown value is not selected
      Fluttertoast.showToast(msg: 'Please enter a title and select a tag');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Title field
    final titleField = TextFormField(
      autofocus: false,
      controller: titleController,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter a title';
        }
        return null; // Return null if the input is valid
      },
      onSaved: (value) {
        titleController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.vpn_key),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Title",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    final dropdownButton = DropdownButton<int>(
      items: const [
        DropdownMenuItem(
          child: Text("Bencana"),
          value: 1,
        ),
        DropdownMenuItem(
          child: Text("Ekonomi"),
          value: 2,
        ),
        DropdownMenuItem(
          child: Text("Keselamatan"),
          value: 3,
        ),
        DropdownMenuItem(
          child: Text("Pendidikan"),
          value: 4,
        ),
        DropdownMenuItem(
          child: Text("Pengangkutan"),
          value: 5,
        ),
        DropdownMenuItem(
          child: Text("Urus Tadbir"),
          value: 6,
        ),
        DropdownMenuItem(
          child: Text("Jenayah"),
          value: 7,
        ),
        DropdownMenuItem(
          child: Text("Kesihatan"),
          value: 8,
        ),
        DropdownMenuItem(
          child: Text("Kepenggunaan"),
          value: 9,
        ),
      ],
      value: _dropdownValue,
      onChanged: dropdownCallback,
    );

    final submitButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.black,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          await fetchResults();
        },
        child: Text(
          "Submit",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 200,
                  ),
                  SizedBox(height: 45),
                  titleField,
                  SizedBox(height: 25),
                  dropdownButton,
                  SizedBox(height: 35),
                  submitButton,
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
