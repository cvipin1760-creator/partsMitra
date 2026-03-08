import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String?> pickAndExtractPartNumber() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image == null) return null;

    final inputImage = InputImage.fromFilePath(image.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    // Common part number patterns (e.g., 53250KWPH00ZA, 24610KST940S)
    // These are typically alphanumeric, 10-15 characters long.
    final partNumberRegex = RegExp(r'[A-Z0-9]{10,15}');

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final text = line.text.replaceAll(' ', '').toUpperCase();
        final match = partNumberRegex.firstMatch(text);
        if (match != null) {
          return match.group(0);
        }
      }
    }
    
    return null;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
