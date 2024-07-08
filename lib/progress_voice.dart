import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class ProgressVoice extends StatefulWidget {
  final int userId;

  const ProgressVoice({super.key, required this.userId});

  @override
  _ProgressVoiceState createState() => _ProgressVoiceState();
}

class _ProgressVoiceState extends State<ProgressVoice> {
  List<VoiceClip> voiceClips = [];

  @override
  void initState() {
    super.initState();
    fetchVoiceClips();
  }

  Future<void> fetchVoiceClips() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.31:3000/user-voiceclips/${widget.userId}'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        voiceClips = data.map((json) => VoiceClip.fromJson(json)).toList();
      });
    } else {
      print('හඬ පට පූරණය කිරීමට අසමත් විය');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 255, 183, 77), // Light Orange
        title: const Text(
          'හඬ පට ප්‍රගතිය',
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
      body: ListView.builder(
        itemCount: voiceClips.length,
        itemBuilder: (context, index) {
          final voiceClip = voiceClips[index];
          return ListTile(
            title: Text('හඬ පට ගත්තා ${voiceClip.date}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('වචනය: ${voiceClip.word}'),
                Text('ප්‍රගතිය: ${voiceClip.progress}'),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VoiceClipPlayer(voiceClip: voiceClip),
                      ),
                    );
                  },
                  child: const Text('හඬ පට අහන්න'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class VoiceClip {
  final int userId;
  final String voiceClip;
  final String date;
  final String word;
  final String progress;

  VoiceClip({
    required this.userId,
    required this.voiceClip,
    required this.date,
    required this.word,
    required this.progress,
  });

  factory VoiceClip.fromJson(Map<String, dynamic> json) {
    return VoiceClip(
      userId: json['userid'],
      voiceClip: json['voiceclip'],
      date: json['date'],
      word: json['word'],
      progress: json['progress'],
    );
  }
}

class VoiceClipPlayer extends StatefulWidget {
  final VoiceClip voiceClip;

  const VoiceClipPlayer({super.key, required this.voiceClip});

  @override
  _VoiceClipPlayerState createState() => _VoiceClipPlayerState();
}

class _VoiceClipPlayerState extends State<VoiceClipPlayer> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _loadVoiceClip(widget.voiceClip.voiceClip);
  }

  void _loadVoiceClip(String base64VoiceClip) {
    final audioBytes = base64Decode(base64VoiceClip);
    final audioUri = Uri.dataFromBytes(audioBytes, mimeType: 'audio/aac');
    _videoController = VideoPlayerController.networkUrl(audioUri)
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoController,
            autoPlay: true,
            looping: false,
          );
        });
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 255, 183, 77), // Light Orange
        title: const Text(
          'හඬ පට අහන්න',
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
      body: Center(
        child: _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(
                controller: _chewieController!,
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
