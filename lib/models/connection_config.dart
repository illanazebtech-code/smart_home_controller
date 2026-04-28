class ConnectionConfig {
  final String brokerUrl;
  final int port;
  final String clientId;

  const ConnectionConfig({
    required this.brokerUrl,
    required this.port,
    required this.clientId,
  });

  static const ConnectionConfig defaults = ConnectionConfig(
    brokerUrl: 'broker.hivemq.com',
    port: 1883,
    clientId: 'smart_home_app',
  );

  ConnectionConfig copyWith({String? brokerUrl, int? port, String? clientId}) {
    return ConnectionConfig(
      brokerUrl: brokerUrl ?? this.brokerUrl,
      port: port ?? this.port,
      clientId: clientId ?? this.clientId,
    );
  }

  Map<String, dynamic> toJson() => {
    'brokerUrl': brokerUrl,
    'port': port,
    'clientId': clientId,
  };

  factory ConnectionConfig.fromJson(Map<String, dynamic> json) {
    return ConnectionConfig(
      brokerUrl: json['brokerUrl'] as String,
      port: json['port'] as int,
      clientId: json['clientId'] as String,
    );
  }
}
