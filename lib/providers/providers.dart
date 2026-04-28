import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/mqtt_service.dart';
import '../core/services/prefs_service.dart';
import '../models/device_model.dart';
import '../models/connection_config.dart';

// ── Services ──────────────────────────────────────────────────────────────────

final mqttServiceProvider = Provider<MqttService>((ref) {
  final service = MqttService();
  ref.onDispose(service.dispose);
  return service;
});

final prefsServiceProvider = Provider<PrefsService>((_) => PrefsService());

// ── Saved Config ──────────────────────────────────────────────────────────────

final savedConfigProvider = FutureProvider<ConnectionConfig>((ref) {
  return ref.read(prefsServiceProvider).loadConfig();
});

// ── MQTT Connection State ──────────────────────────────────────────────────────

final mqttStateProvider = StreamProvider<MqttAppState>((ref) {
  return ref.watch(mqttServiceProvider).statusStream;
});

// ── Devices ───────────────────────────────────────────────────────────────────

class DevicesNotifier extends StateNotifier<List<DeviceModel>> {
  DevicesNotifier(this._mqtt) : super(_defaultDevices) {
    _sub = _mqtt.messageStream.listen(_onMessage);
    // Subscribe to all default topics
    for (final d in _defaultDevices) {
      _mqtt.subscribe(d.topic);
    }
  }

  final MqttService _mqtt;
  StreamSubscription<IncomingMessage>? _sub;

  static final _defaultDevices = <DeviceModel>[
    DeviceModel(
      id: 'light_1',
      name: 'Main Light',
      topic: 'home/light',
      type: DeviceType.light,
      room: 'Living Room',
    ),
    DeviceModel(
      id: 'fan_1',
      name: 'Cooling Fan',
      topic: 'home/fan',
      type: DeviceType.fan,
      room: 'Living Room',
    ),
    DeviceModel(
      id: 'ac_1',
      name: 'Air Conditioner',
      topic: 'home/ac',
      type: DeviceType.ac,
      room: 'Bedroom',
    ),
  ];

  void toggle(String id, bool value) {
    state = [
      for (final d in state)
        if (d.id == id) d.copyWith(isOn: value) else d,
    ];
    final device = state.firstWhere((d) => d.id == id);
    _mqtt.publish(device.topic, value ? 'ON' : 'OFF');
  }

  void addDevice(DeviceModel device) {
    state = [...state, device];
    _mqtt.subscribe(device.topic);
  }

  void removeDevice(String id) {
    state = state.where((d) => d.id != id).toList();
  }

  void _onMessage(IncomingMessage msg) {
    state = [
      for (final d in state)
        if (d.topic == msg.topic)
          d.copyWith(isOn: msg.payload.toUpperCase() == 'ON')
        else
          d,
    ];
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final devicesProvider =
    StateNotifierProvider<DevicesNotifier, List<DeviceModel>>((ref) {
  return DevicesNotifier(ref.watch(mqttServiceProvider));
});
