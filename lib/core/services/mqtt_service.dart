import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// Our own connection-state enum (avoids conflict with mqtt_client internals)
enum MqttAppState { idle, connecting, connected, failed, disconnected }

class IncomingMessage {
  final String topic;
  final String payload;
  const IncomingMessage({required this.topic, required this.payload});
}

class MqttService {
  MqttServerClient? _client;

  final _statusCtrl  = StreamController<MqttAppState>.broadcast();
  final _messageCtrl = StreamController<IncomingMessage>.broadcast();

  Stream<MqttAppState>     get statusStream  => _statusCtrl.stream;
  Stream<IncomingMessage>  get messageStream => _messageCtrl.stream;

  MqttAppState _state = MqttAppState.idle;
  MqttAppState get state => _state;

  void _emit(MqttAppState s) {
    _state = s;
    if (!_statusCtrl.isClosed) _statusCtrl.add(s);
  }

  // ── Connect ───────────────────────────────────────────────────────────────
  Future<bool> connect({
    required String brokerUrl,
    required int port,
    required String clientId,
  }) async {
    _emit(MqttAppState.connecting);

    _client = MqttServerClient.withPort(brokerUrl, clientId, port)
      ..logging(on: false)
      ..keepAlivePeriod = 30
      ..autoReconnect = true
      ..onDisconnected   = _onDisconnected
      ..onConnected      = _onConnected
      ..onAutoReconnected = _onAutoReconnected
      ..connectionMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean()
          .withWillQos(MqttQos.atMostOnce);

    try {
      await _client!.connect();
    } catch (e) {
      _emit(MqttAppState.failed);
      _client?.disconnect();
      return false;
    }

    final status = _client!.connectionStatus;
    if (status?.state == MqttConnectionState.connected) {
      _listenToMessages();
      return true;
    }

    _emit(MqttAppState.failed);
    return false;
  }

  // ── Incoming messages ─────────────────────────────────────────────────────
  void _listenToMessages() {
    _client?.updates?.listen(
      (List<MqttReceivedMessage<MqttMessage>> events) {
        for (final event in events) {
          final pub = event.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            pub.payload.message,
          );
          if (!_messageCtrl.isClosed) {
            _messageCtrl.add(
              IncomingMessage(topic: event.topic, payload: payload),
            );
          }
        }
      },
    );
  }

  // ── Subscribe ─────────────────────────────────────────────────────────────
  void subscribe(String topic) {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  // ── Publish ───────────────────────────────────────────────────────────────
  void publish(String topic, String payload) {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }
    final builder = MqttClientPayloadBuilder()..addString(payload);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  // ── Disconnect ────────────────────────────────────────────────────────────
  void disconnect() => _client?.disconnect();

  void _onConnected()       => _emit(MqttAppState.connected);
  void _onDisconnected()    => _emit(MqttAppState.disconnected);
  void _onAutoReconnected() => _emit(MqttAppState.connected);

  // ── Cleanup ───────────────────────────────────────────────────────────────
  void dispose() {
    _client?.disconnect();
    _statusCtrl.close();
    _messageCtrl.close();
  }
}
