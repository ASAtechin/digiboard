// Holds the display controller when the app runs against the Shiksha Tantra
// platform. When it is null the app uses the original DigiBoard backend.
import 'display_controller.dart';

class PlatformDisplay {
  static DisplayController? controller;
  static bool get enabled => controller != null;
}
