import "package:flutter/foundation.dart";

/// A single error returned from the underlying speech services.
///
/// Errors are either transient or permanent. Permanent errors
/// block speech recognition from continuing and must be
/// addressed before recognition will work. Transient errors
/// cause individual recognition sessions to fail but subsequent
/// attempts may well succeed.
@immutable
class SpeechRecognitionError {
  const SpeechRecognitionError(this.errorMsg, this.permanent);

  factory SpeechRecognitionError.fromJson(Map<String, dynamic> json) =>
      SpeechRecognitionError(
        json["errorMsg"],
        json["permanent"],
      );

  /// Use this to differentiate the various error conditions.
  ///
  /// Not meant for display to the user.
  final String errorMsg;

  /// True means that recognition cannot continue until
  /// the error is resolved.
  final bool permanent;

  Map<String, dynamic> toJson() => <String, dynamic>{
        "errorMsg": errorMsg,
        "permanent": permanent,
      };

  @override
  String toString() =>
      "SpeechRecognitionError msg: $errorMsg, permanent: $permanent";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechRecognitionError &&
          errorMsg == other.errorMsg &&
          permanent == other.permanent;

  @override
  int get hashCode => errorMsg.hashCode;
}
