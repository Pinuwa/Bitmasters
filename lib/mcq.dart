import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Mcqpage extends StatefulWidget {
  final int userId;

  const Mcqpage({super.key, required this.userId});

  @override
  _McqpageState createState() => _McqpageState();
}

class _McqpageState extends State<Mcqpage> {
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  String selectedAnswer = '';
  int score = 0;
  String message = '';
  bool quizSubmitted = false; // Track if the quiz has been submitted

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.31:3000/random-questions'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          questions = data.map((json) => Question.fromJson(json)).toList();
          currentQuestionIndex = 0;
          selectedAnswer = '';
          score = 0;
          message = '';
          quizSubmitted = false;
        });
      } else {
        setState(() {
          message = 'Failed to load questions';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Error fetching questions: $e';
      });
      print('Error: $e');
    }
  }

  void checkAnswer(String answer) {
    if (answer == questions[currentQuestionIndex].correctAnswer) {
      score++;
    }
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = '';
        message = '';
      });
    } else {
      submitQuiz();
    }
  }

  Future<void> submitQuiz() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.31:3000/submit-quiz'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': widget.userId,
        'marks': score,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        message = getResultMessage(score);
        quizSubmitted = true;
      });
    } else {
      setState(() {
        message = 'ප්‍රශ්නාවලිය ඉදිරිපත් කිරීමට අසමත් විය';
      });
    }
  }

  String getResultMessage(int score) {
    if (score == 10) {
      return 'ප්‍රශ්නාවලිය ඉදිරිපත් කළා! ඔබේ ලකුණු: $score (විශිෂ්ටයි)';
    } else if (score >= 7) {
      return 'ප්‍රශ්නාවලිය ඉදිරිපත් කළා! ඔබේ ලකුණු: $score (හොඳින් කළා)';
    } else if (score >= 4) {
      return 'ප්‍රශ්නාවලිය ඉදිරිපත් කළා! ඔබේ ලකුණු: $score (හොඳයි )';
    } else if (score >= 1) {
      return 'ප්‍රශ්නාවලිය ඉදිරිපත් කළා! ඔබේ ලකුණු: $score (නරකයි)';
    } else {
      return 'ප්‍රශ්නාවලිය ඉදිරිපත් කළා! ඔබේ ලකුණු: $score (නරකම)';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ප්‍රශ්න පූරණය වෙමින්...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 231, 222),
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 255, 183, 77), // Light Orange
        title: const Text(
          'බහුවරණ ',
          style: TextStyle(
            fontFamily: 'Yasarath',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color.fromARGB(255, 248, 246, 246),
            shadows: [
              Shadow(
                offset: Offset(2.0, 1.0),
                blurRadius: 2.0,
                color: Colors.black,
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
                    child: currentQuestion.image.isNotEmpty
                        ? Image.memory(
                            base64Decode(currentQuestion.image),
                            height: 150,
                          )
                        : const CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currentQuestion.question,
                    style: const TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ...currentQuestion.options.map((option) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            minimumSize: const Size(200, 50),
                          ),
                          onPressed: () {
                            if (!quizSubmitted) {
                              setState(() {
                                selectedAnswer = option;
                              });
                              checkAnswer(option);
                            }
                          },
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      )),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  if (quizSubmitted)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(200, 50),
                      ),
                      onPressed: fetchQuestions,
                      child: const Text(
                        'නැවත උත්සාහ කරන්න',
                        style: TextStyle(fontSize: 20),
                      ),
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

class Question {
  final int id;
  final String question;
  final String image;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.id,
    required this.question,
    required this.image,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      image: json['image'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
    );
  }
}
