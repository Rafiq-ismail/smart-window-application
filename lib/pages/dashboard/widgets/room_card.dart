import 'package:flutter/material.dart';

class RoomCard extends StatelessWidget {
  final String roomName;
  final bool isOpen;
  final IconData icon;
  final VoidCallback? onTap;

  const RoomCard({
    super.key,
    required this.roomName,
    required this.isOpen,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [

              CircleAvatar(
                radius: 28,
                backgroundColor:
                isOpen ? Colors.green.shade100 : Colors.red.shade100,
                child: Icon(
                  icon,
                  color: isOpen ? Colors.green : Colors.red,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      roomName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      isOpen ? "OPEN" : "CLOSED",
                      style: TextStyle(
                        color:
                        isOpen ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey.shade500,
              ),

            ],
          ),
        ),
      ),
    );
  }
}