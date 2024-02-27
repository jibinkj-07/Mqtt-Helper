import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'features/mqtt/presentation/provider/mqtt_provider.dart';
import 'features/mqtt/presentation/view/connection_screen.dart';
import 'features/mqtt/presentation/view/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then(
    (value) => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MQTTProvider>(create: (_) => MQTTProvider())
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Helper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: Consumer<MQTTProvider>(builder: (ctx, mqttProvider, _) {
        return mqttProvider.mqttConnected
            ? const HomeScreen()
            : const ConnectionScreen();
      }),
    );
  }
}
