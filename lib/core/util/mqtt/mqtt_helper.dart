import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:either_dart/either.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttHelper {
  MqttHelper._internal();

  static final MqttHelper _instance = MqttHelper._internal();

  factory MqttHelper() => _instance;

  // -- MQTT client manager --
  late MqttServerClient _client;

  Future<Either<String, bool>> connect({
    required String host,
    required String port,
    required String userName,
    required String password,
  }) async {
    final randomNumber = math.Random().nextInt(99999) + 10000;
    _client = MqttServerClient.withPort(
      host,
      'MQTT_HELPER_APP-$randomNumber',
      int.parse(port),
    );
    _client.logging(on: false);
    _client.keepAlivePeriod = 60;
    _client.onConnected = onConnected;
    _client.onDisconnected = onDisconnected;
    _client.onSubscribed = onSubscribed;
    _client.pongCallback = pong;
    final connMessage = MqttConnectMessage()
        .startClean()
        .withWillQos(MqttQos.atLeastOnce)
        .withWillRetain();
    _client.connectionMessage = connMessage;
    log("called mqtt connection");
    try {
      if (_client.connectionStatus!.state == MqttConnectionState.disconnected) {
        await _client.connect(userName, password);
      }
      if (isConnected) {
        return const Right(true);
      } else {
        return const Left("Unable to connect to mqtt. Try again");
      }
    } on NoConnectionException catch (e) {
      log('MQTTClient::Client exception - $e');
      _client.disconnect();
      return const Left("Unable to connect to mqtt. Try again");
    } on SocketException catch (e) {
      log('MQTTClient::Socket exception - $e');
      _client.disconnect();
      return const Left("Unable to connect to mqtt. Try again");
    } catch (e) {
      log('Something went wrong $e');
      return const Left("Unable to connect to mqtt. Try again");
    }
  }

  bool get isConnected {
    bool connected = false;
    try {
      connected =
          _client.connectionStatus!.state == MqttConnectionState.connected;
    } catch (e) {
      log('Error from MQTT status check $e');
    }
    return connected;
  }

  void pong() {
    log('MQTTClient::Ping response received');
  }

  void disconnect() => _client.disconnect();

  // Track subscribed topics
  Set<String> subscribedTopics = <String>{};

  void subscribe(String topic) {
    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      if (!subscribedTopics.contains(topic)) {
        _client.subscribe(topic, MqttQos.atLeastOnce);
      }
    }
  }

  void unSubscribe(String topic) async {
    if (subscribedTopics.contains(topic)) {
      _client.unsubscribe(topic);
      subscribedTopics.remove(topic);
    }
  }

  void onConnected() {
    log('MQTTClient::Connected');
  }

  void onDisconnected() {
    log('MQTTClient::Disconnected');
    subscribedTopics.clear();
  }

  void onSubscribed(String topic) {
    subscribedTopics.add(topic);
    log('MQTTClient::Subscribed to topic: $topic all topics are $subscribedTopics');
  }

  void onUnsubscribed(String? topic) {
    log('MQTTClient::Unsubscribed topic: $topic all topics are $subscribedTopics');
  }

  void publishMessage(
      {required String topic,
      required String message,
      required bool isRetain}) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      log('MQTT PUBLISHED MESSAGE TO $topic WITH DATA $message');
      _client.publishMessage(
        topic,
        MqttQos.atMostOnce,
        builder.payload!,
        retain: isRetain,
      );
    }
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>>? getMessagesStream() {
    return _client.updates;
  }

  MqttServerClient get getClient => _client;
}
