import 'package:flutter/material.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  List<String> scannedNumberList = [];
  var qrController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AiBarcodeScanner(
        onDispose: () {
          debugPrint("Barcode scanner disposed!");
        },
        hideGalleryButton: true,
        controller: qrController,
        onDetect: (BarcodeCapture capture) {
          /// List of scanned barcodes if any
          final List<Barcode> barcodes = capture.barcodes;
          debugPrint("Barcode list: ${barcodes[0].displayValue}");
          for (var item in barcodes) {
            qrController.dispose();
            Navigator.pop(context, item.displayValue.toString());
          }
        },
        validator: (value) {
          if (value.barcodes.isEmpty) {
            return false;
          }
          if (!(value.barcodes.first.rawValue?.contains('flutter.dev') ??
              false)) {
            return false;
          }
          return true;
        },
      ),
    );
  }
}
