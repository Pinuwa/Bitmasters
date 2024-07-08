import 'package:flutter/material.dart';

// ignore: camel_case_types
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, String> _wordToImageMap = {
    'අම්මා': 'assets/images/mother_sign.png',
    'අප්පා': 'assets/images/father_sign.png',
    'අ': 'assets/images/0412-1-1.gif',
    'ඔබ': 'assets/images/you_sign.png',
    // Add more word-image pairs here
  };
  String? _selectedImagePath;

  void _searchWord(String query) {
    setState(() {
      _selectedImagePath = _wordToImageMap[query];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 231, 222),
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 255, 183, 77), // Light Orange
        title: const Text(
          'සිංහල සංඥා ශබ්දකෝෂය',
          style: TextStyle(
            fontFamily: 'Yasarath',
            fontSize: 24,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'සොයන්න',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onChanged: (query) {
                _searchWord(query);
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _selectedImagePath != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.grey[300], // Ash
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                Image.asset(
                                  _selectedImagePath!,
                                  width: 250,
                                  height: 250,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: Text(
                        'පරිච්ඡේදයක් හමු නොවීය',
                        style: TextStyle(
                          fontFamily: 'Yasarath',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
