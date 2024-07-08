import 'package:flutter/material.dart';
import 'dart:convert'; // For base64 encoding
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class SslNumbersPage extends StatefulWidget {
  const SslNumbersPage({super.key});

  @override
  SslNumbersPageState createState() => SslNumbersPageState();
}

class SslNumbersPageState extends State<SslNumbersPage> {
  final Logger logger = Logger('SslNumbersPageLogger');
  int currentNumberId = 1; // Start with the first number
  String number = '';
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchNumber(currentNumberId);
  }

  Future<void> fetchNumber(int id) async {
    final response =
        await http.get(Uri.parse('http://192.168.1.31:3000/number/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        number = data['number'].toString();
        imageUrl = data['image'];
        currentNumberId = data['id'];
      });
    } else {
      // Handle error
      logger.severe('අංකය පූරණය කිරීමට අසමත් විය');
    }
  }

  Future<void> fetchNextNumber() async {
    final response = await http.get(
        Uri.parse('http://192.168.1.31:3000/number/next/$currentNumberId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        number = data['number'].toString();
        imageUrl = data['image'];
        currentNumberId = data['id'];
      });
    } else {
      // Handle error
      logger.severe('ඊළඟ අංකය පූරණය කිරීමට අසමත් විය');
    }
  }

  Future<void> fetchPrevNumber() async {
    final response = await http.get(
        Uri.parse('http://192.168.1.31:3000/number/prev/$currentNumberId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        number = data['number'].toString();
        imageUrl = data['image'];
        currentNumberId = data['id'];
      });
    } else {
      // Handle error
      logger.severe('පෙර අංකය පූරණය කිරීමට අසමත් විය');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 255, 183, 77), // Light Orange
        title: const Text(
          'සිංහල සංඥා භාෂා ඉලක්කම්',
          style: TextStyle(
            fontFamily: 'Yasarath',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color.fromARGB(255, 248, 246, 246),
            shadows: [
              Shadow(
                offset: Offset(2.0, 1.0),
                blurRadius: 10.0,
                color: Color.fromARGB(255, 5, 5, 5),
              ),
            ],
          ),
        ),
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
                      number,
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
                          onPressed: fetchPrevNumber,
                          child: const Text('පෙර අංකය'),
                        ),
                      ),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: fetchNextNumber,
                          child: const Text('ඊළඟ අංකය'),
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
