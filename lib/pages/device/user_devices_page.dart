import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../services/device_service.dart';

class UserDevicesPage extends StatelessWidget {
  const UserDevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("My Devices"),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddDeviceDialog(context);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text("Add Device"),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: DeviceService.instance.getUserDevices(),

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
                  "Unable to load devices.\n${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }

          final devices = snapshot.data?.docs ?? [];

          if (devices.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.developer_board_outlined,
                      size: 70,
                      color: AppColors.textSecondary,
                    ),

                    SizedBox(height: 16),

                    Text(
                      "No Devices Added",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "Register your ESP32 device to start connecting it with your Smart Window system.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              100,
            ),
            itemCount: devices.length,
            separatorBuilder: (_, _) =>
            const SizedBox(height: 12),

            itemBuilder: (context, index) {
              final document = devices[index];
              final data = document.data();

              final deviceName =
                  data['deviceName']?.toString() ??
                      'ESP32 Device';

              final deviceType =
                  data['deviceType']?.toString() ??
                      'ESP32';

              final connectionStatus =
                  data['connectionStatus']
                      ?.toString()
                      .toLowerCase() ??
                      'offline';

              final ipAddress =
              data['ipAddress']?.toString();

              final firmwareVersion =
              data['firmwareVersion']?.toString();

              final isOnline =
                  connectionStatus == 'online';

              return Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius:
                  BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.divider,
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,

                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius:
                        BorderRadius.circular(14),
                      ),

                      child: Icon(
                        Icons.developer_board_rounded,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            deviceName,
                            style: const TextStyle(
                              color:
                              AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            deviceType,
                            style: const TextStyle(
                              color:
                              AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 10,
                                color: isOnline
                                    ? Colors.green
                                    : Colors.grey,
                              ),

                              const SizedBox(width: 6),

                              Text(
                                isOnline
                                    ? "Online"
                                    : "Offline",
                                style: TextStyle(
                                  color: isOnline
                                      ? Colors.green
                                      : AppColors
                                      .textSecondary,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          if (ipAddress != null &&
                              ipAddress.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              "IP: $ipAddress",
                              style: const TextStyle(
                                color: AppColors
                                    .textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],

                          if (firmwareVersion != null &&
                              firmwareVersion
                                  .isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              "Firmware: $firmwareVersion",
                              style: const TextStyle(
                                color: AppColors
                                    .textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],

                          const SizedBox(height: 5),

                          Text(
                            "Device ID: ${document.id}",
                            style: const TextStyle(
                              color:
                              AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // =========================================================
  // ADD DEVICE
  // =========================================================

  void _showAddDeviceDialog(
      BuildContext context,
      ) {
    final nameController =
    TextEditingController();

    final ipController =
    TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder:
              (dialogStateContext, setDialogState) {
            return AlertDialog(
              title: const Text(
                "Add ESP32 Device",
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textCapitalization:
                      TextCapitalization.words,
                      decoration:
                      const InputDecoration(
                        labelText: "Device Name",
                        hintText:
                        "Example: Living Room ESP32",
                        border:
                        OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: ipController,
                      keyboardType:
                      TextInputType.number,
                      decoration:
                      const InputDecoration(
                        labelText:
                        "IP Address (Optional)",
                        hintText:
                        "Example: 192.168.1.100",
                        border:
                        OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                    final deviceName =
                    nameController.text
                        .trim();

                    final ipAddress =
                    ipController.text
                        .trim();

                    if (deviceName.isEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please enter a device name.",
                          ),
                        ),
                      );

                      return;
                    }

                    setDialogState(() {
                      isSaving = true;
                    });

                    final success =
                    await DeviceService
                        .instance
                        .addDevice(
                      deviceName:
                      deviceName,
                      deviceType: "ESP32",
                      ipAddress:
                      ipAddress.isEmpty
                          ? null
                          : ipAddress,
                    );

                    if (!context.mounted) {
                      return;
                    }

                    if (success) {
                      if (dialogContext
                          .mounted) {
                        Navigator.of(
                          dialogContext,
                        ).pop();
                      }

                      // Prevent dialog lifecycle
                      // issue after Firestore update.
                      await Future<void>.delayed(
                        const Duration(
                          milliseconds: 200,
                        ),
                      );

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "ESP32 device added successfully.",
                          ),
                        ),
                      );
                    } else {
                      setDialogState(() {
                        isSaving = false;
                      });

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Failed to add device.",
                          ),
                        ),
                      );
                    }
                  },

                  child: isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );

    // We intentionally don't dispose the controllers
    // immediately here because the dialog may still
    // be completing its removal animation.
  }
}