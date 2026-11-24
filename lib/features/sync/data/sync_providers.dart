import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/features/auth/presentation/providers/auth_providers.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/sync/data/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Manual sync (full equivalent): resets watermark, then syncs.
final manualSyncProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    ref.read(isSyncingProvider.notifier).state = true;
    try {
      final uid = ref.read(authStateProvider).value?.uid;
      if (uid != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('sync.watermark.$uid');
      }
      await ref.read(syncServiceProvider).syncNow();
      ref.read(lastSyncTimeProvider.notifier).state = DateTime.now();
    } finally {
      ref.read(isSyncingProvider.notifier).state = false;
    }
  };
});
