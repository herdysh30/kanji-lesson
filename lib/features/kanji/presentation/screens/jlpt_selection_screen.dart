import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/constants/app_constants.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';

class JlptSelectionScreen extends ConsumerWidget {
  const JlptSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JLPT Levels'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AppConstants.jlptLevels.length,
        itemBuilder: (context, index) {
          final level = AppConstants.jlptLevels[index];
          return _JlptLevelCard(level: level);
        },
      ),
    );
  }
}

class _JlptLevelCard extends ConsumerWidget {
  const _JlptLevelCard({required this.level});
  final int level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(jlptStatsProvider(level));
    final color = AppColors.jlptColor(level);
    final description = AppConstants.jlptLevelDescriptions[level] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go('/learn/$level'),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: color, width: 4),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Level badge
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'N$level',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      stats.when(
                        data: (data) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data.learned} / ${data.total} learned',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: data.progress,
                                minHeight: 6,
                                color: color,
                                backgroundColor:
                                    color.withValues(alpha: 0.15),
                              ),
                            ),
                          ],
                        ),
                        loading: () => const SizedBox(height: 30),
                        error: (_, __) => const Text('Tap to load'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
