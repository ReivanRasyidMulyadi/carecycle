import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// Hasil prediksi kategori dari Google ML Kit
class MlCategorySuggestion {
  final String category;
  final String matchedLabel;
  final double confidence;
  final List<String> allDetectedLabels;

  const MlCategorySuggestion({
    required this.category,
    required this.matchedLabel,
    required this.confidence,
    this.allDetectedLabels = const [],
  });

  bool get hasRecommendation => category != 'Lainnya';
}

/// Service On-Device AI Google ML Kit untuk klasifikasi gambar barang
class MlKitService {
  static const List<String> availableCategories = [
    'Pakaian',
    'Buku',
    'Elektronik',
    'Alat Sekolah',
    'Lainnya',
  ];

  // Kata kunci pemetaan label bahasa Inggris dari ML Kit ke kategori CareCycle
  static final Map<String, List<String>> _categoryKeywords = {
    'Pakaian': [
      'clothing', 'apparel', 'shirt', 't-shirt', 'pants', 'trousers', 'jeans',
      'dress', 'skirt', 'jacket', 'coat', 'sweater', 'hoodie', 'shoe', 'footwear',
      'sneakers', 'boots', 'sandals', 'hat', 'cap', 'scarf', 'glove', 'sock',
      'textile', 'sleeve', 'suit', 'collar', 'jersey', 'uniform', 'outerwear',
      'shorts', 'vest', 'denim', 'blouse', 'boot', 'sneaker'
    ],
    'Buku': [
      'book', 'publication', 'novel', 'textbook', 'magazine', 'comic',
      'hardcover', 'paperback', 'booklet', 'notebook', 'reading', 'literature',
      'brochure', 'pamphlet', 'diary', 'journal', 'document', 'paper'
    ],
    'Elektronik': [
      'electronics', 'electronic device', 'computer', 'laptop', 'gadget',
      'phone', 'smartphone', 'mobile phone', 'cellphone', 'tablet', 'display',
      'screen', 'television', 'tv', 'monitor', 'keyboard', 'mouse', 'headphones',
      'earphones', 'headset', 'audio', 'speaker', 'camera', 'charger', 'cable',
      'wire', 'hardware', 'appliance', 'radio', 'watch', 'clock', 'battery',
      'game controller', 'remote control', 'printed circuit board'
    ],
    'Alat Sekolah': [
      'stationery', 'pen', 'pencil', 'marker', 'highlighter', 'eraser',
      'ruler', 'pencil case', 'backpack', 'school bag', 'bag', 'scissors',
      'calculator', 'binder', 'folder', 'sharpener', 'crayon', 'paintbrush',
      'pencil sharpener', 'office supplies', 'luggage and bags'
    ],
  };

  /// Analisis berkas gambar lokal dan hasilkan saran kategori
  static Future<MlCategorySuggestion> classifyImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final options = ImageLabelerOptions(confidenceThreshold: 0.5);
      final imageLabeler = ImageLabeler(options: options);

      final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
      await imageLabeler.close();

      return mapLabelsToCategory(labels);
    } catch (_) {
      // Fallback aman jika model belum terdownload atau device tidak kompatibel
      return const MlCategorySuggestion(
        category: 'Lainnya',
        matchedLabel: '',
        confidence: 0.0,
      );
    }
  }

  /// Memetakan daftar label ML Kit ke salah satu kategori CareCycle
  static MlCategorySuggestion mapLabelsToCategory(List<ImageLabel> labels) {
    if (labels.isEmpty) {
      return const MlCategorySuggestion(
        category: 'Lainnya',
        matchedLabel: '',
        confidence: 0.0,
      );
    }

    final allNames = labels.map((l) => l.label).toList();

    // Prioritaskan label dengan confidence tertinggi yang cocok
    for (final label in labels) {
      final text = label.label.toLowerCase();

      for (final entry in _categoryKeywords.entries) {
        final category = entry.key;
        final keywords = entry.value;

        for (final kw in keywords) {
          if (text.contains(kw) || kw.contains(text)) {
            return MlCategorySuggestion(
              category: category,
              matchedLabel: label.label,
              confidence: label.confidence,
              allDetectedLabels: allNames,
            );
          }
        }
      }
    }

    // Jika tidak ada kata kunci yang cocok secara spesifik
    return MlCategorySuggestion(
      category: 'Lainnya',
      matchedLabel: labels.first.label,
      confidence: labels.first.confidence,
      allDetectedLabels: allNames,
    );
  }

  /// Helper pemetaan dari daftar String murni (berguna untuk unit testing)
  static String mapRawLabelsToCategoryName(List<String> rawLabels) {
    for (final raw in rawLabels) {
      final text = raw.toLowerCase();
      for (final entry in _categoryKeywords.entries) {
        for (final kw in entry.value) {
          if (text.contains(kw) || kw.contains(text)) {
            return entry.key;
          }
        }
      }
    }
    return 'Lainnya';
  }
}
