<<<<<<< HEAD
# 🏠 Smart Home Controller

A professional Flutter + MQTT smart home controller app with a luxury dark UI.

## Features
- **Connect** to any MQTT broker (HiveMQ, EMQX, Mosquitto)
- **Control devices** — Light, Fan, AC, Socket, Lock
- **Real-time sync** via MQTT subscriptions
- **Add / Remove devices** dynamically with custom topics & rooms
- **Saved settings** — broker config persisted via SharedPreferences
- **Room grouping** on the dashboard
- Animated, professional dark UI with `flutter_animate`

## Project Structure
```
lib/
├── main.dart
├── core/
│   ├── services/
│   │   ├── mqtt_service.dart      # MQTT connection + pub/sub
│   │   └── prefs_service.dart     # SharedPreferences wrapper
│   └── theme/
│       └── app_theme.dart         # Colors, typography, ThemeData
├── models/
│   ├── device_model.dart          # Device entity + DeviceType enum
│   └── connection_config.dart     # Broker config model
├── providers/
│   └── providers.dart             # All Riverpod providers
├── screens/
│   ├── connection_screen.dart     # Broker connect UI
│   └── dashboard_screen.dart      # Device control dashboard
└── widgets/
    ├── device_card.dart           # Animated device grid card
    ├── stat_chip.dart             # Statistics chip
    └── add_device_sheet.dart      # Bottom sheet to add device
```

## Setup

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Run
```bash
flutter run
```

## MQTT Topics (Defaults)
| Device        | Topic       | Payload  |
|---------------|-------------|----------|
| Main Light    | home/light  | ON / OFF |
| Cooling Fan   | home/fan    | ON / OFF |
| Air Conditioner| home/ac    | ON / OFF |

Custom topics supported — add any device with any topic via the **Add Device** FAB.

## Testing with MQTTX
1. Open [MQTTX](https://mqttx.app/)
2. Connect to `broker.hivemq.com:1883`
3. Subscribe to `home/light`
4. Toggle the light in the app → MQTTX shows `ON` or `OFF`
5. Publish `ON` or `OFF` from MQTTX → app UI updates in real time

## Dependencies
```yaml
flutter_riverpod: ^2.5.1
mqtt_client: ^10.0.0
shared_preferences: ^2.2.3
google_fonts: ^6.2.1
flutter_animate: ^4.5.0
gap: ^3.0.1
```
=======
# smart_home_controller
Flutter + MQTT Smart Home Controller App
>>>>>>> 9695cb8350ecaedf285e5ce656273d9d9a17a70c
