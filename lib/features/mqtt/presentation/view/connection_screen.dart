import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/util/mqtt/mqtt_helper.dart';
import '../../../../core/util/widgets/custom_text_field.dart';
import '../provider/mqtt_provider.dart';
import 'home_screen.dart';

/// @author : Jibin K John
/// @date   : 22/02/2024
/// @time   : 10:36:31

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _isObscure = ValueNotifier(true);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  String _host = "";
  String _port = "";
  String _name = "";
  String _password = "";

  @override
  void dispose() {
    _isObscure.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        title: const Text("MQTT Connection"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                onSaved: (value) => _host = value.toString().trim(),
                validator: (value) {
                  if (value.toString().trim().isEmpty) {
                    return "Host is empty";
                  }
                  return null;
                },
                labelText: 'Host',
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.next,
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, right: size.width * .4),
                child: CustomTextField(
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _port = value.toString().trim(),
                  validator: (value) {
                    if (value.toString().trim().isEmpty) {
                      return "Port is empty";
                    }
                    return null;
                  },
                  labelText: 'Port',
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  "Credential",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              CustomTextField(
                onSaved: (value) => _name = value.toString().trim(),
                validator: (value) {
                  if (value.toString().trim().isEmpty) {
                    return "Name is empty";
                  }
                  return null;
                },
                labelText: 'Name',
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 15.0),
              ValueListenableBuilder(
                valueListenable: _isObscure,
                builder: (ctx, obscure, _) {
                  return CustomTextField(
                    maxLines: 1,
                    obscureText: obscure,
                    onSaved: (value) => _password = value.toString().trim(),
                    validator: (value) {
                      if (value.toString().trim().isEmpty) {
                        return "Password is empty";
                      }
                      return null;
                    },
                    labelText: 'Password',
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.done,
                    suffix: IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                      onPressed: () => _isObscure.value = !_isObscure.value,
                    ),
                  );
                },
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Container(
                  width: size.width * .5,
                  padding: const EdgeInsets.only(top: 30.0),
                  child: ValueListenableBuilder(
                      valueListenable: _isLoading,
                      builder: (ctx, loading, _) {
                        return FilledButton(
                          onPressed: loading ? null : _onConnect,
                          child: Text(loading ? "Connecting" : "Connect"),
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onConnect() {
    final mqttProvider = Provider.of<MQTTProvider>(context, listen: false);
    MqttHelper mqttHelper = MqttHelper();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      FocusScope.of(context).unfocus();
      _isLoading.value = true;
      mqttHelper
          .connect(
              host: _host, port: _port, userName: _name, password: _password)
          .then((value) {
        _isLoading.value = false;
        if (value.isLeft) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(value.left),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          mqttProvider.mqttConnected = true;
          mqttProvider.mqttBroker = "$_host:$_port";
          mqttProvider.credential = "$_name:$_password";
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      });
    }
  }
}
