import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceController {
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<String?> listenCommand() async {
    bool available = await _speech.initialize();
    if (!available) return null;

    await _speech.listen(localeId: 'es_BO'); // o 'es_ES', etc.

    // Esperar 3 segundos y parar
    await Future.delayed(const Duration(seconds: 3));
    await _speech.stop();

    return _speech.lastRecognizedWords;
  }
}
