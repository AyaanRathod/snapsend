import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

// ── Scanner state machine ─────────────────────────────────────────────────

enum ScannerStatus {
  /// No scan in progress, all state is clear.
  idle,

  /// The ML Kit Document Scanner activity is open (user is capturing).
  scanning,

  /// Image captured; running text recognition.
  processing,

  /// Text recognition complete — ready for the Verification screen.
  done,

  /// An error occurred; [ScannerViewModel.errorMessage] has details.
  error,
}

// ── ViewModel ─────────────────────────────────────────────────────────────

/// Orchestrates the two-step receipt scanning flow:
///
///   1. **Scan** — launches `google_mlkit_document_scanner` which
///      handles camera, edge detection, and auto-cropping automatically.
///   2. **Extract** — feeds the cropped JPEG to `google_mlkit_text_recognition`
///      for OCR, then attempts to auto-parse the total amount.
///
/// After `status == ScannerStatus.done`, the Verification screen reads:
///   - [scannedImagePath] — absolute path to the persisted JPEG
///   - [extractedText]   — raw OCR text
///   - [parsedAmount]    — best-guess total (may be null)
///
/// Call [reset()] when the user navigates away from the scanner flow.
class ScannerViewModel extends ChangeNotifier {
  ScannerStatus _status = ScannerStatus.idle;
  String? _scannedImagePath;
  String? _extractedText;
  double? _parsedAmount;
  String? _errorMessage;

  // ── Public State ────────────────────────────────────────────────────────

  ScannerStatus get status => _status;
  bool get isIdle => _status == ScannerStatus.idle;
  bool get isScanning => _status == ScannerStatus.scanning;
  bool get isProcessing => _status == ScannerStatus.processing;
  bool get isDone => _status == ScannerStatus.done;
  bool get hasError => _status == ScannerStatus.error;
  bool get isBusy =>
      _status == ScannerStatus.scanning ||
      _status == ScannerStatus.processing;

  /// Absolute path to the cropped receipt image saved in app documents.
  String? get scannedImagePath => _scannedImagePath;

  /// Full raw OCR output from ML Kit.
  String? get extractedText => _extractedText;

  /// Best-guess total amount parsed from [extractedText].  May be null if
  /// no recognisable amount was found.
  double? get parsedAmount => _parsedAmount;

  String? get errorMessage => _errorMessage;

  // ── Commands ─────────────────────────────────────────────────────────────

  /// Launches the ML Kit Document Scanner, saves the image, and runs OCR.
  ///
  /// ⚠️  Requires a **physical Android device** with Google Play Services.
  ///     Will throw on the emulator.
  Future<void> startScan() async {
    if (isBusy) return;

    _setStatus(ScannerStatus.scanning);

    // Step 1 — Launch the document scanner activity.
    DocumentScanner? scanner;
    try {
      scanner = DocumentScanner(
        options: DocumentScannerOptions(
          documentFormat: DocumentFormat.jpeg,
          mode: ScannerMode.full,
          isGalleryImport: true, // also allow picking from gallery
          pageLimit: 1, // one receipt = one page
        ),
      );

      final DocumentScanningResult result = await scanner.scanDocument();

      if (result.images.isEmpty) {
        // User cancelled or no image was captured.
        _setStatus(ScannerStatus.idle);
        return;
      }

      final String rawPath = result.images.first;

      // Step 2 — Persist the image to a stable app-documents location.
      _setStatus(ScannerStatus.processing);
      final String persistedPath = await _persistImage(rawPath);
      _scannedImagePath = persistedPath;

      // Step 3 — Run OCR.
      await _extractText(persistedPath);

      _setStatus(ScannerStatus.done);
    } catch (e) {
      _errorMessage = 'Scan failed: ${e.toString()}';
      _setStatus(ScannerStatus.error);
    } finally {
      scanner?.close();
    }
  }

  /// Re-runs OCR on an already persisted image at [imagePath].
  ///
  /// Useful if the user wants to retry extraction on the Verification screen.
  Future<void> reprocessImage(String imagePath) async {
    if (isBusy) return;
    _setStatus(ScannerStatus.processing);
    try {
      _scannedImagePath = imagePath;
      await _extractText(imagePath);
      _setStatus(ScannerStatus.done);
    } catch (e) {
      _errorMessage = 'Text extraction failed: ${e.toString()}';
      _setStatus(ScannerStatus.error);
    }
  }

