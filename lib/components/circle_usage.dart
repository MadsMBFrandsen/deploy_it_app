import 'package:flutter/material.dart';

class CircleUsage extends StatelessWidget {
  final String label;
  final double usage;

  const CircleUsage({required this.label, required this.usage, super.key});

  Color _getUsageColor(double usage) {
    if (usage >= 0.9) return Colors.red;
    if (usage >= 0.6) return Colors.yellow[700]!;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final usageColor = _getUsageColor(usage);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: usage.clamp(0.0, 1.0),
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(usageColor),
              ),
            ),
            Text('${(usage * 100).toInt()}%', style: const TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
