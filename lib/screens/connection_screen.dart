import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../core/theme/app_theme.dart';
import '../models/connection_config.dart';
import '../providers/providers.dart';
import 'dashboard_screen.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brokerCtrl = TextEditingController();
  final _portCtrl = TextEditingController();
  final _clientCtrl = TextEditingController();

  bool _isConnecting = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final config = await ref.read(prefsServiceProvider).loadConfig();
    if (!mounted) return;
    _brokerCtrl.text = config.brokerUrl;
    _portCtrl.text = config.port.toString();
    _clientCtrl.text = config.clientId;
  }

  @override
  void dispose() {
    _brokerCtrl.dispose();
    _portCtrl.dispose();
    _clientCtrl.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final port = int.tryParse(_portCtrl.text.trim());
    if (port == null) {
      setState(() => _errorMsg = 'Port must be a valid number');
      return;
    }

    setState(() {
      _isConnecting = true;
      _errorMsg = null;
    });

    final config = ConnectionConfig(
      brokerUrl: _brokerCtrl.text.trim(),
      port: port,
      clientId: _clientCtrl.text.trim(),
    );

    await ref.read(prefsServiceProvider).saveConfig(config);

    final mqtt = ref.read(mqttServiceProvider);
    final success = await mqtt.connect(
      brokerUrl: config.brokerUrl,
      port: config.port,
      clientId: config.clientId,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const DashboardScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      setState(() {
        _isConnecting = false;
        _errorMsg = 'Connection failed. Check broker URL and port.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const Gap(40),
                _buildForm(),
                if (_errorMsg != null) ...[
                  const Gap(16),
                  _buildError(),
                ],
                const Gap(32),
                _buildConnectButton(),
                const Gap(40),
                _buildPresets(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.accentGlow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
          ),
          child:
              const Icon(Icons.home_rounded, color: AppTheme.accent, size: 30),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const Gap(22),
        const Text(
          'Smart Home',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -1,
            height: 1.0,
          ),
        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.08),
        const Gap(4),
        const Text(
          'Controller',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: AppTheme.accent,
            letterSpacing: -1,
            height: 1.0,
          ),
        ).animate().fadeIn(delay: 180.ms).slideX(begin: -0.08),
        const Gap(14),
        const Text(
          'Connect to your MQTT broker\nto control your home.',
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textSecondary,
            height: 1.55,
          ),
        ).animate().fadeIn(delay: 280.ms),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _InputField(
            label: 'BROKER URL',
            hint: 'broker.hivemq.com',
            controller: _brokerCtrl,
            icon: Icons.dns_rounded,
            validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.12),
          const Gap(16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _InputField(
                  label: 'PORT',
                  hint: '1883',
                  controller: _portCtrl,
                  icon: Icons.settings_ethernet_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return 'Required';
                    if (int.tryParse(v!.trim()) == null) return 'Invalid';
                    return null;
                  },
                ),
              ),
              const Gap(12),
              Expanded(
                flex: 3,
                child: _InputField(
                  label: 'CLIENT ID',
                  hint: 'smart_home_001',
                  controller: _clientCtrl,
                  icon: Icons.fingerprint_rounded,
                  validator: (v) =>
                      (v?.trim().isEmpty ?? true) ? 'Required' : null,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 360.ms).slideY(begin: 0.12),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.danger.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppTheme.danger, size: 18),
          const Gap(10),
          Expanded(
            child: Text(
              _errorMsg!,
              style: const TextStyle(color: AppTheme.danger, fontSize: 13),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().shake(hz: 3, offset: const Offset(4, 0));
  }

  Widget _buildConnectButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _isConnecting
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF00D4AA), Color(0xFF00A882)],
                ),
          color: _isConnecting ? AppTheme.card : null,
          boxShadow: _isConnecting
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.40),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isConnecting ? null : _connect,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: _isConnecting
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: AppTheme.accent,
                          ),
                        ),
                        Gap(12),
                        Text(
                          'Connecting...',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Connect to Broker',
                      style: TextStyle(
                        color: AppTheme.background,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 420.ms).slideY(begin: 0.1);
  }

  Widget _buildPresets() {
    const presets = [
      ('HiveMQ', 'broker.hivemq.com'),
      ('EMQX', 'broker.emqx.io'),
      ('Mosquitto', 'test.mosquitto.org'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK PRESETS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
            letterSpacing: 1.4,
          ),
        ),
        const Gap(12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: presets.map((p) {
            return GestureDetector(
              onTap: () => setState(() => _brokerCtrl.text = p.$2),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  p.$1,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }
}

// ── Reusable Input Field ──────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 1.1,
          ),
        ),
        const Gap(8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textMuted.withOpacity(0.7),
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 18),
            filled: true,
            fillColor: AppTheme.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
