import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class ProgressMcq extends StatefulWidget {
  final int userId;

  const ProgressMcq({super.key, required this.userId});

  @override
  _ProgressMcqState createState() => _ProgressMcqState();
}

class _ProgressMcqState extends State<ProgressMcq> {
  List<Progress> progressList = [];

  @override
  void initState() {
    super.initState();
    fetchProgress();
  }

  Future<void> fetchProgress() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.31:3000/user-progress/${widget.userId}'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        progressList = data.map((json) => Progress.fromJson(json)).toList();
        // Sort the progressList by date in ascending order
        progressList.sort((a, b) => a.date.compareTo(b.date));
      });
    } else {
      // Handle error
      print('Failed to load progress');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 231, 222),
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 255, 183, 77), // Light Orange
        title: const Text(
          'බහුවරණ ප්‍රගතිය',
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
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 10,
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      axisNameWidget: const Text('උත්සාහ ගණන'),
                      sideTitles: SideTitles(
                        showTitles: false,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              index < progressList.length
                                  ? progressList[index].date.split(' ')[0]
                                  : '',
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: const Text('ලකුණු'),
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              value.toInt().toString(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: progressList
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(entry.key.toDouble(),
                              entry.value.marks.toDouble()))
                          .toList(),
                      isCurved: false,
                      color: const Color.fromARGB(255, 255, 8, 21),
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: progressList.length,
              itemBuilder: (context, index) {
                final progress = progressList[index];
                return ListTile(
                  title: Text('Taken on ${progress.date.split(' ')[0]}'),
                  subtitle: Text('Marks: ${progress.marks}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Progress {
  final int userId;
  final int marks;
  final String date;

  Progress({
    required this.userId,
    required this.marks,
    required this.date,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      userId: json['user_id'],
      marks: json['marks'],
      date: json['date'],
    );
  }
}
