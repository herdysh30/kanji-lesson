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
      appBar: AppBar(
        title: Text(l10n.settings, style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildSectionHeader(context, l10n.settingsAppearance),
          _buildSettingsGroup(
            context,
            children: [
              _buildListTile(
                context: context,
                icon: Icons.palette_rounded,
                title: l10n.accentColor,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: AppAccentPalette.options.map((option) {
                    final isSelected = option.color.toARGB32() == accentColor;
                    return GestureDetector(
                      onTap: () {
                        ref.read(accentColorProvider.notifier).setAccentColor(option.color.toARGB32());
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: option.color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
                              : Border.all(color: Colors.transparent, width: 2),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 1, indent: 56),
              _buildListTile(
                context: context,
                icon: Icons.dark_mode_rounded,
                title: l10n.theme,
                trailing: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_rounded)),
                    ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_rounded)),
                    ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_rounded)),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    ref.read(themeModeProvider.notifier).setThemeMode(newSelection.first);
                  },
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader(context, l10n.settingsPreferences),
          _buildSettingsGroup(
            context,
            children: [
              _buildListTile(
                context: context,
                icon: Icons.language_rounded,
                title: l10n.language,
                trailing: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'en', label: Text('EN')),
                    ButtonSegment(value: 'id', label: Text('ID')),
                  ],
                  selected: {locale.languageCode},
                  onSelectionChanged: (Set<String> newSelection) {
                    ref.read(localeProvider.notifier).setLocale(newSelection.first);
                  },
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                secondary: Icon(Icons.star_rounded, color: Theme.of(context).colorScheme.primary),
                title: Text('Item of the Day', style: Theme.of(context).textTheme.titleSmall),
                subtitle: Text('Display on Home Screen', style: Theme.of(context).textTheme.bodySmall),
                value: ref.watch(showKanjiOfTheDayProvider),
                onChanged: (val) {
                  ref.read(showKanjiOfTheDayProvider.notifier).setShowKanjiOfTheDay(val);
                },
                activeTrackColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader(context, l10n.settingsStudyReminders),
          _buildSettingsGroup(
            context,
            children: [
              _buildListTile(
                context: context,
                icon: Icons.track_changes_rounded,
                title: l10n.dailyGoal,
                subtitle: l10n.currentGoal(ref.watch(dailyGoalProvider)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showDailyGoalPicker(context, ref),
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                secondary: Icon(Icons.notifications_active_rounded, color: Theme.of(context).colorScheme.primary),
                title: Text(l10n.dailyReminder, style: Theme.of(context).textTheme.titleSmall),
                subtitle: Text(ref.watch(reminderProvider).enabled 
                    ? l10n.reminderSetFor(ref.watch(reminderProvider).time.format(context))
                    : l10n.turnOnToGetReminded,
                    style: Theme.of(context).textTheme.bodySmall),
                value: ref.watch(reminderProvider).enabled,
                activeTrackColor: Theme.of(context).colorScheme.primary,
                onChanged: (val) async {
                  await ref.read(reminderProvider.notifier).setEnabled(val);
                  if (val) {
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
                      }
                      final state = ref.read(reminderProvider);
                      await NotificationService().scheduleDailyReminder(state.time, playSound: state.sound, enableVibration: state.vibration);
                    }
                  } else {
                    await NotificationService().cancelReminder();
                  }
                },
              ),
              if (ref.watch(reminderProvider).enabled) ...[
                const Divider(height: 1, indent: 56),
                _buildListTile(
                  context: context,
                  icon: Icons.access_time_rounded,
                  iconColor: Colors.transparent,
                  title: l10n.changeReminderTime,
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
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  secondary: const Icon(Icons.volume_up_rounded, color: Colors.transparent),
                  title: Text(l10n.sound, style: Theme.of(context).textTheme.titleSmall),
                  value: ref.watch(reminderProvider).sound,
                  onChanged: (val) async {
                    await ref.read(reminderProvider.notifier).setSound(val);
                    final state = ref.read(reminderProvider);
                    await NotificationService().scheduleDailyReminder(state.time, playSound: state.sound, enableVibration: state.vibration);
                  },
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  secondary: const Icon(Icons.vibration_rounded, color: Colors.transparent),
                  title: Text(l10n.vibration, style: Theme.of(context).textTheme.titleSmall),
                  value: ref.watch(reminderProvider).vibration,
                  onChanged: (val) async {
                    await ref.read(reminderProvider.notifier).setVibration(val);
                    final state = ref.read(reminderProvider);
                    await NotificationService().scheduleDailyReminder(state.time, playSound: state.sound, enableVibration: state.vibration);
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader(context, l10n.settingsDataManagement),
          _buildSettingsGroup(
            context,
            children: [
              _buildListTile(
                context: context,
                icon: Icons.refresh_rounded,
                iconColor: Colors.orange,
                title: l10n.resetLearningProgress,
                subtitle: l10n.clearProgressSubtitle,
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showResetDialog(context, ref),
              ),
              const Divider(height: 1, indent: 56),
              _buildListTile(
                context: context,
                icon: Icons.delete_forever_rounded,
                iconColor: Colors.red,
                title: l10n.resetAllData,
                subtitle: l10n.deleteAllProgressSubtitle,
                titleColor: Colors.red,
                onTap: () => _showDangerousResetDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 100), // Extra padding for CurvedNavigationBar
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? const Color(0xFFE5E5E5),
          width: 0.5,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
        size: 26,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: titleColor ?? Theme.of(context).colorScheme.onSurface,
            ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
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
