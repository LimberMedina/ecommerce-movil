import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'services/cart_service.dart';
import 'services/api_service.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cartService = CartService();
  await cartService.loadCart();
  runApp(MyApp(cartService: cartService));
}

class MyApp extends StatelessWidget {
  final CartService cartService;

  const MyApp({super.key, required this.cartService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartService>.value(
      value: cartService,
      child: MaterialApp(
        title: 'Mi Tienda',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 85, 158, 218)),
          fontFamily: 'Roboto',
        ),
        // No usamos el builder para el micrófono, será manejado en cada pantalla
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(), // Login sin micrófono
          '/home': (context) =>
              const HomeScreenWithVoice(), // Home con micrófono
          '/cart': (context) =>
              const CartScreenWithVoice(), // Cart con micrófono
        },
      ),
    );
  }
}

// Wrapper para HomeScreen que incluye el micrófono
class HomeScreenWithVoice extends StatelessWidget {
  const HomeScreenWithVoice({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const HomeScreen(), // La pantalla original
        const VoiceFloatingButton(), // El botón de micrófono
      ],
    );
  }
}

// Wrapper para CartScreen que incluye el micrófono
class CartScreenWithVoice extends StatelessWidget {
  const CartScreenWithVoice({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const CartScreen(), // La pantalla original
        const VoiceFloatingButton(), // El botón de micrófono
      ],
    );
  }
}

class VoiceFloatingButton extends StatefulWidget {
  const VoiceFloatingButton({super.key});

  @override
  State<VoiceFloatingButton> createState() => _VoiceFloatingButtonState();
}

class _VoiceFloatingButtonState extends State<VoiceFloatingButton> {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _listen() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        debugPrint('Error de reconocimiento: $error');
      },
    );

    if (available) {
      setState(() => _isListening = true);

      _speech.listen(
        onResult: (result) async {
          if (result.finalResult) {
            final command = result.recognizedWords.toLowerCase();
            debugPrint('Comando reconocido: $command');

            // Procesamos el comando de voz
            if (command.isNotEmpty) {
              try {
                // Buscamos el producto directamente por el comando completo
                final products =
                    await ApiService().getProducts(search: command);

                if (products.isNotEmpty) {
                  // Encontramos un producto, lo agregamos al carrito
                  final cartService =
                      Provider.of<CartService>(context, listen: false);

                  // Asegúrate de llamar a saveCart después de addItem
                  cartService.addItem(products.first);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('${products.first.name} agregado al carrito'),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No se encontró producto para "$command"'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al buscar productos: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            setState(() => _isListening = false);
            _speech.stop();
          }
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('El reconocimiento de voz no está disponible')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        backgroundColor: _isListening ? Colors.redAccent : Colors.blueAccent,
        onPressed: _listen,
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          color: Colors.white,
        ),
      ),
    );
  }
}
