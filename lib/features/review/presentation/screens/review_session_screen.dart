import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/constants/srs_constants.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/review/domain/services/srs_engine.dart';
import 'package:kanji_lesson/features/review/presentation/providers/review_providers.dart';
import 'package:kanji_lesson/features/settings/presentation/providers/settings_providers.dart';

// We need a StateNotifier to manage the current review session
final reviewSessionProvider = StateNotifierProvider.autoDispose<ReviewSessionNotifier, ReviewSessionState>((ref) {
  final dueReviews = ref.read(dueReviewsProvider).valueOrNull ?? [];
  return ReviewSessionNotifier(dueReviews, ref);
});

class ReviewSessionState {
  const ReviewSessionState({
    required this.queue,
    required this.currentIndex,
    required this.isFlipped,
    required this.correctCount,
    required this.wrongCount,
    required this.isFinished,
  });

  final List<UserKanjiProgressEntry> queue;
  final int currentIndex;
  final bool isFlipped;
  final int correctCount;
  final int wrongCount;
  final bool isFinished;

  UserKanjiProgressEntry? get currentItem => 
      currentIndex < queue.length ? queue[currentIndex] : null;

  ReviewSessionState copyWith({
    List<UserKanjiProgressEntry>? queue,
    int? currentIndex,
    bool? isFlipped,
    int? correctCount,
    int? wrongCount,
    bool? isFinished,
  }) {
    return ReviewSessionState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class ReviewSessionNotifier extends StateNotifier<ReviewSessionState> {
  ReviewSessionNotifier(List<UserKanjiProgressEntry> initialQueue, this.ref) 
      : super(ReviewSessionState(
          queue: List.from(initialQueue)..shuffle(),
          currentIndex: 0,
          isFlipped: false,
          correctCount: 0,
          wrongCount: 0,
          isFinished: initialQueue.isEmpty,
        ));
        
  final Ref ref;
  final SrsEngine _engine = const SrsEngine();

  void flipCard() {
    state = state.copyWith(isFlipped: true);
  }

  Future<void> submitRating(SrsRating rating) async {
    final item = state.currentItem;
    if (item == null) return;

    // Calculate next SRS schedule
    final result = _engine.calculate(
      rating: rating,
      currentEase: item.ease,
      currentIntervalDays: item.intervalDays,
      repetitions: item.repetitions,
      correctCount: item.correctCount,
      wrongCount: item.wrongCount,
    );

    // Save to DB
    final db = ref.read(databaseProvider);
    await db.updateProgress(
      kanjiCharacter: item.kanjiCharacter,
      status: result.newStatus,
      ease: result.newEase,
      intervalDays: result.newIntervalDays,
      repetitions: result.newRepetitions,
      nextReviewAt: result.nextReviewAt,
      isCorrect: rating != SrsRating.again,
    );
    
    // Also record daily progress
    await db.incrementDailyReviewed(rating != SrsRating.again);

    // Invalidate due reviews providers immediately so the home screen is always up to date
    ref.invalidate(dueReviewsProvider);
    ref.invalidate(dueReviewCountProvider);

    // Update state
    final isCorrect = rating != SrsRating.again;
    
    if (!isCorrect) {
      // Requeue incorrect items at the end
      final newQueue = List<UserKanjiProgressEntry>.from(state.queue)..add(item);
      state = state.copyWith(
        queue: newQueue,
        wrongCount: state.wrongCount + 1,
        currentIndex: state.currentIndex + 1,
        isFlipped: false,
      );
    } else {
      state = state.copyWith(
        correctCount: state.correctCount + 1,
        currentIndex: state.currentIndex + 1,
        isFlipped: false,
      );
    }

    // Check if finished
    if (state.currentIndex >= state.queue.length) {
      state = state.copyWith(isFinished: true);
      // Invalidate providers to refresh dashboards
      ref.invalidate(dueReviewCountProvider);
      ref.invalidate(dueReviewsProvider);
      // ref.invalidate(dailyStatsProvider); // TODO: Uncomment when progress feature is implemented
    }
  }
}

class ReviewSessionScreen extends ConsumerWidget {
  const ReviewSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewSessionProvider);

    // Navigate to result if finished
    if (state.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pushReplacement('/review/result', extra: {
          'correct': state.correctCount,
          'wrong': state.wrongCount,
          'total': state.queue.length,
        });
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentItem = state.currentItem;
    if (currentItem == null) {
      return const Scaffold(body: Center(child: Text('No items to review')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${state.currentIndex + 1} / ${state.queue.length}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _confirmExit(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: state.queue.isNotEmpty ? state.currentIndex / state.queue.length : 0,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: _Flashcard(
                  entry: currentItem,
                  isFlipped: state.isFlipped,
                  onFlip: () => ref.read(reviewSessionProvider.notifier).flipCard(),
                ),
              ),
              const SizedBox(height: 24),
              _ActionArea(isFlipped: state.isFlipped),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Review?'),
        content: const Text('Your progress so far has been saved, but the session is not complete.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End Session'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      context.pop();
    }
  }
}

class _Flashcard extends ConsumerWidget {
  const _Flashcard({
    required this.entry,
    required this.isFlipped,
    required this.onFlip,
  });

  final UserKanjiProgressEntry entry;
  final bool isFlipped;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch full details for the back of the card
    final detailAsync = ref.watch(reviewItemDetailProvider(entry.kanjiCharacter));
    final isId = ref.watch(localeProvider).languageCode == 'id';

    return GestureDetector(
      onTap: isFlipped ? null : onFlip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  entry.kanjiCharacter,
                  style: AppTheme.kanjiLarge(context).copyWith(fontSize: 100),
                ),
              ),
            ),
            if (isFlipped) ...[
              const SizedBox(height: 32),
              const Divider(indent: 32, endIndent: 32),
              const SizedBox(height: 24),
              detailAsync.when(
                data: (detail) => Column(
                  children: [
                    if (detail.isVocab) ...[
                      if (detail.furigana != null && detail.furigana!.isNotEmpty) ...[
                        Text(
                          detail.furigana!,
                          style: AppTheme.japaneseReading(context, fontSize: 28),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (detail.romaji != null && detail.romaji!.isNotEmpty) ...[
                        Text(
                          detail.romaji!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        detail.primaryMeaning ?? '',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      if (detail.primaryReading != null && detail.primaryReading!.isNotEmpty) ...[
                        Text(
                          detail.primaryReading!,
                          style: AppTheme.japaneseReading(context, fontSize: 28),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        detail.primaryMeaning ?? '',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (detail.onyomi != null && detail.onyomi!.isNotEmpty)
                        Text(
                          "ON: ${detail.onyomi!.join(', ')}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (detail.kunyomi != null && detail.kunyomi!.isNotEmpty)
                        Text(
                          "KUN: ${detail.kunyomi!.join(', ')}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 16),
                      _VocabularySlider(character: entry.kanjiCharacter, isId: isId),
                    ],
                  ],
                ),
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text(
                  'Failed to load details',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ] else ...[
              const SizedBox(height: 64),
              Text(
                'Tap to reveal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VocabularySlider extends ConsumerStatefulWidget {
  const _VocabularySlider({required this.character, required this.isId});
  
  final String character;
  final bool isId;

  @override
  ConsumerState<_VocabularySlider> createState() => _VocabularySliderState();
}

class _VocabularySliderState extends ConsumerState<_VocabularySlider> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vocabAsync = ref.watch(kanjiVocabularyProvider(widget.character));

    return vocabAsync.when(
      data: (vocabs) {
        if (vocabs.isEmpty) return const SizedBox.shrink();
        
        final displayVocabs = vocabs.take(15).toList();
        
        return SizedBox(
          height: 120, // Increased height to fit Column
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                itemCount: displayVocabs.length,
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final v = displayVocabs[index];
                  return Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            v.word,
                            style: AppTheme.japaneseReading(context, fontSize: 22),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            v.reading,
                            style: AppTheme.japaneseReading(context, fontSize: 13).copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            v.primaryMeaning(widget.isId),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (displayVocabs.length > 1) ...[
                if (_currentIndex > 0)
                  Positioned(
                    left: -8,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 32),
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                if (_currentIndex < displayVocabs.length - 1)
                  Positioned(
                    right: -8,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 32),
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 100, 
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ActionArea extends ConsumerWidget {
  const _ActionArea({required this.isFlipped});
  final bool isFlipped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isFlipped) {
      return SizedBox(
        width: double.infinity,
        height: 64,
        child: FilledButton(
          onPressed: () => ref.read(reviewSessionProvider.notifier).flipCard(),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Show Answer', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    return Row(
      children: [
        _RatingButton(
          label: 'Again',
          subLabel: '< 10m',
          color: AppColors.incorrect,
          onPressed: () => ref.read(reviewSessionProvider.notifier).submitRating(SrsRating.again),
        ),
        const SizedBox(width: 8),
        _RatingButton(
          label: 'Hard',
          subLabel: '1d',
          color: AppColors.warning,
          onPressed: () => ref.read(reviewSessionProvider.notifier).submitRating(SrsRating.hard),
        ),
        const SizedBox(width: 8),
        _RatingButton(
          label: 'Good',
          subLabel: '3d',
          color: AppColors.primary,
          onPressed: () => ref.read(reviewSessionProvider.notifier).submitRating(SrsRating.good),
        ),
        const SizedBox(width: 8),
        _RatingButton(
          label: 'Easy',
          subLabel: '7d',
          color: AppColors.correct,
          onPressed: () => ref.read(reviewSessionProvider.notifier).submitRating(SrsRating.easy),
        ),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.label,
    required this.subLabel,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final String subLabel;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
