import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voice_journal/calendar_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeechText extends StatefulWidget {
  const SpeechText({super.key});

  @override
  State<SpeechText> createState() => _SpeechtextState();
}

class _SpeechtextState extends State<SpeechText> {
  bool isEditing = false;
  bool isListening = false;
  late stt.SpeechToText _speechToText;
  String text = "Press the button & start speaking";
  double confidence = 1.0;
  late TextEditingController _textController;

  Map<DateTime, String> entries = {};
  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _textController = TextEditingController(text: text);
    _loadEntries();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    Set<String> savedEntries =
        prefs.getStringList('entries')?.toSet() ?? <String>{};

    setState(() {
      for (var entry in savedEntries) {
        var dateStr = entry.split('|')[0];
        var textStr = entry.split('|')[1];
        DateTime date = DateTime.parse(dateStr);
        entries[date] = textStr;
      }
    });
  }

  _saveEntry(DateTime date, String text) async {
    final prefs = await SharedPreferences.getInstance();
    Set<String> savedEntries =
        prefs.getStringList('entries')?.toSet() ?? <String>{};
    savedEntries.add('$date|$text');
    await prefs.setStringList('entries', savedEntries.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                MaterialPageRoute(
                  builder: (context) => CalendarPage(entries: entries),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        glowColor: Colors.blue,
        duration: const Duration(milliseconds: 1000),
        repeat: true,
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: _listen,

          child: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            size: 30,
            color: Colors.white,
          ),
        ),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child:
                        isEditing && text != "Press the button & start speaking"
                            ? TextField(
                              onChanged: (value) {
                                text = value;
                              },
                              controller: TextEditingController(text: text),
                              maxLines: null,

                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
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
                  if (text != "Press the button & start speaking")
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
                onPressed: () {
                  DateTime today = DateTime.now();
                  setState(() {
                    entries[_normalizeDate(today)] = text;
                  });
                  _saveEntry(today, text);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Entry saved!')));
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
            ],
          ),
        ),
      ),
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
        _speechToText.listen(
          localeId: 'sr-RS',
          onResult: (result) {
            setState(() {
              text =
                  result.recognizedWords.isNotEmpty
                      ? result.recognizedWords[0].toUpperCase() +
                          result.recognizedWords.substring(1)
                      : '';
              _textController.text = text;
              if (result.hasConfidenceRating && result.confidence > 0) {
                confidence = result.confidence;
              }
            });
          },
        );
      }
    } else {
      setState(() => isListening = false);
      await _speechToText.stop();
    }
  }
}
