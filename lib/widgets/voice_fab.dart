import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';

class VoiceFab extends StatefulWidget {
  const VoiceFab({super.key});

  @override
  State<VoiceFab> createState() => _VoiceFabState();
}

class _VoiceFabState extends State<VoiceFab> {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _listen(BuildContext context) async {
    final cartService = Provider.of<CartService>(context, listen: false);
    final api = ApiService();

    bool available = await _speech.initialize(
      onStatus: (status) => print('🟡 STATUS: $status'),
      onError: (err) => print('🔴 ERROR: $err'),
    );

    print('🎤 Mic available: $available');

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) async {
          final spokenText = result.recognizedWords.toLowerCase().trim();

          if (spokenText.isNotEmpty) {
            try {
              final products = await api.getProducts(search: spokenText);
              if (products.isNotEmpty) {
                cartService.addItem(products.first);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          '🛒 \"${products.first.name}\" añadido al carrito')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Producto no encontrado')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('❌ Error: $e')),
              );
            }
          }

          _speech.stop();
          setState(() => _isListening = false);
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('🎤 No se pudo iniciar el reconocimiento de voz')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: FloatingActionButton(
        backgroundColor: _isListening ? Colors.redAccent : Colors.blue,
        onPressed: () => _listen(context),
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          color: Colors.white,
        ),
      ),
    );
  }
}
