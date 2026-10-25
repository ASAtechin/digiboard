import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/font_provider.dart';
import 'screens/timetable_carousel_screen.dart' as timetable_screen;
import 'themes/design_system.dart';
import 'services/config_service.dart';
import 'platform/display_controller.dart';
import 'platform/display_gate.dart';
import 'platform/display_store.dart';
import 'platform/platform_client.dart';
import 'platform/platform_display.dart';

// DigiBoard - Material Design 3 Educational Management System
void main() async {
  debugPrint('--- APP STARTING ---');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('--- Widgets Initialized ---');
  // Signage: full screen, no status or navigation bars.
  if (!kIsWeb) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  
  try {
    await ConfigService.loadConfig();
    debugPrint('--- Config Loaded ---');
  } catch (e) {
    debugPrint('--- Config Load Error: $e ---');
  }
  
  if (ConfigService.platformBaseUrl.isNotEmpty) {
    final controller = DisplayController(
      client: PlatformClient(ConfigService.platformBaseUrl),
      store: SharedPreferencesDisplayStore(),
    );
    PlatformDisplay.controller = controller;
    controller.start();
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => FontProvider(),
      child: const DigiBoard(),
    ),
  );
  debugPrint('--- runApp called ---');
}

class DigiBoard extends StatelessWidget {
  const DigiBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DigiBoard - Classroom Display System',
      debugShowCheckedModeBanner: false,
      theme: buildMaterialDesign3Theme(),
      home: PlatformDisplay.controller != null
          ? DisplayGate(controller: PlatformDisplay.controller!)
          : const timetable_screen.TimetableCarouselScreen(),
    );
  }
}
