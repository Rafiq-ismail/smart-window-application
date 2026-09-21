import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../services/device_service.dart';

class AdminDevicesPage extends StatelessWidget {
  const AdminDevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Management'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: DeviceService.instance.getAllDevices(),
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

          final devices = List<
              QueryDocumentSnapshot<Map<String, dynamic>>>.from(
            snapshot.data?.docs ??
                <QueryDocumentSnapshot<Map<String, dynamic>>>[],
          );

          devices.sort((a, b) {
            final aTime = a.data()['createdAt'] as Timestamp?;
            final bTime = b.data()['createdAt'] as Timestamp?;

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

          final onlineCount = devices.where((device) {
            final status = device
                .data()['connectionStatus']
                ?.toString()
                .toLowerCase() ??
                '';

            return status == 'online';
          }).length;

          final offlineCount = devices.where((device) {
            final status = device
                .data()['connectionStatus']
                ?.toString()
                .toLowerCase() ??
                'offline';

            return status != 'online';
          }).length;

          return RefreshIndicator(
            onRefresh: () async {
              await Future<void>.delayed(
                const Duration(milliseconds: 500),
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Device Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Monitor registered Smart Window devices and their connection status.',
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
                        value: devices.length.toString(),
                        icon: Icons.devices_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Online',
                        value: onlineCount.toString(),
                        icon: Icons.wifi_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Offline',
                        value: offlineCount.toString(),
                        icon: Icons.wifi_off_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  'Registered Devices',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                if (devices.isEmpty)
                  const _EmptyDeviceState()
                else
                  ...devices.map(
                        (device) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 15,
                      ),
                      child: _DeviceCard(
                        deviceId: device.id,
                        data: device.data(),
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
              'Unable to load devices',
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

class _EmptyDeviceState extends StatelessWidget {
  const _EmptyDeviceState();

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
            Icons.developer_board_outlined,
            size: 55,
          ),
          SizedBox(height: 15),
          Text(
            'No Devices Registered',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Registered ESP32 devices will appear here.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// =============================================================
// DEVICE CARD
// =============================================================

class _DeviceCard extends StatelessWidget {
  final String deviceId;
  final Map<String, dynamic> data;

  const _DeviceCard({
    required this.deviceId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final deviceName =
        data['deviceName']?.toString() ?? 'Unnamed Device';

    final deviceType =
        data['deviceType']?.toString() ?? 'Unknown';

    final userId =
        data['userId']?.toString() ?? '-';

    final roomId =
        data['roomId']?.toString() ?? '-';

    final ipAddress =
        data['ipAddress']?.toString() ?? '-';

    final firmware =
        data['firmwareVersion']?.toString() ?? '-';

    final signalStrength =
        data['signalStrength']?.toString() ?? '-';

    final uptime =
        data['uptime']?.toString() ?? '0';

    final connectionStatus =
        data['connectionStatus']
            ?.toString()
            .toLowerCase() ??
            'offline';

    final isOnline =
        connectionStatus == 'online';

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
                  Icons.developer_board_rounded,
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
                      deviceName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      deviceType,
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
                  color: isOnline
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnline
                          ? Icons.circle
                          : Icons.circle_outlined,
                      size: 10,
                      color: isOnline
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isOnline
                          ? 'ONLINE'
                          : 'OFFLINE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isOnline
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 8),

          _InfoRow(
            label: 'Device ID',
            value: deviceId,
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
            label: 'IP Address',
            value: ipAddress,
          ),
          _InfoRow(
            label: 'Firmware',
            value: firmware,
          ),
          _InfoRow(
            label: 'Signal',
            value: signalStrength == '-'
                ? '-'
                : '$signalStrength dBm',
          ),
          _InfoRow(
            label: 'Uptime',
            value: '$uptime sec',
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