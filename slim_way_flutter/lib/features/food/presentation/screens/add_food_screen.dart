import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/shared/presentation/theme/theme.dart';
import 'package:slim_way_flutter/shared/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:slim_way_flutter/features/home/presentation/blocs/summary_bloc/summary_bloc.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:slim_way_flutter/features/food/presentation/blocs/food_bloc/food_bloc.dart';
import 'package:slim_way_flutter/shared/utils/barcode_service.dart';
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
  String? _detectedTips;
  String? _detectedPortion;
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
      Uint8List? imageBytes;
      if (result.imageUrl != null) {
        try {
          final response = await http.get(Uri.parse(result.imageUrl!));
          if (response.statusCode == 200) {
            imageBytes = response.bodyBytes;
          }
        } catch (e) {
          debugPrint('Error downloading product image: $e');
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
    context.read<FoodBloc>().add(FoodAnalyzeRequested(_imageBytes!, prompt: _promptController.text));
  }

  Future<void> _saveLog() async {
    if (_hasResult) {
      final authState = context.read<AuthBloc>().state;
      final userId = authState.whenOrNull(authenticated: (u) => u.id);
      if (userId == null) return;

      final food = Food(
        name: _detectedName,
        calories: _detectedCalories,
        protein: _detectedProtein,
        fat: _detectedFat,
        carbs: _detectedCarbs,
        createdAt: DateTime.now().toUtc(),
        userId: userId,
      );

      context.read<FoodBloc>().add(FoodAddRequested(food, imageBytes: _imageBytes));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return BlocListener<FoodBloc, FoodState>(
          listener: (context, state) {
            state.whenOrNull(
              success: (_, analysisResult) {
                if (analysisResult != null) {
                  setState(() {
                    final locale = context.locale.languageCode;
                    if (locale == 'uz') {
                      _detectedName = analysisResult.nameUz ?? 'common.unknown'.tr();
                      _detectedTips = analysisResult.tipsUz;
                    } else if (locale == 'ru') {
                      _detectedName = analysisResult.nameRu ?? 'common.unknown'.tr();
                      _detectedTips = analysisResult.tipsRu;
                    } else {
                      _detectedName = analysisResult.nameEn ?? 'common.unknown'.tr();
                      _detectedTips = analysisResult.tipsEn;
                    }

                    _detectedCalories = analysisResult.calories;
                    _detectedProtein = analysisResult.protein ?? 0.0;
                    _detectedFat = analysisResult.fat ?? 0.0;
                    _detectedCarbs = analysisResult.carbs ?? 0.0;
                    _detectedPortion = analysisResult.portionSize;
                    _hasResult = true;
                  });

                }
              },
              added: () {
                context.read<SummaryBloc>().add(SummaryRefreshRequested());
                Navigator.pop(context);
              },
              failure: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error.toString()), backgroundColor: Colors.redAccent),
                );
              },
            );
          },
          child: BlocBuilder<FoodBloc, FoodState>(
            builder: (context, foodState) {
              final isAnalyzing = foodState is FoodPrepare;
              final isAdding = foodState is FoodAdded; // Should check if it was adding but FoodAdded is a final state

              return Scaffold(
                appBar: AppBar(
                  title: Text('dashboard.log_meal'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () {
                      context.read<FoodBloc>().add(FoodReset());
                      Navigator.pop(context);
                    },
                  ),
                ),
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildImageContainer(isDark),
                      SizedBox(height: 16.h),
                      if (_imageBytes != null && !_hasResult && !isAnalyzing) ...[
                        SizedBox(height: 8.h),
                        TextField(
                          controller: _promptController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'ai.prompt_hint'.tr(),
                            hintStyle: TextStyle(fontSize: 12.sp),
                            filled: true,
                            fillColor: isDark ? AppTheme.darkGray : Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: _analyzeFood,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.green,
                            minimumSize: Size(double.infinity, 56.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          ),
                          child: Text('ai.analyze_btn'.tr().toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14.sp)),
                        ),

                      ],
                      if (isAnalyzing)
                        _buildAnalyzingState(isDark)
                      else if (_hasResult)
                        _buildResultCard(isDark),
                      const SizedBox(height: 40),
                      if (!isAnalyzing && _hasResult)
                        ElevatedButton(
                          onPressed: isAdding ? null : _saveLog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.green,
                            minimumSize: Size(double.infinity, 64.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                          ),
                          child: isAdding 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'common.save'.tr().toUpperCase(),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp),
                              ),
                        ),
                      if (!isAnalyzing && !_hasResult && _imageBytes == null)
                        ElevatedButton(
                          onPressed: () => _showImageSourceOptions(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.green,
                            minimumSize: Size(double.infinity, 64.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                          ),
                          child: Text(
                            'dashboard.log_meal'.tr().toUpperCase(),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildImageContainer(bool isDark) {
    return GestureDetector(
      onTap: () => _showImageSourceOptions(),
      child: Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkGray : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(32.r),
          border: Border.all(color: AppTheme.green.withValues(alpha: 0.1)),
          image: _imageBytes != null
              ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
              : null,
        ),
        child: _imageBytes == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded, size: 64.r, color: AppTheme.green),
                  SizedBox(height: 16.h),
                  Text('auth.camera'.tr(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14.sp)), 
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
        Text('ai.analyzing'.tr(), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)),

      ],
    );
  }

  Widget _buildResultCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppTheme.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppTheme.green.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Fixed overflow by using Column and softWrap
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _detectedName, 
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (_detectedPortion != null)
                Text(
                  ' ($_detectedPortion)', 
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '${_detectedCalories.toInt()} ${'food.unit_kcal'.tr()}', 
            style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w900, color: AppTheme.green)
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroAdjuster('auth.protein'.tr(), _detectedProtein),
              _buildMacroAdjuster('auth.carbs'.tr(), _detectedCarbs),
              _buildMacroAdjuster('auth.fat'.tr(), _detectedFat),
            ],
          ),
          if (_detectedTips != null) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Row(
               children: [
                 const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                 const SizedBox(width: 8),
                 Text('ai.tip_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
               ],
            ),
            const SizedBox(height: 8),
            Text(_detectedTips!, style: const TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => setState(() => _hasResult = false),
            child: Text('barcode.use_photo'.tr(), style: const TextStyle(color: AppTheme.green)),
          ),
        ],

      ),
    );
  }

  Widget _buildMacroAdjuster(String label, double value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.grey, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        Text('${value.toInt()}g', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
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
              title: Text('auth.camera'.tr()),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppTheme.green),
              title: Text('auth.gallery'.tr()),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.green),
              title: Text('barcode.title'.tr()),
              subtitle: Text('barcode.msg'.tr()),

              onTap: () { Navigator.pop(context); _scanBarcode(); },
            ),
          ],
        ),
      ),
    );
  }
}
