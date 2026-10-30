// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> requestWebNotificationPermission() async {
  try {
    await html.Notification.requestPermission();
  } catch (e) {
    // ignore
  }
}
