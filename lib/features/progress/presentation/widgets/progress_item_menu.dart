import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/features/progress/presentation/providers/progress_providers.dart';
import 'package:kanji_lesson/l10n/app_localizations.dart';

/// Popup menu untuk mengelola progres satu item:
/// ubah status (unseen/learning/reviewing/mastered) atau hapus progres.
class ProgressItemMenu extends ConsumerWidget {
  const ProgressItemMenu({super.key, required this.character});

  final String character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    Future<void> setStatus(String status) async {
      await manageProgressItem(ref, character, newStatus: status);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.statusLabel(status))),
        );
      }
    }

    Future<void> delete() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.deleteProgress),
          content: Text(l10n.deleteProgressConfirm(character)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await manageProgressItem(ref, character);
      }
    }

    return PopupMenuButton<String>(
      tooltip: l10n.setStatus,
      onSelected: (value) {
        if (value == 'delete') {
          delete();
        } else {
          setStatus(value);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'unseen', child: Text(l10n.statusUnseen)),
        PopupMenuItem(value: 'learning', child: Text(l10n.statusLearning)),
        PopupMenuItem(value: 'reviewing', child: Text(l10n.statusReviewing)),
        PopupMenuItem(value: 'mastered', child: Text(l10n.statusMastered)),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            l10n.deleteProgress,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}
