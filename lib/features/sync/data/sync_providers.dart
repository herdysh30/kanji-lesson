import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/sync/data/sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncService(db: db);
});

final isSyncingProvider = StateProvider<bool>((ref) => false);

final lastSyncTimeProvider = StateProvider<DateTime?>((ref) => null);

/// Call after any local progress write.
final syncSchedulerProvider = Provider<void Function()>((ref) {
  return () {
    final syncService = ref.read(syncServiceProvider);
    syncService.scheduleSync();
  };
});

/// Manual full sync.
final manualSyncProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    ref.read(isSyncingProvider.notifier).state = true;
    try {
      await ref.read(syncServiceProvider).syncNow();
      ref.read(lastSyncTimeProvider.notifier).state = DateTime.now();
    } finally {
      ref.read(isSyncingProvider.notifier).state = false;
    }
  };
});
