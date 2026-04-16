import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slim_way_client/slim_way_client.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils/i18n.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final locale = state.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.green)));

    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.t('profile', locale), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_note_rounded, color: AppTheme.green),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildProfileHeader(user, state, isDark),
            const SizedBox(height: 40),
            _isEditing 
                ? _buildEditForm(user, state, locale, isDark) 
                : _buildProfileInfo(user, locale, isDark),
            const SizedBox(height: 48),
            _buildSettingsGrid(state, isDark, locale),
            const SizedBox(height: 48),
            _buildLogoutButton(state, locale),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user, AppState state, bool isDark) {
    Uint8List? imageBytes;
    if (user.photoUrl != null && user.photoUrl!.startsWith('data:image')) {
      try {
        imageBytes = base64Decode(user.photoUrl!.split(',').last);
      } catch (_) {}
    }

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.green.withOpacity(0.2), width: 3),
            ),
            child: CircleAvatar(
              radius: 64,
              backgroundColor: isDark ? AppTheme.darkGray : Colors.grey.shade200,
              backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
              child: imageBytes == null ? const Icon(Icons.person_rounded, size: 60, color: AppTheme.green) : null,
            ),
          ),
          if (_isEditing)
            GestureDetector(
              onTap: () => _pickImage(state, user),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: AppTheme.green, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage(AppState state, User user) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 400, imageQuality: 60);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      user.photoUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      await state.updateUser(user);
    }
  }

  Widget _buildProfileInfo(User user, String locale, bool isDark) {
    return Column(
      children: [
        Text(user.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('WEIGHT', '${user.currentWeight}'),
            Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
            _buildStatItem('GOAL', '${user.targetWeight}'),
            Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
            _buildStatItem('AGE', '${user.age}'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.green)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }

  Widget _buildEditForm(User user, AppState state, String locale, bool isDark) {
    final nameCtrl = TextEditingController(text: user.name);
    final weightCtrl = TextEditingController(text: user.currentWeight.toString());
    final targetCtrl = TextEditingController(text: user.targetWeight.toString());

    return Column(
      children: [
        _buildTextField(nameCtrl, 'Full Name', Icons.person_outline_rounded),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField(weightCtrl, 'Weight', Icons.monitor_weight_outlined, isNumeric: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(targetCtrl, 'Target', Icons.flag_outlined, isNumeric: true)),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () async {
              user.name = nameCtrl.text;
              user.currentWeight = double.tryParse(weightCtrl.text) ?? user.currentWeight;
              user.targetWeight = double.tryParse(targetCtrl.text) ?? user.targetWeight;
              await state.updateUser(user);
              setState(() => _isEditing = false);
            },
            child: const Text('SAVE CHANGES'),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {bool isNumeric = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.green),
        filled: true,
        fillColor: AppTheme.green.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSettingsGrid(AppState state, bool isDark, String locale) {
    return Column(
      children: [
        _buildSettingTile(
          I18n.t('language', locale),
          'Select app language',
          Icons.language_rounded,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: ['uz', 'en', 'ru'].map((l) {
              final isSel = state.locale == l;
              return GestureDetector(
                onTap: () => state.setLocale(l),
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSel ? AppTheme.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSel ? AppTheme.green : Colors.grey.withOpacity(0.3)),
                  ),
                  child: Text(l.toUpperCase(), style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.grey
                  )),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingTile(
          I18n.t('appearance', locale),
          isDark ? 'Dark Mode Active' : 'Light Mode Active',
          Icons.dark_mode_rounded,
          Switch(
            value: isDark,
            activeColor: AppTheme.green,
            onChanged: (v) => state.toggleTheme(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(String title, String subtitle, IconData icon, Widget trailing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGray : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.green.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.green.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: AppTheme.green, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AppState state, String locale) {
    return TextButton.icon(
      onPressed: () => state.logout(),
      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
      label: Text(I18n.t('logout', locale), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
    );
  }
}
