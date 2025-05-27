
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)?.settings.arguments as RemoteMessage?;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: message == null
          ? const Center(child: Text("No notification data available"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.notification?.title != null)
                    Text(
                      message.notification!.title!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (message.notification?.body != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(message.notification!.body!),
                    ),
                  if (message.data.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Data: ${message.data.toString()}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}