import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/shared/presentation/theme/theme.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';

class ProfileSetupScreen extends StatefulWidget {
  final int userInfoId;
  const ProfileSetupScreen({super.key, required this.userInfoId});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _gender = 'male';
  double _age = 25;
  double _height = 170;
  double _currentWeight = 70;
  double _targetWeight = 65;
  double _monthlyLoss = 4.0;
  String _activityLevel = 'moderate';

  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (mounted) setState(() => _errorMessage = null);
      final user = User(
        userInfoId: widget.userInfoId,
        name: _nameController.text.trim(),
        age: _age.toInt(),
        gender: _gender,
        height: _height.toInt(),
        currentWeight: double.parse(_currentWeight.toStringAsFixed(1)),
        targetWeight: double.parse(_targetWeight.toStringAsFixed(1)),
        activityLevel: _activityLevel,
        monthlyWeightLossGoal: double.parse(_monthlyLoss.toStringAsFixed(1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      context.read<AuthBloc>().add(AuthUserUpdateRequested(user));
    }
  }

  void _showPicker(BuildContext context, {
    required String title,
    required double initialValue,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onSelectedItemChanged,
    required String unit,
    bool isDecimal = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = List.generate(
      ((max - min) * divisions).toInt() + 1,
      (index) => min + (index / divisions),
    );

    int initialIndex = items.indexWhere((val) => (val - initialValue).abs() < 0.01);
    if (initialIndex == -1) initialIndex = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Theme.of(context).brightness,
                  ),
                  child: CupertinoPicker(
                    magnification: 1.22,
                    squeeze: 1.2,
                    useMagnifier: true,
                    itemExtent: 48,
                    scrollController: FixedExtentScrollController(initialItem: initialIndex),
                    onSelectedItemChanged: (index) {
                      onSelectedItemChanged(items[index]);
                    },
                    children: items.map((val) {
                      final text = isDecimal ? val.toStringAsFixed(1) : val.toInt().toString();
                      return Center(
                        child: Text(
                          '$text $unit',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text("Tasdiqlash", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          failure: (error) {
            if (mounted) setState(() => _errorMessage = error.userFriendlyMessage);
          },
        );
      },
      builder: (context, state) {
        final isLoading = state is AuthPrepare;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shaxsiylashtirish',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87, letterSpacing: -1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sizga eng to'g'ri ovqatlanish rejasini va maqsadlarni tavsiya qilishimiz uchun kerak.",
                      style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54, height: 1.5),
                    ),
                    const SizedBox(height: 40),

                    _buildSectionLabel('ISMINGIZ'),
                    TextFormField(
                      controller: _nameController,
                      enabled: !isLoading,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'Ismingizni kiriting',
                        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Ism kiritilishi shart' : null,
                    ),
                    const SizedBox(height: 32),

                    _buildSectionLabel('JINSINGIZ'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSelectableCard(
                            icon: Icons.male_rounded,
                            label: 'Erkak',
                            isSelected: _gender == 'male',
                            isDark: isDark,
                            onTap: isLoading ? null : () => setState(() => _gender = 'male'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSelectableCard(
                            icon: Icons.female_rounded,
                            label: 'Ayol',
                            isSelected: _gender == 'female',
                            isDark: isDark,
                            onTap: isLoading ? null : () => setState(() => _gender = 'female'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    _buildPickerWidget(
                      label: 'YOSHINGIZ',
                      value: _age,
                      unit: 'yosh',
                      isDark: isDark,
                      onTap: isLoading ? null : () => _showPicker(
                        context,
                        title: "Yoshingizni tanlang",
                        initialValue: _age,
                        min: 10, max: 100, divisions: 1,
                        onSelectedItemChanged: (val) => setState(() => _age = val),
                        unit: 'yosh',
                      ),
                    ),

                    _buildPickerWidget(
                      label: "BO'YINGIZ",
                      value: _height,
                      unit: 'sm',
                      isDark: isDark,
                      onTap: isLoading ? null : () => _showPicker(
                        context,
                        title: "Bo'yingizni tanlang",
                        initialValue: _height,
                        min: 100, max: 230, divisions: 1,
                        onSelectedItemChanged: (val) => setState(() => _height = val),
                        unit: 'sm',
                      ),
                    ),

                    _buildPickerWidget(
                      label: 'HOZIRGI VAZNINGIZ',
                      value: _currentWeight,
                      unit: 'kg',
                      isDark: isDark,
                      isDecimal: true,
                      onTap: isLoading ? null : () => _showPicker(
                        context,
                        title: "Hozirgi vazningiz",
                        initialValue: _currentWeight,
                        min: 30, max: 200, divisions: 10,
                        onSelectedItemChanged: (val) => setState(() => _currentWeight = val),
                        unit: 'kg',
                        isDecimal: true,
                      ),
                    ),

                    _buildPickerWidget(
                      label: 'MAQSADLI VAZN',
                      value: _targetWeight,
                      unit: 'kg',
                      isDark: isDark,
                      isDecimal: true,
                      onTap: isLoading ? null : () => _showPicker(
                        context,
                        title: "Maqsadli vazn",
                        initialValue: _targetWeight,
                        min: 30, max: 200, divisions: 10,
                        onSelectedItemChanged: (val) => setState(() => _targetWeight = val),
                        unit: 'kg',
                        isDecimal: true,
                      ),
                    ),

                    _buildPickerWidget(
                      label: '1 OYDA QANCHA OZMOQCHISIZ?',
                      value: _monthlyLoss,
                      unit: 'kg',
                      isDark: isDark,
                      isDecimal: true,
                      onTap: isLoading ? null : () => _showPicker(
                        context,
                        title: "Oylik maqsad (kg)",
                        initialValue: _monthlyLoss,
                        min: 0.5, max: 12, divisions: 10,
                        onSelectedItemChanged: (val) => setState(() => _monthlyLoss = val),
                        unit: 'kg',
                        isDecimal: true,
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildSectionLabel('FAOLLIK DARAJANGIZ'),
                    _buildActivityList(isDark, isLoading),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 24),
                      _ErrorBox(message: _errorMessage!),
                    ],

                    const SizedBox(height: 56),

                    Container(
                      width: double.infinity,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const _Spinner()
                            : const Text('Boshlash', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildSelectableCard({required IconData icon, required String label, required bool isSelected, required bool isDark, required VoidCallback? onTap}) {
    final bgColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white54 : Colors.black45)),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerWidget({
    required String label,
    required double value,
    required String unit,
    required bool isDark,
    required VoidCallback? onTap,
    bool isDecimal = false,
  }) {
    final displayValue = isDecimal ? value.toStringAsFixed(1) : value.toInt().toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(label),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: displayValue, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
                        TextSpan(text: ' $unit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.black54)),
                      ],
                    ),
                  ),
                  Icon(Icons.unfold_more_rounded, color: AppTheme.primaryColor.withValues(alpha: 0.8)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(bool isDark, bool isLoading) {
    final activities = [
      {'id': 'sedentary', 'icon': Icons.chair_alt_rounded, 'title': 'Kam harakat', 'subtitle': "Asosan o'tirib ishlash, harakat kam"},
      {'id': 'light', 'icon': Icons.directions_walk_rounded, 'title': "O'rtacha faol", 'subtitle': "Kunda ozgina piyoda, yengil mashq"},
      {'id': 'moderate', 'icon': Icons.fitness_center_rounded, 'title': 'Faol', 'subtitle': "Haftada 3-4 marta barqaror sport"},
      {'id': 'active', 'icon': Icons.directions_run_rounded, 'title': 'Juda faol', 'subtitle': "Har kuni og'ir harakat yoki sport"},
    ];

    return Column(
      children: activities.map((act) {
        final isSelected = _activityLevel == act['id'];
        final bgColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05);

        return GestureDetector(
          onTap: isLoading ? null : () => setState(() => _activityLevel = act['id'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : bgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.transparent, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white12 : Colors.black12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(act['icon'] as IconData, color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(act['title'] as String, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 4),
                      Text(act['subtitle'] as String, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor, size: 28),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
    );
  }
}
