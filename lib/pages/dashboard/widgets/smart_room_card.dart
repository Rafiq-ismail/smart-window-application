import 'package:flutter/material.dart';

class SmartRoomCard extends StatelessWidget {
  final String roomName;
  final bool isOpen;
  final IconData icon;
  final VoidCallback onTap;

  const SmartRoomCard({
    super.key,
    required this.roomName,
    required this.isOpen,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [

              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade100,
                child: Icon(
                  icon,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      roomName,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [

                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isOpen
                                ? Colors.green
                                : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          isOpen
                              ? "Online"
                              : "Offline",
                          style: TextStyle(
                            color: isOpen
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Temperature : 28°C",
                      style: TextStyle(fontSize: 13),
                    ),

                    const SizedBox(height: 3),

                    const Text(
                      "Humidity : 65%",
                      style: TextStyle(fontSize: 13),
                    ),

                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),

            ],
          ),
        ),
      ),
    );
  }
}