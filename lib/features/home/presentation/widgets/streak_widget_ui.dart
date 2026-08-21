import 'package:flutter/material.dart';

class StreakWidgetUi extends StatelessWidget {
  const StreakWidgetUi({
    super.key,
    required this.streak,
    required this.goalReached,
  });

  final int streak;
  final bool goalReached;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: goalReached 
            ? Colors.orange.withValues(alpha: 0.9) 
            : const Color(0xFF2C2C2C).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🔥',
            style: TextStyle(fontSize: 100),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                '$streak',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
          ),
          const Text(
            'Day Streak',
            style: TextStyle(
              fontSize: 48,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
