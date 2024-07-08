import 'package:flutter/material.dart';
import 'signup.dart';
import 'signin.dart';

// ignore: camel_case_types
class firstpage extends StatelessWidget {
  const firstpage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 208, 141),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top Text
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 100.0),
                child: Column(
                  children: [
                    Text(
                      'සිංහල සංඥා භාෂා ඉගෙනුම් පද්ධතිය\nහා\nවාචික පුහුණුව',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontSize: 22,
                        fontFamily: '0KDNAMAL',
                        fontWeight: FontWeight.w500,
                        shadows: const [
                          Shadow(
                            offset: Offset(2.0, 1.0),
                            blurRadius: 2.0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Spacer to push the content towards the top
              const Spacer(),

              // Button
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 15.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3A423),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                    child: Text(
                      'ආරම්භ කරන්න',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: '0KDNAMAL',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              // Link Button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SigninPage()),
                  );
                },
                child: const Text(
                  'මට දැනටමත් ගිණුමක් ති‌බෙනවා',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: '0KDNAMAL',
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 20.0),
            ],
          ),
          Positioned(
            left: (screenWidth * 0.1),
            top: (screenHeight * 0.35),
            child: Container(
              width: screenWidth * 0.8,
              height: screenHeight * 0.3,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/topinterface.png'),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
