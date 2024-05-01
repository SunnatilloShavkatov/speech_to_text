// ignore_for_file: discarded_futures

import "dart:async";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:speech_to_text/speech_to_text.dart";
import "package:speech_to_text/speech_to_text_provider.dart";
import "package:speech_to_text_example/recognition_results_widget.dart";

void main() => runApp(const ProviderDemoApp());

class ProviderDemoApp extends StatefulWidget {
  const ProviderDemoApp({super.key});

  @override
  State<ProviderDemoApp> createState() => _ProviderDemoAppState();
}

class _ProviderDemoAppState extends State<ProviderDemoApp> {
  final SpeechToText speech = SpeechToText();
  late SpeechToTextProvider speechProvider;

  @override
  void initState() {
    super.initState();
    speechProvider = SpeechToTextProvider(speech);
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    await speechProvider.initialize();
  }

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<SpeechToTextProvider>.value(
        value: speechProvider,
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text("Speech to Text Provider Example"),
            ),
            body: const SpeechProviderExampleWidget(),
          ),
        ),
      );
}

class SpeechProviderExampleWidget extends StatefulWidget {
  const SpeechProviderExampleWidget({super.key});

  @override
  SpeechProviderExampleWidgetState createState() =>
      SpeechProviderExampleWidgetState();
}

class SpeechProviderExampleWidgetState
    extends State<SpeechProviderExampleWidget> {
  String _currentLocaleId = "";

  void _setCurrentLocale(SpeechToTextProvider speechProvider) {
    if (speechProvider.isAvailable && _currentLocaleId.isEmpty) {
      _currentLocaleId = speechProvider.systemLocale?.localeId ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final SpeechToTextProvider speechProvider =
        Provider.of<SpeechToTextProvider>(context);
    if (speechProvider.isNotAvailable) {
      return const Center(
        child: Text(
          "Speech recognition not available, no permission or not available on the device.",
        ),
      );
    }
    _setCurrentLocale(speechProvider);
    return Column(
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
                  onPressed:
                      !speechProvider.isAvailable || speechProvider.isListening
                          ? null
                          : () => speechProvider.listen(
                                localeId: _currentLocaleId,
                              ),
                  child: const Text("Start"),
                ),
                TextButton(
                  onPressed:
                      speechProvider.isListening ? speechProvider.stop : null,
                  child: const Text("Stop"),
                ),
                TextButton(
                  onPressed:
                      speechProvider.isListening ? speechProvider.cancel : null,
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
                  items: speechProvider.locales
                      .map(
                        (LocaleName localeName) => DropdownMenuItem<String>(
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
        const Expanded(
          flex: 4,
          child: RecognitionResultsWidget(),
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
                child: speechProvider.hasError
                    ? Text(speechProvider.lastError!.errorMsg)
                    : Container(),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          color: Theme.of(context).colorScheme.background,
          child: Center(
            child: speechProvider.isListening
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
    );
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
