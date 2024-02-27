class MessageEntity {
  final String topic;
  final String payload;
  final DateTime time;

  MessageEntity({
    required this.topic,
    required this.payload,
    required this.time,
  });
}
