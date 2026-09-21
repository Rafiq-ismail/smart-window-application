import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../services/window_service.dart';

class WindowsPage extends StatelessWidget {
  const WindowsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("My Windows"),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),

      // ADD WINDOW BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddWindowDialog(context);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text("Add Window"),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: WindowService.instance.getUserWindows(),

        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ERROR
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Unable to load windows.\n${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }

          final windows = snapshot.data?.docs ?? [];

          // EMPTY
          if (windows.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.window_outlined,
                      size: 70,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No Windows Added",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Your registered smart windows will appear here.",
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

          // WINDOW LIST
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              100,
            ),
            itemCount: windows.length,
            separatorBuilder: (_, _) =>
            const SizedBox(height: 12),

            itemBuilder: (context, index) {
              final document = windows[index];
              final data = document.data();

              final name =
                  data['name']?.toString() ?? 'Window';

              final status =
                  data['status']?.toString() ?? 'CLOSED';

              final openingPercentage =
                  (data['openingPercentage'] as num?)
                      ?.toInt() ??
                      0;

              final isOpen = status == 'OPEN';

              // CLICKABLE WINDOW CARD
              return InkWell(
                borderRadius: BorderRadius.circular(18),

                onTap: () {
                  _showWindowControlDialog(
                    context: context,
                    windowId: document.id,
                    windowName: name,
                    status: status,
                    openingPercentage: openingPercentage,
                  );
                },

                child: Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.divider,
                    ),
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,

                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius:
                          BorderRadius.circular(14),
                        ),

                        child: Icon(
                          isOpen
                              ? Icons.window_rounded
                              : Icons.window_outlined,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "$status • $openingPercentage%",
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // ADD WINDOW DIALOG
  // ============================================================

  void _showAddWindowDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                "Add New Window",
              ),

              content: TextField(
                controller: nameController,
                autofocus: true,
                textCapitalization:
                TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: "Window Name",
                  hintText: "Example: Bedroom Window",
                  border: OutlineInputBorder(),
                ),
              ),

              actions: [
                // CANCEL
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Cancel"),
                ),

                // ADD
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                    final name =
                    nameController.text.trim();

                    // VALIDATION
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please enter a window name.",
                          ),
                        ),
                      );
                      return;
                    }

                    // SHOW LOADING
                    setDialogState(() {
                      isSaving = true;
                    });

                    // SAVE TO FIRESTORE
                    final success =
                    await WindowService.instance
                        .addWindow(
                      name: name,
                    );

                    if (!context.mounted) {
                      return;
                    }

                    // SUCCESS
                    if (success) {
                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Window added successfully.",
                          ),
                        ),
                      );
                    } else {
                      // FAILED
                      setDialogState(() {
                        isSaving = false;
                      });

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Failed to add window.",
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
    ).then((_) {
      nameController.dispose();
    });
  }

  // ============================================================
  // WINDOW CONTROL DIALOG
  // ============================================================

  void _showWindowControlDialog({
    required BuildContext context,
    required String windowId,
    required String windowName,
    required String status,
    required int openingPercentage,
  }) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        bool isUpdating = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(windowName),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.window_rounded,
                    size: 60,
                    color: AppColors.primary,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Opening: $openingPercentage%",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              actions: [
                // CLOSE WINDOW
                OutlinedButton.icon(
                  onPressed: isUpdating
                      ? null
                      : () async {
                    setDialogState(() {
                      isUpdating = true;
                    });

                    final success =
                    await WindowService.instance
                        .updateWindowState(
                      windowId: windowId,
                      openingPercentage: 0,
                    );

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? "$windowName closed."
                              : "Failed to close window.",
                        ),
                      ),
                    );
                  },

                  icon: const Icon(
                    Icons.close_rounded,
                  ),

                  label: const Text("Close"),
                ),

                // OPEN WINDOW
                ElevatedButton.icon(
                  onPressed: isUpdating
                      ? null
                      : () async {
                    setDialogState(() {
                      isUpdating = true;
                    });

                    final success =
                    await WindowService.instance
                        .updateWindowState(
                      windowId: windowId,
                      openingPercentage: 100,
                    );

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? "$windowName opened."
                              : "Failed to open window.",
                        ),
                      ),
                    );
                  },

                  icon: const Icon(
                    Icons.open_in_full_rounded,
                  ),

                  label: const Text("Open"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}