import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  Widget buildNotification({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text("Notifications"),

        centerTitle: true,

        actions: [

          IconButton(

            icon: const Icon(Icons.delete),

            onPressed: () {

              NotificationService.instance.clearNotifications();

            },

          ),

        ],

      ),
      body: AnimatedBuilder(

        animation: NotificationService.instance,

        builder: (context, child) {

          return ListView.builder(

            padding: const EdgeInsets.all(20),

            itemCount:
            NotificationService.instance.notifications.length,

            itemBuilder: (context, index) {

              final item =
              NotificationService.instance.notifications[index];

              return buildNotification(

                icon: Icons.notifications,

                color: Colors.blue,

                title: item.title,

                subtitle: item.message,

                time:
                "${item.time.hour}:${item.time.minute.toString().padLeft(2, '0')}",

              );

            },

          );

        },

      ),
    );
  }
}