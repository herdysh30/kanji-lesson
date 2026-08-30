import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/constants/srs_constants.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/features/review/presentation/screens/review_session_screen.dart';

class ReviewResultScreen extends StatelessWidget {
  const ReviewResultScreen({
    super.key,
    required this.correctCount,
    required this.wrongCount,
    required this.totalCount,
    this.srsChanges = const [],
  });

  final int correctCount;
  final int wrongCount;
  final int totalCount;
  final List<SrsChange> srsChanges;

  @override
  Widget build(BuildContext context) {
    final accuracy = totalCount > 0 ? correctCount / totalCount : 0.0;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                accuracy >= 0.8 ? Icons.emoji_events_rounded : Icons.check_circle_outline_rounded,
                size: 100,
                color: accuracy >= 0.8 ? Colors.amber : AppColors.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Review Complete!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You have completed $totalCount reviews.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              
              // Stats Cards
              Row(
                children: [
                  _StatCard(
                    title: 'Correct',
                    value: '$correctCount',
                    color: AppColors.correct,
                  ),
                  const SizedBox(width: 16),
                  _StatCard(
                    title: 'Wrong',
                    value: '$wrongCount',
                    color: AppColors.incorrect,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'Accuracy',
                value: '${(accuracy * 100).round()}%',
                color: AppColors.primary,
                isFullWidth: true,
              ),
              const SizedBox(height: 24),

              // SRS Changes
              if (srsChanges.isNotEmpty) ...[
                Text(
                  'SRS Changes',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: srsChanges.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final change = srsChanges[index];
                      final ratingIcon = switch (change.rating) {
                        SrsRating.again => '❌',
                        SrsRating.hard => '⚠️',
                        SrsRating.good => '✅',
                        SrsRating.easy => '⭐',
                      };
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(ratingIcon, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              change.character,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(
                              '${change.oldStatus} → ${change.newStatus}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Back to Home', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    this.isFullWidth = false,
  });

  final String title;
  final String value;
  final Color color;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
    
    if (isFullWidth) return child;
    return Expanded(child: child);
  }
}
