import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
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
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  String _gender = 'male';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final user = User(
        userInfoId: widget.userInfoId,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        gender: _gender,
        height: int.parse(_heightController.text),
        currentWeight: double.parse(_currentWeightController.text),
        targetWeight: double.parse(_targetWeightController.text),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      context.read<AuthBloc>().add(AuthUserUpdateRequested(user));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0F0F), Color(0xFF001A0F)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'auth.welcome_title'.tr().isNotEmpty ? 'auth.welcome_title'.tr() : 'Welcome!',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'auth.welcome_subtitle'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  _buildSectionTitle('auth.basic_info'.tr()),
                  _buildTextField(_nameController, 'auth.full_name'.tr(), Icons.person_outline),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_ageController, 'auth.age'.tr(), Icons.calendar_today_outlined, isNumeric: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildGenderSelector()),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionTitle('auth.physical_metrics'.tr()),
                  _buildTextField(_heightController, 'auth.height'.tr(), Icons.height, isNumeric: true),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_currentWeightController, 'auth.current_weight'.tr(), Icons.monitor_weight_outlined, isNumeric: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(_targetWeightController, 'auth.target_weight'.tr(), Icons.flag_outlined, isNumeric: true)),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'common.get_started'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor.withValues(alpha: 0.7)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'common.error_required'.tr();
        if (isNumeric && (double.tryParse(value) == null)) return 'common.error_invalid_number'.tr();
        return null;
      },
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _gender,
          dropdownColor: const Color(0xFF1A1A1A),
          style: const TextStyle(color: Colors.white),
          items: [
            DropdownMenuItem(value: 'male', child: Text('common.male'.tr())),
            DropdownMenuItem(value: 'female', child: Text('common.female'.tr())),
            DropdownMenuItem(value: 'other', child: Text('common.other'.tr())),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _gender = value);
          },
        ),
      ),
    );
  }
}
