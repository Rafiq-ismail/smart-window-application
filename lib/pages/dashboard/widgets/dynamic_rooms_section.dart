import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/app_colors.dart';
import '../../../services/room_service.dart';
import '../../control/control_page.dart';
import 'room_status_card.dart';

class DynamicRoomsSection extends StatelessWidget {
  const DynamicRoomsSection({
    super.key,
    required this.onAddRoom,
  });

  final VoidCallback onAddRoom;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Rooms',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: onAddRoom,
              icon: const Icon(
                Icons.add_rounded,
                size: 20,
              ),
              label: const Text('Add Room'),
            ),
          ],
        ),

        const SizedBox(height: 15),

        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: RoomService.instance.getUserRooms(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.divider,
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 36,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Unable to load rooms.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.connectionState ==
                ConnectionState.waiting &&
                !snapshot.hasData) {
              return const SizedBox(
                height: 80,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final rooms =
            List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
              snapshot.data?.docs ??
                  <QueryDocumentSnapshot<Map<String, dynamic>>>[],
            );

            if (rooms.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.divider,
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.meeting_room_outlined,
                      size: 40,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No rooms added yet.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Tap Add Room to create your first room.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            rooms.sort((a, b) {
              final aTime =
              a.data()['createdAt'] as Timestamp?;

              final bTime =
              b.data()['createdAt'] as Timestamp?;

              if (aTime == null && bTime == null) {
                return 0;
              }

              if (aTime == null) {
                return 1;
              }

              if (bTime == null) {
                return -1;
              }

              return bTime.compareTo(aTime);
            });

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int index = 0;
                index < rooms.length;
                index++) ...[
                  _buildRoomCard(
                    context,
                    rooms[index],
                  ),
                  if (index != rooms.length - 1)
                    const SizedBox(height: 15),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRoomCard(
      BuildContext context,
      QueryDocumentSnapshot<Map<String, dynamic>>
      document,
      ) {
    final data = document.data();

    final roomName =
    data['name']?.toString().trim();

    final displayName =
    roomName == null || roomName.isEmpty
        ? 'Room'
        : roomName;

    return RoomStatusCard(
      roomName: displayName,
      icon: Icons.meeting_room_rounded,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ControlPage(
              roomName: displayName,
            ),
          ),
        );
      },
    );
  }
}