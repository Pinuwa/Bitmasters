import 'package:flutter/material.dart';
import 'package:ssl_project/first.dart';
import 'package:ssl_project/progressMcq.dart';
import 'package:ssl_project/change_profile.dart';
import 'package:ssl_project/lesson.dart';
import 'package:ssl_project/progress_voice.dart';

class ProfilePage extends StatelessWidget {
  final int userId;

  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userId: userId)),
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 245, 231, 222),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 183, 77),
          title: const Text(
            'ප්‍රගති වාර්තාව',
            style: TextStyle(
              fontFamily: 'Yasarath',
              fontSize: 28,
              fontWeight: FontWeight.w800,
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'සිංහල සංඥා භාෂා බහුවරණ',
                style: TextStyle(
                  fontFamily: 'Yasarath',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 1.0),
                      blurRadius: 2.0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildProgressButton(
                context,
                'ප්‍රගතිය',
                ProgressMcq(userId: userId),
              ),
              const SizedBox(height: 40),
              const Text(
                'සිංහල වාචීක පුහුණුව',
                style: TextStyle(
                  fontFamily: 'Yasarath',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 1.0),
                      blurRadius: 2.0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildProgressButton(
                context,
                'ප්‍රගතිය',
                ProgressVoice(userId: userId),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeProfilePage(userId: userId),
                    ),
                  );
                },
                child: const Text('ගිණුම වෙනස් කරන්න'),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: IconButton(
                  icon: const Icon(Icons.logout, size: 30),
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressButton(
      BuildContext context, String buttonText, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(
          fontFamily: 'Yasarath',
          fontSize: 18,
          color: Colors.black,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('පිටවීම'),
          content: const Text('ඔබට අනිවාර්යයෙන්ම පිටවීමට අවශ්‍යද?'),
          actions: [
            TextButton(
              child: const Text('අවලංගු කරන්න'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('පිටවීම'),
              onPressed: () {
                // Perform logout logic here
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const firstpage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
