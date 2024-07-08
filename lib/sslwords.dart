import 'package:flutter/material.dart';
import 'dart:convert'; // For base64 encoding
import 'package:http/http.dart' as http;

class Sslwordspage extends StatefulWidget {
  const Sslwordspage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SslwordspageState createState() => _SslwordspageState();
}

class _SslwordspageState extends State<Sslwordspage> {
  int currentWordId = 1; // Start with the first word
  String word = '';
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchWord(currentWordId);
  }

  Future<void> fetchWord(int id) async {
    final response =
        await http.get(Uri.parse('http://192.168.1.31:3000/word/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        word = data['word'];
        imageUrl = data['image'];

        currentWordId = data['id'];
      });
    } else {
      // Handle error
    }
  }

  Future<void> fetchNextWord() async {
    final response = await http
        .get(Uri.parse('http://192.168.1.31:3000/word/next/$currentWordId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        word = data['word'];
        imageUrl = data['image'];

        currentWordId = data['id'];
      });
    } else {
      // Handle error
    }
  }

  Future<void> fetchPrevWord() async {
    final response = await http
        .get(Uri.parse('http://192.168.1.31:3000/word/prev/$currentWordId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        word = data['word'];
        imageUrl = data['image'];

        currentWordId = data['id'];
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 255, 183, 77), // Light Orange
        title: const Text(
          'සිංහල සංඥා භාෂා වචන',
          style: TextStyle(
            fontFamily: 'Yasarath',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color.fromARGB(255, 248, 246, 246),
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 3.0,
                color: Color.fromARGB(96, 0, 0, 0),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      word,
                      style: const TextStyle(fontSize: 36),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: imageUrl.isNotEmpty
                        ? Image.memory(
                            base64Decode(imageUrl),
                            width: 200,
                            height: 250,
                          )
                        : const CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: fetchPrevWord,
                        child: const Text('පෙර වචනය'),
                      ),
                      ElevatedButton(
                        onPressed: fetchNextWord,
                        child: const Text('ඊළඟ වචනය'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
