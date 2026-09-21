import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class AdminEmergencyPage extends StatelessWidget {
  const AdminEmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Emergency Monitoring"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('emergencies')
            .orderBy(
          'triggeredAt',
          descending: true,
        )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: AppColors.danger,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Unable to load emergency records",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final documents =
              snapshot.data?.docs ?? [];

          final activeCount =
              documents.where((doc) {
                final status = doc
                    .data()['status']
                    ?.toString()
                    .toLowerCase();

                return status == 'active';
              }).length;

          final resolvedCount =
              documents.where((doc) {
                final status = doc
                    .data()['status']
                    ?.toString()
                    .toLowerCase();

                return status == 'resolved';
              }).length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _EmergencySummaryCard(
                total: documents.length,
                active: activeCount,
                resolved: resolvedCount,
              ),

              const SizedBox(height: 24),

              const Text(
                "Emergency Records",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              if (documents.isEmpty)
                const _EmptyEmergencyCard()
              else
                ...documents.map(
                      (document) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: _EmergencyCard(
                      documentId: document.id,
                      data: document.data(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// EMERGENCY SUMMARY
// ============================================================

class _EmergencySummaryCard extends StatelessWidget {
  final int total;
  final int active;
  final int resolved;

  const _EmergencySummaryCard({
    required this.total,
    required this.active,
    required this.resolved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.danger,
              ),
              SizedBox(width: 10),
              Text(
                "Emergency Overview",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  title: "Total",
                  value: total.toString(),
                  icon: Icons.list_alt_outlined,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _SummaryItem(
                  title: "Active",
                  value: active.toString(),
                  icon:
                  Icons.warning_amber_rounded,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _SummaryItem(
                  title: "Resolved",
                  value: resolved.toString(),
                  icon:
                  Icons.check_circle_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primaryDark,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMERGENCY CARD
// ============================================================

class _EmergencyCard extends StatelessWidget {
  final String documentId;
  final Map<String, dynamic> data;

  const _EmergencyCard({
    required this.documentId,
    required this.data,
  });

  String _formatTimestamp(dynamic value) {
    if (value is! Timestamp) {
      return 'Not available';
    }

    final date = value.toDate();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final alertType =
        data['alertType']?.toString() ??
            'Unknown Alert';

    final description =
        data['description']?.toString() ??
            'No description';

    final status =
        data['status']
            ?.toString()
            .toLowerCase() ??
            'active';

    final isActive = status == 'active';

    final acknowledged =
        data['acknowledged'] == true;

    final userId =
        data['userId']?.toString() ??
            'Unknown user';

    final roomId =
        data['roomId']?.toString() ??
            'Not assigned';

    final triggeredDate =
    _formatTimestamp(
      data['triggeredAt'],
    );

    final acknowledgedDate =
    _formatTimestamp(
      data['acknowledgedAt'],
    );

    final resolvedDate =
    _formatTimestamp(
      data['resolvedAt'],
    );

    // ========================================================
    // STATUS DESIGN
    // ========================================================

    String statusText;
    IconData statusIcon;
    Color statusColor;

    if (!isActive) {
      statusText = 'RESOLVED';
      statusIcon =
          Icons.check_circle_outline;
      statusColor = Colors.green;
    } else if (acknowledged) {
      statusText =
      'ACTIVE • ACKNOWLEDGED';
      statusIcon =
          Icons.visibility_outlined;
      statusColor = Colors.orange;
    } else {
      statusText = 'ACTIVE';
      statusIcon =
          Icons.warning_amber_rounded;
      statusColor = AppColors.danger;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // ==================================================
          // HEADER
          // ==================================================

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor:
                statusColor.withValues(
                  alpha: 0.12,
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  alertType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                  statusColor.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 14,
                      color: statusColor,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                        FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ==================================================
          // DESCRIPTION
          // ==================================================

          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 14),

          // ==================================================
          // TIME INFORMATION
          // ==================================================

          _EmergencyInfoRow(
            icon: Icons.access_time,
            text:
            "Triggered: $triggeredDate",
          ),

          if (acknowledged) ...[
            const SizedBox(height: 6),
            _EmergencyInfoRow(
              icon:
              Icons.visibility_outlined,
              text:
              "Acknowledged: $acknowledgedDate",
            ),
          ],

          if (!isActive) ...[
            const SizedBox(height: 6),
            _EmergencyInfoRow(
              icon:
              Icons.check_circle_outline,
              text:
              "Resolved: $resolvedDate",
            ),
          ],

          const SizedBox(height: 14),

          const Divider(),

          const SizedBox(height: 8),

          // ==================================================
          // FIRESTORE INFORMATION
          // ==================================================

          Text(
            "User ID: $userId",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color:
              AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "Room ID: $roomId",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color:
              AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "Emergency ID: $documentId",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textLight,
            ),
          ),

          // ==================================================
          // ACKNOWLEDGE BUTTON
          // ==================================================

          if (isActive &&
              !acknowledged) ...[
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirmed =
                  await showDialog<bool>(
                    context: context,
                    builder:
                        (dialogContext) {
                      return AlertDialog(
                        title: const Text(
                          "Acknowledge Emergency",
                        ),
                        content: const Text(
                          "Confirm that you have seen and reviewed this emergency alert.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                dialogContext,
                                false,
                              );
                            },
                            child: const Text(
                              "Cancel",
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(
                                dialogContext,
                                true,
                              );
                            },
                            child: const Text(
                              "Acknowledge",
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmed != true) {
                    return;
                  }

                  try {
                    final admin =
                        FirebaseAuth
                            .instance
                            .currentUser;

                    final emergencyRef =
                    FirebaseFirestore
                        .instance
                        .collection(
                      'emergencies',
                    )
                        .doc(
                      documentId,
                    );

                    await emergencyRef
                        .update({
                      'acknowledged': true,
                      'acknowledgedAt':
                      FieldValue
                          .serverTimestamp(),
                      'responseLogs':
                      FieldValue
                          .arrayUnion([
                        {
                          'time':
                          Timestamp.now(),
                          'action':
                          'Emergency acknowledged by admin',
                          'performedBy':
                          admin?.uid ??
                              'admin',
                        },
                      ]),
                    });

                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Emergency acknowledged successfully.",
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Failed to acknowledge emergency: $e",
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.visibility_outlined,
                ),
                label: const Text(
                  "Acknowledge Alert",
                ),
              ),
            ),
          ],

          // ==================================================
          // ACKNOWLEDGED INFORMATION
          // ==================================================

          if (isActive &&
              acknowledged) ...[
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.orange
                    .withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange
                      .withValues(
                    alpha: 0.30,
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons
                        .visibility_outlined,
                    size: 18,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "ADMIN ACKNOWLEDGED",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ==================================================
          // RESOLVED INFORMATION
          // ==================================================

          if (!isActive) ...[
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.green
                    .withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green
                      .withValues(
                    alpha: 0.25,
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons
                        .check_circle_outline,
                    size: 18,
                    color: Colors.green,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "RESOLVED BY SYSTEM",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// EMERGENCY INFO ROW
// ============================================================

class _EmergencyInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmergencyInfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 15,
          color: AppColors.textSecondary,
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color:
              AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyEmergencyCard
    extends StatelessWidget {
  const _EmptyEmergencyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 20,
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
            Icons
                .health_and_safety_outlined,
            size: 60,
            color:
            AppColors.textSecondary,
          ),

          SizedBox(height: 14),

          Text(
            "No emergency records",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 6),

          Text(
            "Emergency alerts will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
              AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}