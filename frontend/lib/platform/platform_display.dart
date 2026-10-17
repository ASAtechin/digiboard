// Holds the display controller when the app runs against the Shiksha Tantra
// platform. When it is null the app uses the original DigiBoard backend.
import 'display_controller.dart';

class PlatformDisplay {
  static DisplayController? controller;
  static bool get enabled => controller != null;
}

/// The platform's alert state in the shape the timetable screen already
/// understands. Throws when the status cannot be confirmed, so the screen
/// shows "alert status unavailable" and keeps the last confirmed alert.
Map<String, dynamic> platformAlertStatus(DisplayController controller) {
  if (controller.alertStatusUnknown) {
    throw Exception('Alert status unavailable');
  }
  final alerts = controller.alerts
      .map(
        (a) => <String, dynamic>{
          'active': true,
          'id': a.id,
          'type': a.severity,
          'message': a.displayMessage,
        },
      )
      .toList();
  return alerts.isEmpty
      ? {'active': false, 'alerts': alerts}
      : {...alerts.first, 'alerts': alerts};
}
