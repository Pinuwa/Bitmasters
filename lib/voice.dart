import 'package:flutter/material.dart';
import 'dart:convert'; // For base64 encoding
import 'dart:io'; // For File
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart'; // Add this import for getting the temporary directory

class VoicePage extends StatefulWidget {
  final int userId;
  const VoicePage({super.key, required this.userId});

  @override
  VoicePageState createState() => VoicePageState();
}

class VoicePageState extends State<VoicePage> {
  final Logger logger = Logger('VoicePageLogger');
  int currentVoiceId = 1; // Start with the first voice
  String word = '';
  String videoUrl = '';
  String imageUrl = '';

  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? recordedFilePath;

  @override
  void initState() {
    super.initState();
    fetchVoice(currentVoiceId);
    initRecorder();
  }

  Future<void> initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  Future<void> startRecording() async {
    if (!_isRecording) {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/audio.aac';
      await _recorder.startRecorder(toFile: path);
      setState(() {
        _isRecording = true;
        recordedFilePath = path;
      });
    }
  }

  Future<void> stopRecording() async {
    if (_isRecording) {
      final path = await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });
      logger.info('Recorded audio path: $path');
    }
  }

  Future<void> uploadVoiceClip() async {
    if (recordedFilePath != null) {
      final bytes = await File(recordedFilePath!).readAsBytes();
      final base64Audio = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('http://192.168.1.31:3000/uploadVoiceClip'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'userId': widget.userId,
          'voiceId': currentVoiceId,
          'voiceClip': base64Audio,
        }),
      );

      if (response.statusCode == 200) {
        logger.info('හඬ පටය සාර්ථකව උඩුගත කරන ලදී');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('හඬ පටය සාර්ථකව උඩුගත කරන ලදී')),
        );
      } else {
        logger.severe(
            'හඬ පටය උඩුගත කිරීමට අසමත් විය: ${response.statusCode} ${response.body}');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'හඬ පටය උඩුගත කිරීමට අසමත් විය: ${response.statusCode} ${response.body}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('උඩුගත කිරීමට හඬ පටයක් නැත')),
      );
    }
  }

  Future<void> fetchVoice(int id) async {
    final response =
        await http.get(Uri.parse('http://192.168.1.31:3000/voice/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        word = data['word'];
        videoUrl = data['video'];
        imageUrl = data['image'];
        currentVoiceId = data['id'];
        recordedFilePath = null; // Reset the recorded file path
        _loadVideo(videoUrl);
      });
    } else {
      logger.severe('හඬ පූරණය කිරීමට අසමත් විය');
    }
  }

  Future<void> fetchNextVoice() async {
    final response = await http
        .get(Uri.parse('http://192.168.1.31:3000/voice/next/$currentVoiceId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        word = data['word'];
        videoUrl = data['video'];
        imageUrl = data['image'];
        currentVoiceId = data['id'];
        recordedFilePath = null; // Reset the recorded file path
        _loadVideo(videoUrl);
      });
    } else {
      logger.severe('මීළඟ හඬ පූරණය කිරීමට අසමත් විය');
    }
  }

  Future<void> fetchPrevVoice() async {
    final response = await http
        .get(Uri.parse('http://192.168.1.31:3000/voice/prev/$currentVoiceId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        word = data['word'];
        videoUrl = data['video'];
        imageUrl = data['image'];
        currentVoiceId = data['id'];
        recordedFilePath = null; // Reset the recorded file path
        _loadVideo(videoUrl);
      });
    } else {
      logger.severe('පෙර හඬ පූරණය කිරීමට අසමත් විය');
    }
  }

  void _loadVideo(String base64Video) {
    try {
      final videoBytes = base64Decode(base64Video);
      final videoUri = Uri.dataFromBytes(videoBytes, mimeType: 'video/mp4');
      _videoController = VideoPlayerController.networkUrl(videoUri)
        ..initialize().then((_) {
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoController,
              autoPlay: true,
              looping: false,
            );
          });
        });
    } catch (e) {
      logger.severe('ශ්‍රව්‍ය පූරණය කිරීමට අසමත් විය: $e');
    }
  }

  void _playAgain() {
    if (_videoController.value.isInitialized) {
      _videoController.seekTo(Duration.zero);
      _videoController.play();
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 231, 222),
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 255, 183, 77), // Light Orange
        title: const Text(
          'වාචික පුහුණුව',
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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                            width: imageSize,
                            height: imageSize,
                          )
                        : const CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: _chewieController != null &&
                            _chewieController!
                                .videoPlayerController.value.isInitialized
                        ? Chewie(
                            controller: _chewieController!,
                          )
                        : const CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _playAgain,
                    child: const Text('නැවතත් සවන් දෙන්න'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Flexible(
                        child: ElevatedButton(
                          onPressed: fetchPrevVoice,
                          child: const Text('කලින් වාදය'),
                        ),
                      ),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: fetchNextVoice,
                          child: const Text('ඊළඟ වාදය'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    icon: Icon(_isRecording ? Icons.mic_off : Icons.mic),
                    onPressed: _isRecording ? stopRecording : startRecording,
                    color: _isRecording ? Colors.red : Colors.blue,
                    iconSize: 50,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: uploadVoiceClip,
                    child: const Text('හඬ උඩුගත කරන්න'),
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
