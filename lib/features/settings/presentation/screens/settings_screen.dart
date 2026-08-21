import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/core/constants/app_constants.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/progress/presentation/providers/progress_providers.dart';
import 'package:kanji_lesson/features/settings/presentation/providers/settings_providers.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/l10n/app_localizations.dart';
import 'package:kanji_lesson/core/services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final accentColor = ref.watch(accentColorProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // ─── Accent Color ───────────────────────────────────
          ListTile(
            leading: const Icon(Icons.palette_rounded),
            title: Text(l10n.accentColor),
            subtitle: Text(
              AppAccentPalette.options
                  .firstWhere((o) => o.color.toARGB32() == accentColor)
                  .name,
            ),
            trailing: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Color(accentColor),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).dividerTheme.color ?? const Color(0xFFE5E5E5),
                ),
              ),
            ),
            onTap: () => _showAccentPicker(context, ref, accentColor),
          ),
          const Divider(),

          // ─── Language ───────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: Text(l10n.language),
            trailing: DropdownButton<String>(
              value: locale.languageCode,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'id', child: Text('Bahasa Indonesia')),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(localeProvider.notifier).setLocale(val);
                }
              },
            ),
          ),
          const Divider(),

          // ─── Daily Goal ─────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.track_changes_rounded),
            title: Text(l10n.dailyGoal),
            subtitle: Text(l10n.currentGoal(ref.watch(dailyGoalProvider))),
            trailing: const Icon(Icons.edit_rounded),
            onTap: () => _showDailyGoalPicker(context, ref),
          ),
          const Divider(),

          // ─── Daily Reminder ─────────────────────────────────
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_rounded),
            title: Text(l10n.dailyReminder),
            subtitle: Text(ref.watch(reminderProvider).enabled 
                ? l10n.reminderSetFor(ref.watch(reminderProvider).time.format(context))
                : l10n.turnOnToGetReminded),
            value: ref.watch(reminderProvider).enabled,
            onChanged: (val) async {
              await ref.read(reminderProvider.notifier).setEnabled(val);
              if (val) {
                // Request permissions
                final granted = await NotificationService().requestPermissions();
                if (!granted) {
                  ref.read(reminderProvider.notifier).setEnabled(false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.notificationPermissionDenied)),
                    );
                  }
                  return;
                }
                
                if (context.mounted) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: ref.read(reminderProvider).time,
                  );
                  if (time != null) {
                    await ref.read(reminderProvider.notifier).setTime(time);
                    final state = ref.read(reminderProvider);
                    await NotificationService().scheduleDailyReminder(time, playSound: state.sound, enableVibration: state.vibration);
                  } else {
                    final state = ref.read(reminderProvider);
                    await NotificationService().scheduleDailyReminder(state.time, playSound: state.sound, enableVibration: state.vibration);
                  }
                }
              } else {
                await NotificationService().cancelReminder();
              }
            },
          ),
          if (ref.watch(reminderProvider).enabled) ...[
            ListTile(
              leading: const Icon(Icons.access_time_rounded, color: Colors.transparent),
              title: Text(l10n.changeReminderTime),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: ref.read(reminderProvider).time,
                );
                if (time != null) {
                  await ref.read(reminderProvider.notifier).setTime(time);
                  final state = ref.read(reminderProvider);
                  await NotificationService().scheduleDailyReminder(time, playSound: state.sound, enableVibration: state.vibration);
                }
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.volume_up_rounded, color: Colors.transparent),
              title: Text(l10n.sound),
              value: ref.watch(reminderProvider).sound,
              onChanged: (val) async {
                await ref.read(reminderProvider.notifier).setSound(val);
                final state = ref.read(reminderProvider);
                await NotificationService().scheduleDailyReminder(state.time, playSound: state.sound, enableVibration: state.vibration);
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.vibration_rounded, color: Colors.transparent),
              title: Text(l10n.vibration),
              value: ref.watch(reminderProvider).vibration,
              onChanged: (val) async {
                await ref.read(reminderProvider.notifier).setVibration(val);
                final state = ref.read(reminderProvider);
                await NotificationService().scheduleDailyReminder(state.time, playSound: state.sound, enableVibration: state.vibration);
              },
            ),
          ],
          const Divider(),

          // ─── Theme ──────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.dark_mode_rounded),
            title: Text(l10n.theme),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              items: [
                DropdownMenuItem(value: ThemeMode.system, child: Text(l10n.system)),
                DropdownMenuItem(value: ThemeMode.light, child: Text(l10n.light)),
                DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.dark)),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(val);
                }
              },
            ),
          ),
          const Divider(),

          // ─── Reset Progress ─────────────────────────────────
          ListTile(
            leading: const Icon(Icons.refresh_rounded, color: Colors.orange),
            title: Text(l10n.resetLearningProgress),
            subtitle: Text(l10n.clearProgressSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showResetDialog(context, ref),
          ),
          const Divider(),

          // ─── Danger Zone ────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
            title: Text(l10n.resetAllData),
            subtitle: Text(l10n.deleteAllProgressSubtitle),
            textColor: Colors.red,
            onTap: () => _showDangerousResetDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showAccentPicker(BuildContext context, WidgetRef ref, int currentColor) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.accentColor, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 20),
                ...AppAccentPalette.options.map((option) {
                  final isSelected = option.color.toARGB32() == currentColor;
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: option.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(option.name),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: option.color)
                        : null,
                    onTap: () {
                      ref.read(accentColorProvider.notifier).setAccentColor(option.color.toARGB32());
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDailyGoalPicker(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentGoal = ref.read(dailyGoalProvider);
    final options = [5, 10, 15, 20, 30, 50];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.dailyGoal, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 20),
                ...options.map((option) {
                  final isSelected = option == currentGoal;
                  return ListTile(
                    title: Text('$option correct answers'),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      ref.read(dailyGoalProvider.notifier).setDailyGoal(option);
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showResetDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    int? selectedLevel;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.resetLearningProgress),
          content: SingleChildScrollView(
            child: RadioGroup<int?>(
              groupValue: selectedLevel,
              onChanged: (val) => setState(() => selectedLevel = val),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<int?>(
                    value: null,
                    title: Text(l10n.allLevels),
                    subtitle: Text(l10n.clearProgressSubtitle),
                  ),
                  ...AppConstants.jlptLevels.map((level) => RadioListTile<int?>(
                    value: level,
                    title: Text('JLPT N$level'),
                    subtitle: FutureBuilder<JlptStats>(
                      future: ref.read(jlptStatsProvider(level).future),
                      builder: (_, snapshot) {
                        if (snapshot.hasData) {
                          return Text('${snapshot.data!.learned} ${l10n.learned}, ${snapshot.data!.mastered} ${l10n.mastered}');
                        }
                        return const Text('Loading...');
                      },
                    ),
                  )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                Navigator.pop(context);
                final db = ref.read(databaseProvider);
                if (selectedLevel == null) {
                  await db.resetAllProgress();
                } else {
                  await db.resetJlptProgress(selectedLevel!);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.progressResetSuccess),
                    ),
                  );
                  ref.invalidate(overallProgressProvider);
                  ref.invalidate(weakKanjiCountProvider);
                  ref.invalidate(weeklyActivityProvider);
                  ref.invalidate(quizHistoryProvider);
                  ref.invalidate(studyStreakProvider);
                  for (final level in AppConstants.jlptLevels) {
                    ref.invalidate(jlptStatsProvider(level));
                  }
                }
              },
              child: Text(l10n.reset),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDangerousResetDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    bool confirm = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('⚠️ ${l10n.dangerZoneResetTitle}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dangerZoneResetContent,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('I understand this cannot be undone'),
                value: confirm,
                onChanged: (val) => setState(() => confirm = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: confirm
                  ? () async {
                      Navigator.pop(context);
                      final db = ref.read(databaseProvider);
                      await db.clearAllCache();
                      await db.resetAllProgress();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All data has been reset!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        ref.invalidate(overallProgressProvider);
                        ref.invalidate(weakKanjiCountProvider);
                        ref.invalidate(weeklyActivityProvider);
                        ref.invalidate(quizHistoryProvider);
                        ref.invalidate(studyStreakProvider);
                        for (final level in AppConstants.jlptLevels) {
                          ref.invalidate(jlptStatsProvider(level));
                        }
                        ref.invalidate(kanjiListProvider);
                      }
                    }
                  : null,
              child: Text(l10n.resetAllData),
            ),
          ],
        ),
      ),
    );
  }
}