  /// Clears all scanner state.  Call when the user leaves the scanner flow.
  void reset() {
    _status = ScannerStatus.idle;
    _scannedImagePath = null;
    _extractedText = null;
    _parsedAmount = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Private Helpers ───────────────────────────────────────────────────────

  void _setStatus(ScannerStatus status) {
    _status = status;
    notifyListeners();
  }

  /// Copies [sourcePath] to `<appDocDir>/receipts/<uuid>.jpg` for persistence.
  ///
  /// The temporary file from ML Kit may be cleaned up by the OS; we copy it
  /// to a location that survives the app lifecycle.
  Future<String> _persistImage(String sourcePath) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory('${appDocDir.path}/receipts');
    if (!receiptsDir.existsSync()) {
      await receiptsDir.create(recursive: true);
    }
    final String destPath =
        '${receiptsDir.path}/${const Uuid().v4()}.jpg';
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  /// Runs ML Kit text recognition on the image at [imagePath].
  Future<void> _extractText(String imagePath) async {
    final recognizer =
        TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText result =
          await recognizer.processImage(inputImage);
      _extractedText = result.text;
      _parsedAmount = _parseAmount(result.text);
    } finally {
      recognizer.close();
    }
  }

  /// Attempts to extract the total amount from [text].
  ///
  /// Strategy:
  ///   1. Strip timestamps (e.g. "19:44:27") so they are never parsed as dollars.
  ///   2. Collect every TOTAL-style match (excluding SUBTOTAL via lookbehind).
  ///   3. Return the LARGEST candidate — Grand Total >= Subtotal always.
  ///   4. Last resort: largest decimal in text (capped at 9999 to skip barcodes).
  double? _parseAmount(String text) {
    // Strip timestamps like "19:44:27" or "06:29 AM" and long numeric serials.
    final cleaned = text
        .replaceAll(RegExp(r'\b\d{1,2}:\d{2}(:\d{2})?\s*(AM|PM)?\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\b\d{6,}\b'), '');

    final candidates = <double>[];

    void tryAdd(String? raw) {
      if (raw == null) return;
      final v = double.tryParse(raw.replaceAll(',', '.'));
      if (v != null && v > 0 && v < 10000) candidates.add(v);
    }

    // Priority patterns — negative lookbehind (?<!SUB) stops SUBTOTAL matching.
    final priorityPatterns = [
      RegExp(r'grand\s*total[^\d]*(\d+[.,]\d{2})', caseSensitive: false),
      RegExp(r'(?<!SUB)\bTOTAL\b[^\d]*(\d+[.,]\d{2})', caseSensitive: false),
      RegExp(r'TOTAL\s+PURCHASE[^\d]*(\d+[.,]\d{2})', caseSensitive: false),
      RegExp(r'VISA\s*TEND[^\d]*(\d+[.,]\d{2})', caseSensitive: false),
      RegExp(r'AMOUNT\s+DUE[^\d]*(\d+[.,]\d{2})', caseSensitive: false),
      RegExp(r'BALANCE\s+DUE[^\d]*(\d+[.,]\d{2})', caseSensitive: false),
      RegExp(r'\bAMOUNT[^\d]*(\d+[.,]\d{2})', caseSensitive: false),
    ];

    for (final pattern in priorityPatterns) {
      for (final match in pattern.allMatches(cleaned)) {
        tryAdd(match.group(1));
      }
    }

    // If we found any, return the LARGEST (Grand Total > Subtotal always).
    if (candidates.isNotEmpty) {
      candidates.sort((a, b) => b.compareTo(a));
      return candidates.first;
    }

    // Subtotal-only fallback.
    final subMatch = RegExp(r'\bsubtotal[^\d]*(\d+[.,]\d{2})', caseSensitive: false)
        .firstMatch(cleaned);
    if (subMatch != null) {
      final v = double.tryParse(subMatch.group(1)!.replaceAll(',', '.'));
      if (v != null && v > 0) return v;
    }

    // Last resort: largest reasonable decimal in the cleaned text.
    double? largest;
    for (final match in RegExp(r'\b(\d{1,4}[.,]\d{2})\b').allMatches(cleaned)) {
      final v = double.tryParse(match.group(1)!.replaceAll(',', '.'));
      if (v != null && v > 0 && v < 10000) {
        if (largest == null || v > largest) largest = v;
      }
    }
    return largest;
  }
}
