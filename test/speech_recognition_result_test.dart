import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:speech_to_text/speech_recognition_result.dart";

void main() {
  const String firstRecognizedWords = "hello";
  const String secondRecognizedWords = "hello there";
  const double firstConfidence = 0.85;
  const double secondConfidence = 0.62;
  const String firstRecognizedJson =
      '{"alternates":[{"recognizedWords":"$firstRecognizedWords","confidence":$firstConfidence}],"finalResult":false}';
  const SpeechRecognitionWords firstWords =
      SpeechRecognitionWords(firstRecognizedWords, firstConfidence);
  const SpeechRecognitionWords secondWords =
      SpeechRecognitionWords(secondRecognizedWords, secondConfidence);

  setUp(() {});

  group("recognizedWords", () {
    test("empty if no alternates", () {
      const SpeechRecognitionResult result =
          SpeechRecognitionResult(<SpeechRecognitionWords>[], true);
      expect(result.recognizedWords, isEmpty);
    });
    test("matches first alternate", () {
      const SpeechRecognitionResult result = SpeechRecognitionResult(
          <SpeechRecognitionWords>[firstWords, secondWords], true,);
      expect(result.recognizedWords, firstRecognizedWords);
    });
  });
  group("alternates", () {
    test("empty if no alternates", () {
      const SpeechRecognitionResult result =
          SpeechRecognitionResult(<SpeechRecognitionWords>[], true);
      expect(result.alternates, isEmpty);
    });
    test("expected contents", () {
      const SpeechRecognitionResult result = SpeechRecognitionResult(
          <SpeechRecognitionWords>[firstWords, secondWords], true,);
      expect(result.alternates, contains(firstWords));
      expect(result.alternates, contains(secondWords));
    });
    test("in order", () {
      const SpeechRecognitionResult result = SpeechRecognitionResult(
          <SpeechRecognitionWords>[firstWords, secondWords], true,);
      expect(result.alternates.first, firstWords);
    });
  });
  group("confidence", () {
    test("0 if no alternates", () {
      const SpeechRecognitionResult result =
          SpeechRecognitionResult(<SpeechRecognitionWords>[], true);
      expect(result.confidence, 0);
    });
    test("isConfident false if no alternates", () {
      const SpeechRecognitionResult result =
          SpeechRecognitionResult(<SpeechRecognitionWords>[], true);
      expect(result.isConfident(), isFalse);
    });
    test("isConfident matches first alternate", () {
      const SpeechRecognitionResult result = SpeechRecognitionResult(
          <SpeechRecognitionWords>[firstWords, secondWords], true,);
      expect(result.isConfident(), firstWords.isConfident());
    });
    test("hasConfidenceRating false if no alternates", () {
      const SpeechRecognitionResult result =
          SpeechRecognitionResult(<SpeechRecognitionWords>[], true);
      expect(result.hasConfidenceRating, isFalse);
    });
    test("hasConfidenceRating matches first alternate", () {
      const SpeechRecognitionResult result = SpeechRecognitionResult(
          <SpeechRecognitionWords>[firstWords, secondWords], true,);
      expect(result.hasConfidenceRating, firstWords.hasConfidenceRating);
    });
  });
  group("json", () {
    test("loads correctly", () {
      final json = jsonDecode(firstRecognizedJson);
      final SpeechRecognitionResult result =
          SpeechRecognitionResult.fromJson(json);
      expect(result.recognizedWords, firstRecognizedWords);
      expect(result.confidence, firstConfidence);
    });
    test("roundtrips correctly", () {
      final json = jsonDecode(firstRecognizedJson);
      final SpeechRecognitionResult result =
          SpeechRecognitionResult.fromJson(json);
      final Map<String, dynamic> roundTripJson = result.toJson();
      final SpeechRecognitionResult roundtripResult =
          SpeechRecognitionResult.fromJson(roundTripJson);
      expect(result, roundtripResult);
    });
  });
  group("overrides", () {
    test("toString works with no alternates", () {
      const SpeechRecognitionResult result =
          SpeechRecognitionResult(<SpeechRecognitionWords>[], true);
      expect(
        result.toString(),
        "SpeechRecognitionResult words: [], final: true",
      );
    });
    test("toString works with alternates", () {
      const SpeechRecognitionResult result = SpeechRecognitionResult(
          <SpeechRecognitionWords>[firstWords], true,);
      expect(
        result.toString(),
        "SpeechRecognitionResult words: [SpeechRecognitionWords words: hello,  confidence: 0.85], final: true",
      );
    });
    test("hash same for same object", () {
      const SpeechRecognitionResult result = SpeechRecognitionResult(
          <SpeechRecognitionWords>[firstWords], true,);
      expect(result.hashCode, result.hashCode);
    });
    test("hash differs for different objects", () {
      const SpeechRecognitionResult result1 = SpeechRecognitionResult(
          <SpeechRecognitionWords>[firstWords], true,);
      const SpeechRecognitionResult result2 = SpeechRecognitionResult(
          <SpeechRecognitionWords>[secondWords], true,);
      expect(result1.hashCode, isNot(result2.hashCode));
    });
    test("equals same for same object", () {
      const SpeechRecognitionResult result = SpeechRecognitionResult(
          <SpeechRecognitionWords>[firstWords], true,);
      expect(result, result);
    });
    test("equals same for different object same values", () {
      const SpeechRecognitionResult result1 = SpeechRecognitionResult(
          <SpeechRecognitionWords>[firstWords], true,);
      const SpeechRecognitionResult result1a = SpeechRecognitionResult(
          <SpeechRecognitionWords>[firstWords], true,);
      expect(result1, result1a);
    });
    test("equals differs for different objects", () {
      const SpeechRecognitionResult result1 = SpeechRecognitionResult(
          <SpeechRecognitionWords>[firstWords], true,);
      const SpeechRecognitionResult result2 = SpeechRecognitionResult(
          <SpeechRecognitionWords>[secondWords], true,);
      expect(result1, isNot(result2));
    });
  });
}
