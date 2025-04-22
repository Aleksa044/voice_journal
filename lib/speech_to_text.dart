
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voice_journal/calendar_page.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';




class SpeechText extends StatefulWidget{
  const SpeechText({super.key});

  @override
  State<SpeechText> createState() => _SpeechtextState();
  
}

class _SpeechtextState extends State<SpeechText>{
  bool isEditing = false;
  bool isListening = false;
  late stt.SpeechToText _speechToText;
  String text = "Press the button & start speaking";
  double confidence = 1.0;
  late TextEditingController _textController;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  String? _audioPath;
  bool isRecording = false;


  @override
    void initState(){
      super.initState();      
      _speechToText = stt.SpeechToText();
      _textController = TextEditingController(text: text);
      _initAudio();

    }
  Future<void> _initAudio() async {
    PermissionStatus status = await Permission.microphone.request();
      if (status.isGranted) {
        await _recorder.openRecorder();
        await _player.openPlayer();
  } else {
    print("Microphone permission not granted");
  }
}

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        toolbarHeight: 80,
        elevation: 10,
        shadowColor: Colors.black.withAlpha((0.4 * 255).toInt()),
        centerTitle: true,
        title: const Text(
          'Voice Journal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
       actions: [
          IconButton(
          icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarPage()),
              );
          },
        ),
      ],
       
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        glowColor: Colors.blue,
        duration:const Duration(milliseconds: 1000),
        repeat: true,
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
        onPressed:_listen,
        
        child: Icon(
          isListening?
          Icons.mic: Icons.mic_none,
          size: 30,
          color: Colors.white,
          ),),
      ),
        body: SingleChildScrollView( 
        reverse: true,
        child: Container(
          padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Text(
  "Confidence: ${(confidence * 100).toStringAsFixed(1)}%",
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  ),
),
const SizedBox(height: 20),
            Row(
              
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    
    Expanded(
      child: isEditing
      
          ? TextField(
              onChanged: (value) {
                text = value;
              },
              controller: TextEditingController(text: text),
              maxLines: null,
              
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            )
          : Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
    ),
    const SizedBox(width: 10),
    Tooltip(
      message: isEditing ? 'Save changes' : 'Edit',
      child: IconButton(
        icon: Icon(isEditing ? Icons.check : Icons.edit),
        onPressed: () {
          setState(() {
            isEditing = !isEditing;
          });
        },
      ),
    ),
  ],
),

        
        
        const SizedBox(height: 20),
      ElevatedButton(
        onPressed: (){

        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        child: const Text(
          'Save Entry',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      if (_audioPath != null)
  Column(
    children: [
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: () async {
          await _player.startPlayer(
            fromURI: _audioPath,
            codec: Codec.aacMP4,
            whenFinished: () {
              setState(() {});
            },
          );
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Play Recording'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      ),
    ],
  ),

        ],)),),
    );
  }
  
  void _listen() async {
    if (!isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (status) => print('status: $status'),
        onError: (error) => print('error: $error'),
       
      );
      if (available) {
        setState(() => isListening = true);
         Directory tempDir = await getTemporaryDirectory();
          _audioPath = '${tempDir.path}/recorded_audio.aac';
          await _recorder.startRecorder(toFile: _audioPath, codec: Codec.aacMP4);

        await _speechToText.listen(
           localeId: 'sr-RS',
          onResult: (result) {
          setState(() {
            
            text = result.recognizedWords.isNotEmpty
                ? result.recognizedWords[0].toUpperCase() +
                    result.recognizedWords.substring(1)
                : '';
            _textController.text = text;
            if (result.hasConfidenceRating && result.confidence > 0) {
              confidence = result.confidence;
            }
          });
        });
      }
    } else {
      setState(() => isListening = false);
      await _speechToText.stop();
      await _recorder.stopRecorder();
      
    }
  }
}