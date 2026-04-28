import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../core/theme/app_theme.dart';
import '../models/device_model.dart';

class DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onToggle,
    required this.onDelete,
  });

  Color get _accentColor {
    switch (device.type) {
      case DeviceType.light:  return const Color(0xFFFFD166);
      case DeviceType.fan:    return const Color(0xFF60B8FF);
      case DeviceType.ac:     return const Color(0xFF8EECF5);
      case DeviceType.socket: return const Color(0xFFFF8C69);
      case DeviceType.lock:   return const Color(0xFFB8A9FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _confirmDelete(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: device.isOn
              ? _accentColor.withOpacity(0.12)
              : AppTheme.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: device.isOn
                ? _accentColor.withOpacity(0.35)
                : AppTheme.border,
            width: 1.5,
          ),
          boxShadow: device.isOn
              ? [
                  BoxShadow(
                    color: _accentColor.withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: device.isOn
                      ? _accentColor.withOpacity(0.22)
                      : AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  device.icon,
                  color: device.isOn ? _accentColor : AppTheme.textMuted,
                  size: 24,
                ),
              ),
              const Spacer(),
              // Name
              Text(
                device.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: device.isOn ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(3),
              Text(
                device.isOn ? 'ON' : 'OFF',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: device.isOn ? _accentColor : AppTheme.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const Gap(12),
              // Toggle
              Align(
                alignment: Alignment.centerRight,
                child: Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: device.isOn,
                    onChanged: onToggle,
                    activeColor: _accentColor,
                    activeTrackColor: _accentColor.withOpacity(0.25),
                    inactiveThumbColor: AppTheme.textMuted,
                    inactiveTrackColor: AppTheme.surfaceAlt,
                    trackOutlineColor:
                        WidgetStateProperty.all(Colors.transparent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Remove Device',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Remove "${device.name}" from your home?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Remove',
                style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
