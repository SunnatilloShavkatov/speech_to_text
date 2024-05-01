import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:speech_to_text/speech_recognition_error.dart";

void main() {
  const String msg1 = "msg1";

  setUp(() {});

  group("properties", () {
    test("equals true for same object", () {
      const SpeechRecognitionError error = SpeechRecognitionError(msg1, false);
      expect(error, error);
    });
    test("equals true for different object same values", () {
      const SpeechRecognitionError error1 = SpeechRecognitionError(msg1, false);
      const SpeechRecognitionError error2 = SpeechRecognitionError(msg1, false);
      expect(error1, error2);
    });
    test("equals false for different object", () {
      const SpeechRecognitionError error1 = SpeechRecognitionError(msg1, false);
      const SpeechRecognitionError error2 =
          SpeechRecognitionError("msg2", false);
      expect(error1, isNot(error2));
    });
    test("hash same for same object", () {
      const SpeechRecognitionError error = SpeechRecognitionError(msg1, false);
      expect(error.hashCode, error.hashCode);
    });
    test("hash same for different object same values", () {
      const SpeechRecognitionError error1 = SpeechRecognitionError(msg1, false);
      const SpeechRecognitionError error2 = SpeechRecognitionError(msg1, false);
      expect(error1.hashCode, error2.hashCode);
    });
    test("hash different for different object", () {
      const SpeechRecognitionError error1 = SpeechRecognitionError(msg1, false);
      const SpeechRecognitionError error2 =
          SpeechRecognitionError("msg2", false);
      expect(error1.hashCode, isNot(error2.hashCode));
    });
    test("toString as expected", () {
      const SpeechRecognitionError error1 = SpeechRecognitionError(msg1, false);
      expect(
        error1.toString(),
        "SpeechRecognitionError msg: $msg1, permanent: false",
      );
    });
  });
  group("json", () {
    test("loads properly", () {
      var json = jsonDecode('{"errorMsg":"$msg1","permanent":true}');
      SpeechRecognitionError error = SpeechRecognitionError.fromJson(json);
      expect(error.errorMsg, msg1);
      expect(error.permanent, isTrue);
      json = jsonDecode('{"errorMsg":"$msg1","permanent":false}');
      error = SpeechRecognitionError.fromJson(json);
      expect(error.permanent, isFalse);
    });
    test("roundtrips properly", () {
      final json = jsonDecode('{"errorMsg":"$msg1","permanent":true}');
      final SpeechRecognitionError error =
          SpeechRecognitionError.fromJson(json);
      final Map<String, dynamic> roundtripJson = error.toJson();
      final SpeechRecognitionError roundtripError =
          SpeechRecognitionError.fromJson(roundtripJson);
      expect(error, roundtripError);
    });
  });
}
