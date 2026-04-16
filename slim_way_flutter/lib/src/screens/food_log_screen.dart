import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slim_way_client/slim_way_client.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils/i18n.dart';
import 'dart:typed_data';

class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({super.key});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  final _promptController = TextEditingController();
  String _detectedName = '';
  double _detectedCalories = 0.0;
  Uint8List? _imageBytes;
  final _picker = ImagePicker();
  bool _isAnalyzing = false;
  bool _hasResult = false;

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
        _isAnalyzing = true;
        _hasResult = false;
      });

      try {
        final appState = context.read<AppState>();
        // Future improvement: Send _promptController.text to AI
        final result = await appState.analyzeFoodImage(bytes);

        if (result != null) {
          setState(() {
            _detectedName = result.name;
            _detectedCalories = result.calories;
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
  }

  Future<void> _saveLog() async {
    if (_hasResult) {
      try {
        final appState = context.read<AppState>();
        final food = Food(
          name: _detectedName,
          calories: _detectedCalories,
          createdAt: DateTime.now(),
          userId: appState.currentUser?.id ?? 0,
        );

        await appState.addFood(food, imageBytes: _imageBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(I18n.t('save_log', appState.locale)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.accentColor,
            ),
          );
          appState.selectedTabIndex = 0;
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
    final locale = state.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          I18n.t('log_meal', locale),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppTheme.accentColor),
            onPressed: () => Navigator.pushNamed(context, '/food-history'),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildImageContainer(isDark),
              const SizedBox(height: 32),
              if (_isAnalyzing)
                _buildAnalyzingState(isDark, locale)
              else if (_hasResult)
                _buildResultCard(isDark, locale)
              else
                _buildPromptInput(isDark, locale),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomAction(locale),
    );
  }

  Widget _buildImageContainer(bool isDark) {
    return GestureDetector(
      onTap: () => _showImageSourceOptions(),
      child: Hero(
        tag: 'food_photo',
        child: Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: AppTheme.accentColor.withOpacity(0.1)),
            image: _imageBytes != null
                ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                : null,
          ),
          child: _imageBytes == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined, size: 64, color: AppTheme.accentColor),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to Snap Meal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: (isDark ? Colors.white38 : Colors.black38),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildAnalyzingState(bool isDark, String locale) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentColor),
        const SizedBox(height: 24),
        Text(
          'AI is studying your meal...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(bool isDark, String locale) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _detectedName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppTheme.accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(
              '~ ${_detectedCalories.toInt()} kcal',
              style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => setState(() {
              _hasResult = false;
              _imageBytes = null;
            }),
            child: const Text('Retake Photo', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptInput(bool isDark, String locale) {
    return TextField(
      controller: _promptController,
      maxLines: 2,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: 'Add context (e.g. "Spicy", "Homemade")',
        hintStyle: TextStyle(color: (isDark ? Colors.white.withOpacity(0.24) : Colors.black.withOpacity(0.24))),
        filled: true,
        fillColor: (isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildBottomAction(String locale) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: 64,
        child: ElevatedButton(
          onPressed: _hasResult ? _saveLog : () => _showImageSourceOptions(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(
            (_hasResult ? I18n.t('save_log', locale) : I18n.t('log_meal', locale)).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ),
      ),
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.accentColor),
              title: const Text('Camera', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppTheme.accentColor),
              title: const Text('Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
