import 'package:flutter/material.dart';
import 'dart:convert'; // For base64 encoding
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class SslPage extends StatefulWidget {
  const SslPage({super.key});

  @override
  SslPageState createState() => SslPageState();
}

class SslPageState extends State<SslPage> {
  final Logger logger = Logger('SslPageLogger');
  int currentLetterId = 1; // Start with the first letter
  String letter = '';
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchLetter(currentLetterId);
  }

  Future<void> fetchLetter(int id) async {
    final response =
        await http.get(Uri.parse('http://192.168.1.31:3000/letter/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        letter = data['letter'];
        imageUrl = data['image'];
        currentLetterId = data['id'];
      });
    } else {
      // Handle error
      logger.severe('ලිපිය පූරණය කිරීමට අසමත් විය');
    }
  }

  Future<void> fetchNextLetter() async {
    final response = await http.get(
        Uri.parse('http://192.168.1.31:3000/letter/next/$currentLetterId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        letter = data['letter'];
        imageUrl = data['image'];
        currentLetterId = data['id'];
      });
    } else {
      // Handle error
      logger.severe('ඊළඟ අකුර පූරණය කිරීමට අසමත් විය');
    }
  }

  Future<void> fetchPrevLetter() async {
    final response = await http.get(
        Uri.parse('http://192.168.1.31:3000/letter/prev/$currentLetterId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        letter = data['letter'];
        imageUrl = data['image'];
        currentLetterId = data['id'];
      });
    } else {
      // Handle error
      logger.severe('පෙර අකුර පූරණය කිරීමට අසමත් විය');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 255, 183, 77), // Light Orange
        title: const Text(
          'සිංහල සංඥා භාෂා අකුරු',
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
          double imageSize =
              constraints.maxWidth * 0.8; // 80% of the screen width
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      letter,
                      style: const TextStyle(fontSize: 36),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: imageUrl.isNotEmpty
                        ? Image.memory(
                            base64Decode(imageUrl),
                            width: imageSize,
                            height: imageSize,
                          )
                        : const CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Flexible(
                        child: ElevatedButton(
                          onPressed: fetchPrevLetter,
                          child: const Text('කලින් අකුර '),
                        ),
                      ),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: fetchNextLetter,
                          child: const Text('ඊළඟ අකුර'),
                        ),
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
