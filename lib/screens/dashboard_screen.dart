import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../core/theme/app_theme.dart';
import '../models/device_model.dart';
import '../providers/providers.dart';
import '../widgets/device_card.dart';
import '../widgets/add_device_sheet.dart';
import '../widgets/stat_chip.dart';
import 'connection_screen.dart';
import '../core/services/mqtt_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(devicesProvider);
    final activeCount = devices.where((d) => d.isOn).length;
    final rooms = devices.map((d) => d.room).toSet().toList()..sort();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good ${_greeting()},',
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const Text(
                            'My Home',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const _StatusDot(),
                    const Gap(10),
                    // FIX: read mqtt inside the callback, not outside
                    _IconBtn(
                      icon: Icons.power_settings_new_rounded,
                      color: AppTheme.danger,
                      onTap: () {
                        ref.read(mqttServiceProvider).disconnect();
                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                const ConnectionScreen(),
                            transitionsBuilder: (_, anim, __, child) =>
                                FadeTransition(opacity: anim, child: child),
                          ),
                        );
                      },
                    ),
                  ],
                ).animate().fadeIn(),
              ),
            ),

            // ── Stats Row ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: StatChip(
                        icon: Icons.devices_rounded,
                        label: 'Total',
                        value: '${devices.length}',
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: StatChip(
                        icon: Icons.power_rounded,
                        label: 'Active',
                        value: '$activeCount',
                        color: AppTheme.accent,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: StatChip(
                        icon: Icons.nightlight_rounded,
                        label: 'Idle',
                        value: '${devices.length - activeCount}',
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms),
              ),
            ),

            // ── Devices by Room ───────────────────────────────────────
            for (final room in rooms) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 14),
                  child: Row(
                    children: [
                      const Icon(Icons.meeting_room_rounded,
                          size: 14, color: AppTheme.textMuted),
                      const Gap(6),
                      Text(
                        room.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMuted,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final roomDevices =
                          devices.where((d) => d.room == room).toList();
                      if (i >= roomDevices.length) return null;

                      final device = roomDevices[i];
                      final globalIndex = devices.indexOf(device);

                      return DeviceCard(
                        device: device,
                        onToggle: (val) => ref
                            .read(devicesProvider.notifier)
                            .toggle(device.id, val),
                        onDelete: () => ref
                            .read(devicesProvider.notifier)
                            .removeDevice(device.id),
                      ).animate().fadeIn(
                            delay: Duration(milliseconds: 80 * globalIndex),
                          );
                    },
                    childCount: devices.where((d) => d.room == room).length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: Gap(120)),
          ],
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDevice(context, ref),
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Device',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
    );
  }

  void _showAddDevice(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AddDeviceSheet(
        onAdd: (device) => ref.read(devicesProvider.notifier).addDevice(device),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

// ── Status Dot ────────────────────────────────────────────────────────────────
class _StatusDot extends ConsumerWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mqttStateProvider);
    // FIX: compare directly with enum value instead of string
    final isConnected = state.maybeWhen(
      data: (s) => s == MqttAppState.connected,
      orElse: () => false,
    );

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isConnected ? AppTheme.accent : AppTheme.danger,
        boxShadow: [
          BoxShadow(
            color: (isConnected ? AppTheme.accent : AppTheme.danger)
                .withOpacity(0.5),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}

// ── Icon Button ───────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
