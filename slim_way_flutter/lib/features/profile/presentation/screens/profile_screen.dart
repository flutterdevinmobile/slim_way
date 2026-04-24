import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/shared/presentation/theme/theme.dart';
import 'package:slim_way_flutter/shared/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:slim_way_flutter/shared/utils/image_utils.dart';

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
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final user = authState.whenOrNull(authenticated: (u) => u);
            if (user == null) {
              return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.green)));
            }

            return Scaffold(
              appBar: AppBar(
                title: Text('profile.title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    _buildProfileHeader(user, isDark),
                    const SizedBox(height: 40),
                    _isEditing 
                        ? _buildEditForm(user, isDark) 
                        : _buildProfileInfo(user, isDark),
                    const SizedBox(height: 48),
                    _buildSettingsGrid(settingsState, isDark),
                    const SizedBox(height: 48),
                    _buildAchievementsSection(user, isDark),
                    const SizedBox(height: 48),
                    _buildLogoutButton(),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileHeader(User user, bool isDark) {
    final imageProvider = ImageUtils.getSafeImageProvider(user.photoUrl);

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.green.withValues(alpha: 0.2), width: 3),
            ),
            child: CircleAvatar(
              radius: 64,
              backgroundColor: isDark ? AppTheme.darkGray : Colors.grey.shade200,
              backgroundImage: imageProvider,
              child: imageProvider == null ? const Icon(Icons.person_rounded, size: 60, color: AppTheme.green) : null,
            ),
          ),
          if (_isEditing)
            GestureDetector(
              onTap: () => _pickImage(user),
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

  Future<void> _pickImage(User user) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 400, imageQuality: 60);
    if (pickedFile != null && mounted) {
      final bytes = await pickedFile.readAsBytes();
      user.photoUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      if (mounted) {
        context.read<AuthBloc>().add(AuthUserUpdateRequested(user));
      }
    }
  }

  Widget _buildProfileInfo(User user, bool isDark) {
    return Column(
      children: [
        Text(user.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('profile.stat_weight'.tr(), '${user.currentWeight}'),
            Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.2)),
            _buildStatItem('profile.stat_goal'.tr(), '${user.targetWeight}'),
            Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.2)),
            _buildStatItem('profile.stat_age'.tr(), '${user.age}'),
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

  Widget _buildEditForm(User user, bool isDark) {
    final nameCtrl = TextEditingController(text: user.name);
    final weightCtrl = TextEditingController(text: user.currentWeight.toString());
    final targetCtrl = TextEditingController(text: user.targetWeight.toString());

    return Column(
      children: [
        _buildTextField(nameCtrl, 'profile.full_name'.tr(), Icons.person_outline_rounded),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField(weightCtrl, 'profile.weight'.tr(), Icons.monitor_weight_outlined, isNumeric: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(targetCtrl, 'profile.target'.tr(), Icons.flag_outlined, isNumeric: true)),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              user.name = nameCtrl.text;
              user.currentWeight = double.tryParse(weightCtrl.text) ?? user.currentWeight;
              user.targetWeight = double.tryParse(targetCtrl.text) ?? user.targetWeight;
              context.read<AuthBloc>().add(AuthUserUpdateRequested(user));
              setState(() => _isEditing = false);
            },
            child: Text('common.save_changes'.tr()),
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
        fillColor: AppTheme.green.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSettingsGrid(SettingsState state, bool isDark) {
    return Column(
      children: [
        _buildSettingTile(
          'profile.language'.tr(),
          'profile.select_language'.tr(),
          Icons.language_rounded,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: ['uz', 'en', 'ru'].map((l) {
              final isSel = state.locale == l;
              return GestureDetector(
                onTap: () {
                  context.read<SettingsBloc>().add(LocaleChanged(l));
                  context.setLocale(Locale(l));
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSel ? AppTheme.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSel ? AppTheme.green : Colors.grey.withValues(alpha: 0.3)),
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
          'profile.appearance'.tr(),
          isDark 
              ? '${'profile.dark_mode'.tr()} ${'profile.active'.tr()}' 
              : '${'profile.light_mode'.tr()} ${'profile.active'.tr()}',
          Icons.dark_mode_rounded,
          Switch(
            value: isDark,
            activeThumbColor: AppTheme.green,
            onChanged: (v) => context.read<SettingsBloc>().add(ThemeToggled()),
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
        border: Border.all(color: AppTheme.green.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
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

  Widget _buildAchievementsSection(User user, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'achievements.title'.tr(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildBadgeItem(
                '🔥',
                'achievements.streak_name'.tr(),
                'achievements.streak_desc'.tr(),
                user.streakCount >= 7,
                isDark,
              ),
              _buildBadgeItem(
                '💧',
                'achievements.water_name'.tr(),
                'achievements.water_desc'.tr(),
                (user.waterGlassSize ?? 0) > 250, // Mock logic
                isDark,
              ),
              _buildBadgeItem(
                '🥗',
                'achievements.food_name'.tr(),
                'achievements.food_desc'.tr(),
                true,
                isDark,
              ),
              _buildBadgeItem(
                '🎯',
                'achievements.goal_name'.tr(),
                'achievements.goal_desc'.tr(),
                user.currentWeight == user.targetWeight,
                isDark,
              ),
              _buildBadgeItem(
                '🌅',
                'achievements.morning_name'.tr(),
                'achievements.morning_desc'.tr(),
                false,
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(
    String icon,
    String name,
    String desc,
    bool isEarned,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => _showAchievementDetails(icon, name, desc, isEarned),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isEarned
              ? LinearGradient(
                  colors: [AppTheme.green.withValues(alpha: 0.2), AppTheme.green.withValues(alpha: 0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isEarned ? null : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isEarned ? AppTheme.green.withValues(alpha: 0.3) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isEarned
              ? [
                  BoxShadow(
                    color: AppTheme.green.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isEarned ? Colors.white : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                icon,
                style: TextStyle(fontSize: 24, color: isEarned ? null : Colors.grey.withValues(alpha: 0.5)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isEarned ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetails(String icon, String name, String desc, bool isEarned) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (isEarned ? AppTheme.green : Colors.grey).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(icon, style: const TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 24),
              Text(
                name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (isEarned ? AppTheme.green : Colors.orange).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isEarned ? 'achievements.earned'.tr() : 'achievements.locked'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isEarned ? AppTheme.green : Colors.orange,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'achievements.how_to'.tr(),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Text(
                desc,
                style: const TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEarned ? AppTheme.green : Colors.grey.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text('common.great'.tr()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildLogoutButton() {
    return TextButton.icon(
      onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
      label: Text('profile.logout'.tr(), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
    );
  }
}
