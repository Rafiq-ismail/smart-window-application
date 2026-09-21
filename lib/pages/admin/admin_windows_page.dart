import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../services/window_service.dart';

class AdminWindowsPage extends StatelessWidget {
  const AdminWindowsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Window Management'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: WindowService.instance.getAllWindows(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(
              snapshot.error.toString(),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final windows = List<
              QueryDocumentSnapshot<Map<String, dynamic>>>.from(
            snapshot.data?.docs ??
                <QueryDocumentSnapshot<Map<String, dynamic>>>[],
          );

          // Newest window first
          windows.sort((a, b) {
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

          final openCount = windows.where((window) {
            final status = window
                .data()['status']
                ?.toString()
                .toUpperCase() ??
                'CLOSED';

            return status == 'OPEN';
          }).length;

          final closedCount = windows.where((window) {
            final status = window
                .data()['status']
                ?.toString()
                .toUpperCase() ??
                'CLOSED';

            return status != 'OPEN';
          }).length;

          return RefreshIndicator(
            onRefresh: () async {
              await Future<void>.delayed(
                const Duration(milliseconds: 500),
              );
            },
            child: ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Window Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Monitor windows registered by SmartWindow users.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total',
                        value: windows.length.toString(),
                        icon: Icons.window_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Open',
                        value: openCount.toString(),
                        icon: Icons.sensor_window_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Closed',
                        value: closedCount.toString(),
                        icon: Icons.window_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  'Registered Windows',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                if (windows.isEmpty)
                  const _EmptyWindowState()
                else
                  ...windows.map(
                        (window) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 15,
                      ),
                      child: _WindowCard(
                        windowId: window.id,
                        data: window.data(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 55,
              color: Colors.red,
            ),
            const SizedBox(height: 15),
            const Text(
              'Unable to load windows',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// SUMMARY CARD
// =============================================================

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 25,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// EMPTY STATE
// =============================================================

class _EmptyWindowState extends StatelessWidget {
  const _EmptyWindowState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.window_outlined,
            size: 55,
          ),
          SizedBox(height: 15),
          Text(
            'No Windows Registered',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Windows registered by users will appear here.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// =============================================================
// WINDOW CARD
// =============================================================

class _WindowCard extends StatelessWidget {
  final String windowId;
  final Map<String, dynamic> data;

  const _WindowCard({
    required this.windowId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        data['name']?.toString() ?? 'Unnamed Window';

    final userId =
        data['userId']?.toString() ?? '-';

    final roomId =
        data['roomId']?.toString() ?? '-';

    final assignedDeviceId =
        data['assignedDeviceId']?.toString() ?? '-';

    final status =
        data['status']?.toString().toUpperCase() ??
            'CLOSED';

    final openingPercentage =
    data['openingPercentage'] is num
        ? (data['openingPercentage'] as num).toInt()
        : 0;

    final isOpen = status == 'OPEN';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.window_rounded,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$openingPercentage% open',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isOpen
                      ? Colors.green.withValues(
                    alpha: 0.12,
                  )
                      : Colors.grey.withValues(
                    alpha: 0.15,
                  ),
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Text(
                  isOpen ? 'OPEN' : 'CLOSED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isOpen
                        ? Colors.green
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 8),

          _InfoRow(
            label: 'Window ID',
            value: windowId,
          ),
          _InfoRow(
            label: 'User ID',
            value: userId,
          ),
          _InfoRow(
            label: 'Room ID',
            value: roomId,
          ),
          _InfoRow(
            label: 'Device ID',
            value: assignedDeviceId,
          ),
          _InfoRow(
            label: 'Opening',
            value: '$openingPercentage%',
          ),
        ],
      ),
    );
  }
}

// =============================================================
// INFORMATION ROW
// =============================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}