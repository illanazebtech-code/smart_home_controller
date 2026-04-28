import 'package:flutter/material.dart';

enum DeviceType { light, fan, ac, socket, lock }

class DeviceModel {
  final String id;
  final String name;
  final String topic;
  final DeviceType type;
  final bool isOn;
  final String room;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.topic,
    required this.type,
    this.isOn = false,
    this.room = 'Living Room',
  });

  DeviceModel copyWith({bool? isOn, String? name, String? room}) {
    return DeviceModel(
      id: id,
      name: name ?? this.name,
      topic: topic,
      type: type,
      isOn: isOn ?? this.isOn,
      room: room ?? this.room,
    );
  }

  IconData get icon {
    switch (type) {
      case DeviceType.light:  return Icons.lightbulb_rounded;
      case DeviceType.fan:    return Icons.air_rounded;
      case DeviceType.ac:     return Icons.ac_unit_rounded;
      case DeviceType.socket: return Icons.power_rounded;
      case DeviceType.lock:   return Icons.lock_rounded;
    }
  }

  String get typeLabel {
    switch (type) {
      case DeviceType.light:  return 'Light';
      case DeviceType.fan:    return 'Fan';
      case DeviceType.ac:     return 'AC';
      case DeviceType.socket: return 'Socket';
      case DeviceType.lock:   return 'Lock';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'topic': topic,
    'type': type.name,
    'room': room,
  };

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      topic: json['topic'] as String,
      type: DeviceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DeviceType.light,
      ),
      room: json['room'] as String? ?? 'Living Room',
    );
  }
}
