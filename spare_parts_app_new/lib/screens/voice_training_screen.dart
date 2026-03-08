
// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/voice_correction_service.dart';
import 'package:translator/translator.dart';
import '../services/product_service.dart';
import '../models/product.dart';

class VoiceTrainingScreen extends StatefulWidget {
  const VoiceTrainingScreen({super.key});

  @override
  _VoiceTrainingScreenState createState() => _VoiceTrainingScreenState();
}

class _VoiceTrainingScreenState extends State<VoiceTrainingScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  final TextEditingController _correctionController = TextEditingController();
  final TextEditingController _testController = TextEditingController();
  final _translator = GoogleTranslator();
  final VoiceCorrectionService _voiceService = VoiceCorrectionService();
  final TextEditingController _aliasController = TextEditingController();
  final TextEditingController _pronunciationController = TextEditingController();
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  int? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCorrections();
  }

  Future<void> _loadProducts() async {
    final products = await _productService.getAllProducts();
    if (mounted) {
      setState(() {
        _products = products;
        _selectedProductId = products.isNotEmpty ? products.first.id : null;
      });
    }
  }
  Future<void> _loadCorrections() async {
    await _voiceService.listCorrections();
    if (mounted) {
      setState(() {});
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) => setState(() => _isListening = false),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) async {
            String text = val.recognizedWords;
            try {
              final t = await _translator.translate(text, to: 'en');
              text = t.text;
            } catch (_) {}
            final corrected = await _voiceService.getCorrection(text);
            setState(() {
              _recognizedText = corrected ?? text;
              _correctionController.text = corrected ?? text;
              _testController.text = corrected ?? text;
            });
          },
          localeId: '${Localizations.localeOf(context).languageCode}_${Localizations.localeOf(context).countryCode ?? 'US'}',
        );
      } else {
        debugPrint("The user has denied the use of speech recognition.");
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Training'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Recognized Text: $_recognizedText'),
            const SizedBox(height: 20),
            TextField(
              controller: _correctionController,
              decoration: const InputDecoration(labelText: 'Corrected Text'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _voiceService.addCorrection(
                  _recognizedText,
                  _correctionController.text,
                );
                await _loadCorrections();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Correction saved!')),
                );
              },
              child: const Text('Save Correction'),
            ),
            const SizedBox(height: 30),
            if (_products.isNotEmpty)
              DropdownButtonFormField<int>(
                value: _selectedProductId,
                items: _products
                    .map((p) => DropdownMenuItem(value: p.id, child: Text('${p.name} (${p.partNumber})')))
                    .toList(),
                onChanged: (val) => setState(() => _selectedProductId = val),
                decoration: const InputDecoration(labelText: 'Product'),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _aliasController,
              decoration: const InputDecoration(labelText: 'Alias or Alternate Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pronunciationController,
              decoration: const InputDecoration(labelText: 'Pronunciation (optional)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_selectedProductId == null || _aliasController.text.isEmpty) return;
                await _productService.addAlias(_selectedProductId!, _aliasController.text, _pronunciationController.text.isEmpty ? null : _pronunciationController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alias saved')),
                );
                _aliasController.clear();
                _pronunciationController.clear();
              },
              child: const Text('Save Alias'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
    );
  }
}
