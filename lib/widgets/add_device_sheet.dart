import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../core/theme/app_theme.dart';
import '../models/device_model.dart';

class AddDeviceSheet extends StatefulWidget {
  final void Function(DeviceModel device) onAdd;

  const AddDeviceSheet({super.key, required this.onAdd});

  @override
  State<AddDeviceSheet> createState() => _AddDeviceSheetState();
}

class _AddDeviceSheetState extends State<AddDeviceSheet> {
  final _formKey  = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _topicCtrl = TextEditingController();
  final _roomCtrl  = TextEditingController(text: 'Living Room');

  DeviceType _selectedType = DeviceType.light;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _topicCtrl.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final device = DeviceModel(
      id: 'device_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      topic: _topicCtrl.text.trim(),
      type: _selectedType,
      room: _roomCtrl.text.trim(),
    );

    widget.onAdd(device);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(20),
              const Text(
                'Add Device',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Gap(6),
              const Text(
                'Configure your new smart device',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const Gap(24),

              // Type selector
              const Text(
                'DEVICE TYPE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.1,
                ),
              ),
              const Gap(10),
              _TypeSelector(
                selected: _selectedType,
                onSelect: (t) => setState(() => _selectedType = t),
              ),
              const Gap(20),

              // Name
              _SheetField(
                label: 'DEVICE NAME',
                hint: 'e.g. Bedroom Light',
                controller: _nameCtrl,
                icon: Icons.label_rounded,
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
              ),
              const Gap(14),

              // Topic
              _SheetField(
                label: 'MQTT TOPIC',
                hint: 'e.g. home/bedroom/light',
                controller: _topicCtrl,
                icon: Icons.route_rounded,
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
              ),
              const Gap(14),

              // Room
              _SheetField(
                label: 'ROOM',
                hint: 'e.g. Bedroom',
                controller: _roomCtrl,
                icon: Icons.meeting_room_rounded,
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
              ),
              const Gap(28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [AppTheme.accent, AppTheme.accentDim],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _submit,
                      borderRadius: BorderRadius.circular(14),
                      child: const Center(
                        child: Text(
                          'Add Device',
                          style: TextStyle(
                            color: AppTheme.background,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final DeviceType selected;
  final void Function(DeviceType) onSelect;

  const _TypeSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DeviceType.values.map((type) {
          final isSelected = selected == type;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onSelect(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accentGlow : AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.accent : AppTheme.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      DeviceModel(
                        id: '',
                        name: '',
                        topic: '',
                        type: type,
                      ).icon,
                      size: 16,
                      color: isSelected ? AppTheme.accent : AppTheme.textMuted,
                    ),
                    const Gap(6),
                    Text(
                      DeviceModel(
                        id: '',
                        name: '',
                        topic: '',
                        type: type,
                      ).typeLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppTheme.accent : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?)? validator;

  const _SheetField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
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
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: AppTheme.textMuted.withOpacity(0.7), fontSize: 14),
            prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 18),
            filled: true,
            fillColor: AppTheme.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
