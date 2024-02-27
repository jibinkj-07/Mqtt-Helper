import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/util/mqtt/mqtt_helper.dart';
import '../../../../core/util/widgets/custom_text_field.dart';
import '../provider/mqtt_provider.dart';

/// @author : Jibin K John
/// @date   : 22/02/2024
/// @time   : 11:05:50

class Subscribe extends StatefulWidget {
  const Subscribe({super.key});

  @override
  State<Subscribe> createState() => _SubscribeState();
}

class _SubscribeState extends State<Subscribe> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _topicController = TextEditingController();

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Form(
                key: _formKey,
                child: CustomTextField(
                  controller: _topicController,
                  validator: (value) {
                    if (value.toString().trim().isEmpty) {
                      return "Topic is empty";
                    }
                    return null;
                  },
                  labelText: 'Topic',
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 15.0),
              FilledButton(
                  onPressed: _onSubscribe, child: const Text("Subscribe"))
            ],
          ),
        ),
        Expanded(
          child: Consumer<MQTTProvider>(builder: (ctx, mqttProvider, _) {
            if (mqttProvider.subscribedTopics.isEmpty) {
              return const Center(
                child: Text(
                  "No topics subscribed",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              );
            }
            return ListView.separated(
              itemCount: mqttProvider.subscribedTopics.length,
              itemBuilder: (ctx, index) {
                return ListTile(
                  title: Text(
                    mqttProvider.subscribedTopics[index],
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () =>
                        _onUnsubscribe(mqttProvider.subscribedTopics[index]),
                  ),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 0.0),
            );
          }),
        )
      ],
    );
  }

  void _onSubscribe() {
    if (Provider.of<MQTTProvider>(context, listen: false).mqttConnected) {
      if (_formKey.currentState!.validate()) {
        FocusScope.of(context).unfocus();
        MqttHelper mqttHelper = MqttHelper();
        mqttHelper.subscribe(_topicController.text);
        Provider.of<MQTTProvider>(context, listen: false)
            .addSubscribedTopic(_topicController.text);

        _topicController.clear();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("MQTT broker is disconnected"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onUnsubscribe(String topic) {
    MqttHelper mqttHelper = MqttHelper();
    if (Provider.of<MQTTProvider>(context, listen: false).mqttConnected) {
      mqttHelper.unSubscribe(topic);
      Provider.of<MQTTProvider>(context, listen: false)
          .removeSubscribedTopic(topic);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("MQTT broker is disconnected"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
