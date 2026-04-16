import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slim_way_client/slim_way_client.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils/i18n.dart';
import '../utils/barcode_service.dart';
import 'barcode_scanner_screen.dart';
import 'package:http/http.dart' as http;

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _promptController = TextEditingController();
  String _detectedName = '';
  double _detectedCalories = 0.0;
  Uint8List? _imageBytes;
  final _picker = ImagePicker();
  double _detectedProtein = 0.0;
  double _detectedFat = 0.0;
  double _detectedCarbs = 0.0;
  bool _isAnalyzing = false;
  bool _hasResult = false;

  Future<void> _scanBarcode() async {
    final dynamic result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (result == 'SHOW_PICKER') {
      _showImageSourceOptions();
      return;
    }

    if (result != null && result is BarcodeProduct) {
      // If product has image, download it to Uint8List for display
      Uint8List? imageBytes;
      if (result.imageUrl != null) {
        try {
          final response = await http.get(Uri.parse(result.imageUrl!));
          if (response.statusCode == 200) {
            imageBytes = response.bodyBytes;
          }
        } catch (e) {
             print('Error downloading product image: $e');
        }
      }

      setState(() {
        _detectedName = result.name;
        _detectedCalories = result.calories;
        _detectedProtein = result.protein;
        _detectedFat = result.fat;
        _detectedCarbs = result.carbs;
        _imageBytes = imageBytes;
        _hasResult = true;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _hasResult = false;
        _detectedName = '';
        _detectedCalories = 0;
      });
    }
  }

  Future<void> _analyzeFood() async {
    if (_imageBytes == null) return;

    setState(() => _isAnalyzing = true);
    try {
      final appState = context.read<AppState>();
      final result = await appState.analyzeFoodImage(_imageBytes!, prompt: _promptController.text);

      if (result != null) {
        setState(() {
          _detectedName = appState.getLocalizedFoodName(result);
          _detectedCalories = result.calories;
          _detectedProtein = result.protein ?? 0.0;
          _detectedFat = result.fat ?? 0.0;
          _detectedCarbs = result.carbs ?? 0.0;
          _hasResult = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(I18n.t('ai_error', context.read<AppState>().locale))),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _saveLog() async {
    if (_hasResult) {
      try {
        final appState = context.read<AppState>();
        final food = Food(
          name: _detectedName,
          calories: _detectedCalories,
          protein: _detectedProtein,
          fat: _detectedFat,
          carbs: _detectedCarbs,
          createdAt: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, DateTime.now().minute, DateTime.now().second),
          userId: appState.currentUser?.id ?? 0,
        );

        await appState.addFood(food, imageBytes: _imageBytes);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Error saving log'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.t('log_meal', state.locale), style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageContainer(isDark),
            const SizedBox(height: 16),
            if (_imageBytes != null && !_hasResult && !_isAnalyzing) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _promptController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Describe your meal (optional, e.g. "200g Greek Salad")',
                  hintStyle: const TextStyle(fontSize: 12),
                  filled: true,
                  fillColor: isDark ? AppTheme.darkGray : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _analyzeFood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.green,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('ANALYZE MEAL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
            if (_isAnalyzing)
              _buildAnalyzingState(isDark)
            else if (_hasResult)
              _buildResultCard(isDark),
            const SizedBox(height: 40),
            if (!_isAnalyzing && _hasResult) 
              ElevatedButton(
                onPressed: _saveLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.green,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  I18n.t('save_log', state.locale).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            if (!_isAnalyzing && !_hasResult && _imageBytes == null)
              ElevatedButton(
                onPressed: () => _showImageSourceOptions(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.green,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  I18n.t('log_meal', state.locale).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer(bool isDark) {
    return GestureDetector(
      onTap: () => _showImageSourceOptions(),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkGray : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppTheme.green.withOpacity(0.1)),
          image: _imageBytes != null
              ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
              : null,
        ),
        child: _imageBytes == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded, size: 64, color: AppTheme.green),
                  SizedBox(height: 16),
                  Text('Snap your meal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildAnalyzingState(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 32),
        const CircularProgressIndicator(color: AppTheme.green),
        const SizedBox(height: 24),
        Text('AI Analyzing...', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)),
      ],
    );
  }

  Widget _buildResultCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.green.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(_detectedName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${_detectedCalories.toInt()} kcal', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.green)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroAdjuster('Protein', _detectedProtein),
              _buildMacroAdjuster('Carbs', _detectedCarbs),
              _buildMacroAdjuster('Fat', _detectedFat),
            ],
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => setState(() => _hasResult = false),
            child: const Text('Change photo/prompt', style: TextStyle(color: AppTheme.green)),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroAdjuster(String label, double value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('${value.toInt()}g', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.green),
              title: const Text('Camera'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppTheme.green),
              title: const Text('Gallery'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.green),
              title: const Text('Scan Barcode'),
              subtitle: const Text('Automatic nutrition lookup'),
              onTap: () { Navigator.pop(context); _scanBarcode(); },
            ),
          ],
        ),
      ),
    );
  }
}
