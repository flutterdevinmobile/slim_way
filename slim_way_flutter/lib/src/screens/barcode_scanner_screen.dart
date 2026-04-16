import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/i18n.dart';
import '../utils/barcode_service.dart';
import '../theme.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> with SingleTickerProviderStateMixin {
  bool _isScanning = true;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  MobileScannerController? scannerController;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    scannerController?.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        formats: [BarcodeFormat.all],
      );
    }
    setState(() {
      _hasPermission = status.isGranted;
      _isCheckingPermission = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.green)));
    }

    if (!_hasPermission || scannerController == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Permission Denied')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_photography_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Camera permission is required to scan barcodes'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkPermission,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Product Barcode', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
            onPressed: () => scannerController?.toggleTorch(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: scannerController!,
            onDetect: (capture) async {
              if (!_isScanning) return;
              
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  setState(() => _isScanning = false);
                  _handleBarcode(code);
                }
              }
            },
          ),
          // Scanner Overlay
          Center(
            child: Container(
              width: 280,
              height: 200, 
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.green, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                   _ScanningLine(),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Align barcode in the frame',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBarcode(String code) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.green)),
    );

    final product = await BarcodeService.getProductByBarcode(code);
    
    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      if (product != null) {
        Navigator.pop(context, product); 
      } else {
        _showNotFoundDialog();
      }
    }
  }

  void _showNotFoundDialog() {
    final state = context.read<AppState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.search_off_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Text(I18n.t('barcode_not_found', state.locale)),
          ],
        ),
        content: Text(
          I18n.t('barcode_msg', state.locale),
          style: const TextStyle(fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              setState(() => _isScanning = true); // Resume scanning
            },
            child: Text(I18n.t('cancel', state.locale), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, 'SHOW_PICKER'); // Return special flag to parent
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(I18n.t('use_photo', state.locale), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ScanningLine extends StatefulWidget {
  @override
  _ScanningLineState createState() => _ScanningLineState();
}

class _ScanningLineState extends State<_ScanningLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _controller.value * 200,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: AppTheme.green,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.green.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
