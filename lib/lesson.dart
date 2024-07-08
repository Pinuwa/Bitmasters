import 'package:flutter/material.dart';
import 'package:ssl_project/mcq.dart';
import 'package:ssl_project/practice.dart';
import 'package:ssl_project/voice.dart';
import 'sslnumbers.dart';
import 'sslwords.dart';
import 'ssl.dart';
import 'search.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  final int userId;

  const HomePage({super.key, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const LessonScreen(),
      const SearchPage(),
      Mcqpage(userId: widget.userId), // Pass userId to Mcqpage
      VoicePage(userId: widget.userId),
      ProfilePage(userId: widget.userId), // Pass userId to ProfilePage
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 231, 222),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            const Color.fromARGB(255, 255, 183, 77), // Light Orange
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'පාඩම්',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'ශබ්දකෝෂය',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'බහුවරණ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'වාචික',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'ගිණුම',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 130, 28),
        unselectedItemColor: const Color.fromARGB(255, 107, 107, 107),
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }
}

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 300,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 251, 200, 124),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(150),
                  bottomRight: Radius.circular(150),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 120.0),
              child: CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/images/topinterface.png'),
              ),
            ),
            const Positioned(
              top: 50,
              child: Text(
                'සිංහල සංඥා භාෂා ඉගෙනුම් පද්ධතිය\nහා\nවාචික පුහුණුව',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Yasarath',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color.fromARGB(255, 8, 0, 0),
                  shadows: const [
                    Shadow(
                      offset: Offset(2.0, 1.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 253, 171, 116),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomButton(
                    label: 'සිංහල සංඥා භාෂා හෝඩිය', targetPage: SslPage()),
                SizedBox(height: 16),
                CustomButton(
                    label: 'සිංහල සංඥා භාෂා වචන', targetPage: Sslwordspage()),
                SizedBox(height: 16),
                CustomButton(
                    label: 'සිංහල සංඥා භාෂා ඉලක්කම්',
                    targetPage: SslNumbersPage()),
                SizedBox(height: 16),
                CustomButton(
                    label: 'සංඥා භාෂා පුහුණුව', targetPage: PracticePage()),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  final Widget targetPage;

  const CustomButton(
      {super.key, required this.label, required this.targetPage});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black, // Border color
            width: 2, // Border width
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Yasarath',
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final Color color;

  const PlaceholderWidget({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: const Center(
        child: Text(
          'This is a placeholder',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
