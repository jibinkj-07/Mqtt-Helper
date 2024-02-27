import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_helper/features/mqtt/presentation/provider/mqtt_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/util/mqtt/mqtt_helper.dart';
import '../../../../core/util/widgets/custom_text_field.dart';

/// @author : Jibin K John
/// @date   : 22/02/2024
/// @time   : 11:05:28

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _payloadController = TextEditingController();

  @override
  void dispose() {
    _topicController.dispose();
    _payloadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomTextField(
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
                const SizedBox(height: 15.0),
                CustomTextField(
                  controller: _payloadController,
                  validator: (value) {
                    if (value.toString().trim().isEmpty) {
                      return "Payload is empty";
                    }
                    return null;
                  },
                  labelText: 'Payload',
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.none,
                  maxLines: 5,
                ),
                const SizedBox(height: 15.0),
                FilledButton(
                    onPressed: _onPublish, child: const Text("Publish"))
              ],
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Consumer<MQTTProvider>(builder: (ctx, mqttProvider, _) {
                if (mqttProvider.allMessage.isEmpty) {
                  return const Center(
                    child: Text(
                      "No messages",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                  itemCount: mqttProvider.allMessage.length,
                  itemBuilder: (ctx, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mqttProvider.allMessage[index].payload,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15.0,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  child: Text(
                                    mqttProvider.allMessage[index].topic,
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                DateFormat("dd-MM-yyyy").add_jms().format(
                                    mqttProvider.allMessage[index].time),
                                style: const TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 0.0),
                );
              }),
              Positioned(
                top: 0,
                right: 0,
                child: TextButton(
                  onPressed: _onClear,
                  child: const Text("Clear"),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  void _onPublish() {
    // Checking for mqtt connection
    if (Provider.of<MQTTProvider>(context, listen: false).mqttConnected) {
      if (_formKey.currentState!.validate()) {
        MqttHelper mqttHelper = MqttHelper();
        mqttHelper.publishMessage(
          topic: _topicController.text,
          message: _payloadController.text,
          isRetain: false,
        );
        _payloadController.clear();
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

  void _onClear() {
    Provider.of<MQTTProvider>(context, listen: false).clearMessages();
  }
}
