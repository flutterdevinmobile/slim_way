import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:vibration/vibration.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/shared/presentation/theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';


class WaterTrackerCard extends StatefulWidget {
  final DailyLog? log;
  final int glassSize;
  final VoidCallback onAdd;
  final Function(int) onUpdate;

  const WaterTrackerCard({
    super.key,
    required this.log,
    required this.glassSize,
    required this.onAdd,
    required this.onUpdate,
  });

  @override
  State<WaterTrackerCard> createState() => _WaterTrackerCardState();
}

class _WaterTrackerCardState extends State<WaterTrackerCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAdd() async {
    widget.onAdd();
    _controller.forward(from: 0);
    
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 50);
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final waterMl = widget.log?.waterMl ?? 0;

    const goal = 2500; // Hardcoded goal for now

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGray : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'home.water_intake'.tr(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              Row(
                children: [
                  Lottie.network(
                    'https://lottie.host/809c95d9-4d62-430c-99d8-98e3b1c67d64/vNfR9Xpx6k.json',
                    controller: _controller,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.water_drop_rounded, color: AppTheme.green, size: 24),
                  ),

                  const SizedBox(width: 8),
                  Text(
                    '$waterMl / $goal ml',
                    style: const TextStyle(color: AppTheme.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (waterMl / goal).clamp(0.0, 1.0),
                  backgroundColor: AppTheme.green.withValues(alpha: 0.1),
                  color: AppTheme.green,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onAdd,

                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.green.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.add_rounded, color: AppTheme.green, size: 28),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) {
                  if (value == 'subtract') {
                    widget.onUpdate(-widget.glassSize);
                  }
                },

                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'subtract',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
                        SizedBox(width: 8),
                        Text('food.undo'.tr(), style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
