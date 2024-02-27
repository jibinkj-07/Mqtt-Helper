import 'package:flutter/foundation.dart';

import '../../domain/entity/message_entity.dart';

class MQTTProvider extends ChangeNotifier {
  String _credential = "";

  bool _mqttConnected = false;
  final List<MessageEntity> _allMessage = [];
  final List<String> _subscribedTopics = [];
  String _mqttBroker = "";

  List<MessageEntity> get allMessage {
    _allMessage.sort((a, b) => b.time.compareTo(a.time));
    return _allMessage;
  }

  String get mqttBroker => _mqttBroker;

  String get credential => _credential;

  bool get mqttConnected => _mqttConnected;

  List<String> get subscribedTopics => _subscribedTopics;

  void addSubscribedTopic(String topic) {
    if (!_subscribedTopics.contains(topic)) {
      _subscribedTopics.add(topic);
      notifyListeners();
    }
  }

  void removeSubscribedTopic(String topic) {
    if (_subscribedTopics.contains(topic)) {
      _subscribedTopics.remove(topic);
      notifyListeners();
    }
  }

  set credential(String cred) {
    _credential = cred;
    notifyListeners();
  }

  void addMessage(MessageEntity message) {
    final index = _allMessage.indexWhere((element) =>
        element.topic == message.topic &&
        element.payload == message.payload &&
        (element.time.difference(message.time).inMilliseconds < 500));
    if (index < 0) {
      _allMessage.add(message);
    }
    notifyListeners();
  }

  set mqttConnected(bool connection) {
    _mqttConnected = connection;
    notifyListeners();
  }

  set mqttBroker(String broker) {
    _mqttBroker = broker;
    notifyListeners();
  }

  void clearMessages() {
    _allMessage.clear();
    notifyListeners();
  }

  void onClear() {
    _mqttBroker = "";
    _mqttConnected = false;
    _allMessage.clear();
    _subscribedTopics.clear();
    notifyListeners();
  }
}
