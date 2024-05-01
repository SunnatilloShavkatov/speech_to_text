// ignore_for_file: discarded_futures

import "dart:async";

import "package:flutter/material.dart";
import "package:speech_to_text/speech_recognition_error.dart";
import "package:speech_to_text/speech_recognition_result.dart";
import "package:speech_to_text/speech_to_text.dart";

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasSpeech = false;
  bool _stressTest = false;
  double level = 0;
  int _stressLoops = 0;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = <LocaleName>[];
  final SpeechToText speech = SpeechToText();

  @override
  void initState() {
    super.initState();
  }

  Future<void> initSpeechState() async {
    final bool hasSpeech = await speech.initialize(
      onError: errorListener,
      onStatus: statusListener,
    );
    if (hasSpeech) {
      _localeNames = await speech.locales();

      final LocaleName? systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? "";
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Speech to Text Example"),
          ),
          body: Column(
            children: <Widget>[
              const Center(
                child: Text(
                  "Speech recognition available",
                  style: TextStyle(fontSize: 22),
                ),
              ),
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      TextButton(
                        onPressed: _hasSpeech ? null : initSpeechState,
                        child: const Text("Initialize"),
                      ),
                      TextButton(
                        onPressed: stressTest,
                        child: const Text("Stress Test"),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      TextButton(
                        onPressed: !_hasSpeech || speech.isListening
                            ? null
                            : startListening,
                        child: const Text("Start"),
                      ),
                      TextButton(
                        onPressed: speech.isListening ? stopListening : null,
                        child: const Text("Stop"),
                      ),
                      TextButton(
                        onPressed: speech.isListening ? cancelListening : null,
                        child: const Text("Cancel"),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      DropdownButton<String>(
                        onChanged: _switchLang,
                        value: _currentLocaleId,
                        items: _localeNames
                            .map(
                              (LocaleName localeName) =>
                                  DropdownMenuItem<String>(
                                value: localeName.localeId,
                                child: Text(localeName.name),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                flex: 4,
                child: Column(
                  children: <Widget>[
                    const Center(
                      child: Text(
                        "Recognized Words",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: <Widget>[
                          ColoredBox(
                            color: Theme.of(context).secondaryHeaderColor,
                            child: Center(
                              child: Text(
                                lastWords,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            bottom: 10,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      blurRadius: .26,
                                      spreadRadius: level * 1.5,
                                      color: Colors.black.withOpacity(.05),
                                    ),
                                  ],
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.mic),
                                  onPressed: () {},
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    const Center(
                      child: Text(
                        "Error Status",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    Center(
                      child: Text(lastError),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                color: Theme.of(context).colorScheme.background,
                child: Center(
                  child: speech.isListening
                      ? const Text(
                          "I'm listening...",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      : const Text(
                          "Not listening",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      );

  void stressTest() {
    if (_stressTest) {
      return;
    }
    _stressLoops = 0;
    _stressTest = true;
    debugPrint("Starting stress test...");
    startListening();
  }

  void changeStatusForStress(String status) {
    if (!_stressTest) {
      return;
    }
    if (speech.isListening) {
      stopListening();
    } else {
      if (_stressLoops >= 100) {
        _stressTest = false;
        debugPrint("Stress test complete.");
        return;
      }
      debugPrint("Stress loop: $_stressLoops");
      ++_stressLoops;
      startListening();
    }
  }

  void startListening() {
    lastWords = "";
    lastError = "";
    speech.listen(
      onResult: resultListener,
      listenFor: const Duration(seconds: 10),
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
    );
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = "${result.recognizedWords} - ${result.finalResult}";
    });
  }

  void soundLevelListener(double level) {
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    changeStatusForStress(status);
    setState(() {
      lastStatus = status;
    });
  }

  void _switchLang(String? selectedVal) {
    if (selectedVal == null) {
      return;
    }
    setState(() {
      _currentLocaleId = selectedVal;
    });
    debugPrint(selectedVal);
  }
}
