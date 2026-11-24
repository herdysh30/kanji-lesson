import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/features/progress/presentation/widgets/progress_item_menu.dart';
import 'package:kanji_lesson/features/review/presentation/providers/review_providers.dart';
import 'package:kanji_lesson/l10n/app_localizations.dart';

/// Bottom sheet berisi daftar item yang akan direview (due reviews).
/// Tiap item bisa diedit via [ProgressItemMenu] — ubah status / hapus.
void showReviewQueueSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => const _ReviewQueueSheet(),
  );
}

class _ReviewQueueSheet extends ConsumerWidget {
  const _ReviewQueueSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dueReviewsAsync = ref.watch(dueReviewsProvider);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.playlist_play_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.reviewQueue,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: dueReviewsAsync.when(
                  data: (items) => items.isEmpty
                      ? _EmptyQueue(l10n: l10n)
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) =>
                              _QueueTile(item: items[index], l10n: l10n),
                        ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => _EmptyQueue(l10n: l10n),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  const _QueueTile({required this.item, required this.l10n});

  final UserKanjiProgressEntry item;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final text = item.kanjiCharacter;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        text,
        style: AppTheme.kanjiLarge(context).copyWith(fontSize: 20),
      ),
      subtitle: Text(l10n.statusLabel(item.status)),
      trailing: ProgressItemMenu(character: text),
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.reviewQueueEmpty,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
