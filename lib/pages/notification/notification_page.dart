import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please login to view notifications.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where(
          'userId',
          isEqualTo: user.uid,
        )
            .orderBy(
          'createdAt',
          descending: true,
        )
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Failed to load notifications: '
                      '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet.',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();

              final String title =
                  data['title'] ?? 'Notification';

              final String message =
                  data['message'] ?? '';

              final Timestamp? timestamp =
              data['createdAt'] as Timestamp?;

              final DateTime? dateTime =
              timestamp?.toDate();

              final String formattedTime =
              dateTime == null
                  ? '--:--'
                  : '${dateTime.hour.toString().padLeft(2, '0')}:'
                  '${dateTime.minute.toString().padLeft(2, '0')}';

              return buildNotification(
                icon: Icons.notifications,
                color: Colors.blue,
                title: title,
                subtitle: message,
                time: formattedTime,
              );
            },
          );
        },
      ),
    );
  }
}