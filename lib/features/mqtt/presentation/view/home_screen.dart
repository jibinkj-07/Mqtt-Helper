import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_helper/features/mqtt/domain/entity/message_entity.dart';
import 'package:provider/provider.dart';

import '../../../../core/util/mqtt/mqtt_helper.dart';
import '../provider/mqtt_provider.dart';
import '../widgets/dashboard.dart';
import '../widgets/subscribe.dart';
import 'connection_screen.dart';

/// @author : Jibin K John
/// @date   : 22/02/2024
/// @time   : 11:03:07

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screen = [];
  final ValueNotifier<int> _index = ValueNotifier(0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _listenMqtt();
    _screen.addAll([
      const Dashboard(),
      const Subscribe(),
    ]);
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _index.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _index,
      builder: (ctx, index, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            automaticallyImplyLeading: false,
            title: Consumer<MQTTProvider>(builder: (ctx, mqttProvider, _) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mqttProvider.mqttBroker),
                    Text(
                      mqttProvider.mqttConnected ? "Connected" : "Disconnected",
                      style: const TextStyle(fontSize: 15.0),
                    ),
                  ],
                );
              }

              return const Text("Subscribe");
            }),
            actions: [
              if (index == 0)
                Consumer<MQTTProvider>(builder: (ctx, mqttProvider, _) {
                  if (mqttProvider.mqttConnected) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () {
                      final mqttProvider =
                          Provider.of<MQTTProvider>(context, listen: false);
                      MqttHelper mqttHelper = MqttHelper();

                      mqttHelper
                          .connect(
                              host: mqttProvider.mqttBroker.split(":").first,
                              port: mqttProvider.mqttBroker.split(":").last,
                              userName:
                                  mqttProvider.credential.split(":").first,
                              password: mqttProvider.credential.split(":").last)
                          .then((value) {
                        if (value.isLeft) {
                          mqttProvider.mqttConnected = false;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(value.left),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          mqttProvider.mqttConnected = true;
                        }
                      });
                    },
                  );
                }),
              IconButton(
                icon: const Icon(Icons.power_settings_new_rounded),
                onPressed: () {
                  MqttHelper mqttHelper = MqttHelper();
                  final mqttProvider =
                      Provider.of<MQTTProvider>(context, listen: false);
                  mqttHelper.disconnect();
                  mqttProvider.onClear();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (_) => const ConnectionScreen()));
                },
              ),
            ],
          ),
          body: _screen[index],
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) => _index.value = i,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                label: 'Dashboard',
                selectedIcon: Icon(Icons.space_dashboard_sharp),
              ),
              NavigationDestination(
                icon: Icon(Icons.loyalty_outlined),
                label: 'Subscribe',
                selectedIcon: Icon(Icons.loyalty_rounded),
              ),
            ],
          ),
        );
      },
    );
  }

  void _listenMqtt() {
    final mqttHelper = MqttHelper();
    final context = this.context;
    final mqttProvider = Provider.of<MQTTProvider>(context, listen: false);
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      mqttProvider.mqttConnected = mqttHelper.isConnected;
    });
    try {
      mqttHelper
          .getMessagesStream()!
          .where((messages) => messages.isNotEmpty)
          .listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        final recMess = messages[0].payload as MqttPublishMessage;
        final result =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        final topic = recMess.variableHeader!.topicName;

        log("MQTT MESSAGE:[MESSAGE:$result] TOPIC:$topic");
        mqttProvider.addMessage(
          MessageEntity(
            topic: topic,
            payload: result,
            time: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      log("error from _mqttListener $e");
    }
  }
}
