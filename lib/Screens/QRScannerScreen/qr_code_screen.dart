import 'package:flutter/material.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  var isPermissionGiven = false;

  List<String> scannedNumberList = [];
  var qrController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void initState() {
    checkCameraPermission();
    super.initState();
  }

  Future<bool> checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted) {
      isPermissionGiven = status.isGranted;
      setState(() {});
      return true; // Permission already granted
    } else if (status.isDenied) {
      status = await Permission.camera.request(); // Request permission
      isPermissionGiven = status.isGranted;
      setState(() {});
      return status.isGranted;
    } else if (status.isPermanentlyDenied) {
      //openAppSettings(); // Redirect user to settings
      return false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isPermissionGiven ? null : AppBar(
        title: Text("Scan"),
      ),
      body: isPermissionGiven
          ? AiBarcodeScanner(
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
            )
          : InfoColumn(
              title: "Permission",
              description: "Please allow permission to camera access",
              onPressed: () {
                openAppSettings();
              },
        onRefresh: (){
          checkCameraPermission();
        },
      ),
    );
  }
}

class InfoColumn extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onPressed;
  final VoidCallback onRefresh;
  const InfoColumn({
    super.key,
    required this.title,
    required this.description,
    required this.onPressed,
    required this.onRefresh
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade400,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      "Open Settings",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRefresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade400,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      "Refresh",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
