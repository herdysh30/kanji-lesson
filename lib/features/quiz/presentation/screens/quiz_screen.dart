import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/features/quiz/domain/services/quiz_generator.dart';
import 'package:kanji_lesson/features/kanji/presentation/widgets/kanji_audio_button.dart';
import 'package:kanji_lesson/features/kanji/presentation/widgets/kanji_drawing_pad.dart';
import 'package:kanji_lesson/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:kanji_lesson/core/services/mlkit_digital_ink_service.dart';
import 'package:kanji_lesson/l10n/app_localizations.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart'
    as mlkit;

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int? _selectedAnswerIndex;
  bool _isAnswerRevealed = false;

  // Writing Quiz state
  mlkit.Ink? _currentInk;
  bool _isChecking = false;
  bool _showHint = false;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsInit = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("ja-JP");
    _isTtsInit = true;
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _playCurrentAudio(QuizQuestion question) async {
    if (!_isTtsInit) return;
    // For reading quizzes, only play audio after answer is revealed
    if (question.type == QuizType.reading && !_isAnswerRevealed) return;
    final text = question.sentenceObj != null
        ? question.sentenceObj!.japanese
        : (question.kanjiCharacter ?? question.correctAnswer);
    try {
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  void _handleOptionSelected(int index, QuizQuestion question) {
    if (_isAnswerRevealed) return; // Prevent multiple taps

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswerRevealed = true;
    });

    _playCurrentAudio(question);

    final notifier = ref.read(quizSessionProvider.notifier);
    notifier.answerCurrent(index);
  }

  void _onNextPressed() {
    final state = ref.read(quizSessionProvider);
    if (state.isFinished) {
      context.pushReplacement('/quiz/result');
    } else {
      setState(() {
        _selectedAnswerIndex = null;
        _isAnswerRevealed = false;
        _currentInk = null;
        _showHint = false;
      });
      ref.read(quizSessionProvider.notifier).nextQuestion();

      if (ref.read(quizSessionProvider).isFinished) {
        context.pushReplacement('/quiz/result');
      }
    }
  }

  String _kanaToRomaji(String kana) {
    if (kana.isEmpty) return '';
    if (!RegExp(r'[\u3040-\u309F\u30A0-\u30FF]').hasMatch(kana)) return '';
    
    final map = {
      'きゃ': 'kya', 'きゅ': 'kyu', 'きょ': 'kyo',
      'しゃ': 'sha', 'しゅ': 'shu', 'しょ': 'sho',
      'ちゃ': 'cha', 'ちゅ': 'chu', 'ちょ': 'cho',
      'にゃ': 'nya', 'にゅ': 'nyu', 'にょ': 'nyo',
      'ひゃ': 'hya', 'ひゅ': 'hyu', 'ひょ': 'hyo',
      'みゃ': 'mya', 'みゅ': 'myu', 'みょ': 'myo',
      'りゃ': 'rya', 'りゅ': 'ryu', 'りょ': 'ryo',
      'ぎゃ': 'gya', 'ぎゅ': 'gyu', 'ぎょ': 'gyo',
      'じゃ': 'ja', 'じゅ': 'ju', 'じょ': 'jo',
      'びゃ': 'bya', 'びゅ': 'byu', 'びょ': 'byo',
      'ぴゃ': 'pya', 'ぴゅ': 'pyu', 'ぴょ': 'pyo',
      'か': 'ka', 'き': 'ki', 'く': 'ku', 'け': 'ke', 'こ': 'ko',
      'さ': 'sa', 'し': 'shi', 'す': 'su', 'せ': 'se', 'そ': 'so',
      'た': 'ta', 'ち': 'chi', 'つ': 'tsu', 'て': 'te', 'と': 'to',
      'な': 'na', 'に': 'ni', 'ぬ': 'nu', 'ね': 'ne', 'の': 'no',
      'は': 'ha', 'ひ': 'hi', 'ふ': 'fu', 'へ': 'he', 'ほ': 'ho',
      'ま': 'ma', 'み': 'mi', 'む': 'mu', 'め': 'me', 'も': 'mo',
      'や': 'ya', 'ゆ': 'yu', 'よ': 'yo',
      'ら': 'ra', 'り': 'ri', 'る': 'ru', 'れ': 're', 'ろ': 'ro',
      'わ': 'wa', 'を': 'o', 'ん': 'n',
      'が': 'ga', 'ぎ': 'gi', 'ぐ': 'gu', 'げ': 'ge', 'ご': 'go',
      'ざ': 'za', 'じ': 'ji', 'ず': 'zu', 'ぜ': 'ze', 'ぞ': 'zo',
      'だ': 'da', 'ぢ': 'ji', 'づ': 'zu', 'で': 'de', 'ど': 'do',
      'ば': 'ba', 'び': 'bi', 'ぶ': 'bu', 'べ': 'be', 'ぼ': 'bo',
      'ぱ': 'pa', 'ぴ': 'pi', 'ぷ': 'pu', 'ぺ': 'pe', 'ぽ': 'po',
      'あ': 'a', 'い': 'i', 'う': 'u', 'え': 'e', 'お': 'o',
      'ー': '-',
    };

    String result = kana;
    
    // Sort keys by length descending to match longest first
    final keys = map.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
    
    // Handle small tsu (sokuon)
    for (int i = 0; i < result.length; i++) {
      if (result[i] == 'っ' && i + 1 < result.length) {
        for (final k in keys) {
           if (result.substring(i + 1).startsWith(k)) {
              final romaji = map[k]!;
              result = result.replaceRange(i, i + 1, romaji[0]);
              break;
           }
        }
      }
    }

    for (final k in keys) {
      result = result.replaceAll(k, map[k]!);
    }
    return result;
  }

  Widget _buildSentenceText(BuildContext context, QuizQuestion question) {
    if (question.kanjiCharacter == null) return Text(question.prompt);
    
    final parts = question.prompt.split(question.kanjiCharacter!);
    if (parts.length == 1) return Text(question.prompt); // Kanji not found in string
    
    final baseStyle = AppTheme.kanjiLarge(context).copyWith(
      fontSize: 28,
      fontWeight: FontWeight.normal,
      height: 1.2,
    );
    final boldStyle = baseStyle.copyWith(
      fontWeight: FontWeight.w900,
      color: Theme.of(context).colorScheme.primary,
    );

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: baseStyle,
        children: [
          for (int i = 0; i < parts.length; i++) ...[
            TextSpan(text: parts[i]),
            if (i < parts.length - 1)
              TextSpan(text: question.kanjiCharacter, style: boldStyle),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final initDataAsync = ref.watch(quizInitDataProvider);
    final sessionState = ref.watch(quizSessionProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmExit(context);
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(
                builder: (context, ref, _) {
                  final sessionState = ref.watch(quizSessionProvider);
                  final progress = sessionState.tasks.isEmpty
                      ? 0.0
                      : sessionState.currentIndex /
                            sessionState.tasks.length;
                  return SafeArea(
                    bottom: false,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      color: AppColors.incorrect,
                      minHeight: 4,
                    ),
                  );
                },
              ),
              Expanded(
                child: AppBar(
                  title: Text(l10n.quizSession),
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => _confirmExit(context),
                  ),
                  elevation: 0,
                  primary: false,
                ),
              ),
            ],
          ),
        ),
        body: initDataAsync.when(
          data: (initData) {
            if (initData.tasks.isEmpty) {
              final setup = ref.watch(quizSetupProvider);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.notEnoughQuizData(
                      setup.selectedJlptLevel?.toString() ?? l10n.myLearned,
                      setup.selectedItemTypes.map((e) => e.name).join(', '),
                      setup.selectedQuizTypes.map((e) => e.name).join(', '),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // Initialize session with loaded tasks
            Future.microtask(() {
              ref.read(quizSessionProvider.notifier).initialize(initData);
            });

            final currentQuestion = sessionState.currentQuestion;
            if (currentQuestion == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.preparingQuiz),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    l10n.questionOf(sessionState.currentIndex + 1, sessionState.tasks.length),
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),

                // Prompt Area (Prominently Centered at Top)
                if (currentQuestion.type != QuizType.writing)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 110,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: currentQuestion.sentenceObj != null
                                  ? _buildSentenceText(context, currentQuestion)
                                  : Text(
                                      currentQuestion.prompt,
                                      style: AppTheme.kanjiLarge(context).copyWith(
                                        fontSize: 96,
                                        fontWeight: FontWeight.bold,
                                        height: 1.1,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                          ),
                          // Show audio button ONLY after answered or if hint is shown
                          if (_isAnswerRevealed || _showHint) ...[
                            const SizedBox(height: 8),
                            KanjiAudioButton(
                              character: currentQuestion.sentenceObj != null
                                  ? currentQuestion.sentenceObj!.japanese
                                  : (currentQuestion.kanjiCharacter ?? currentQuestion.prompt),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                if (currentQuestion.type == QuizType.writing)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 16.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentQuestion.prompt,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          KanjiAudioButton(
                            character: currentQuestion.kanjiCharacter ?? currentQuestion.correctAnswer,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Sentence translations (Only for Sentence Quiz)
                if (currentQuestion.sentenceObj != null && _isAnswerRevealed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Column(
                      children: [
                        if (currentQuestion.sentenceObj!.romaji.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              currentQuestion.sentenceObj!.romaji,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Text(
                          currentQuestion.sentenceObj!.english,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentQuestion.sentenceObj!.indonesian,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                // Hint for Meaning/Reading Quizzes
                if (currentQuestion.type != QuizType.writing &&
                    !_isAnswerRevealed)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        child: _showHint
                            ? InkWell(
                                onTap: () => setState(() => _showHint = false),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        currentQuestion.sentenceObj != null
                                            ? currentQuestion.sentenceObj!.hiragana
                                            : (currentQuestion.options[currentQuestion.correctIndex].explanation ?? ''),
                                        style: Theme.of(context).textTheme.titleMedium
                                            ?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.visibility_off,
                                        size: 18,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : OutlinedButton(
                                onPressed: () {
                                  setState(() => _showHint = true);
                                  ref.read(quizSessionProvider.notifier).markHintUsed();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  side: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n.showHint,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.lightbulb_outline,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),

                // Question Instruction
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _getInstructionText(currentQuestion, l10n),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // Options or Drawing Pad
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: currentQuestion.type == QuizType.writing
                        ? _buildWritingPad(currentQuestion)
                        : CustomScrollView(
                            slivers: [
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ...List.generate(
                                      currentQuestion.options.length,
                                      (index) {
                                        final option =
                                            currentQuestion.options[index];
                                        final isSelected =
                                            _selectedAnswerIndex == index;
                                        final isCorrectOption =
                                            index ==
                                            currentQuestion.correctIndex;

                                        Color backgroundColor = Theme.of(
                                          context,
                                        ).colorScheme.surface;
                                        Color borderColor = Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant;
                                        Color textColor = Theme.of(
                                          context,
                                        ).colorScheme.onSurface;

                                        if (_isAnswerRevealed) {
                                          if (isCorrectOption) {
                                            backgroundColor = AppColors.correct
                                                .withValues(alpha: 0.15);
                                            borderColor = AppColors.correct;
                                            textColor = AppColors.correct;
                                          } else if (isSelected &&
                                              !isCorrectOption) {
                                            backgroundColor = AppColors
                                                .incorrect
                                                .withValues(alpha: 0.15);
                                            borderColor = AppColors.incorrect;
                                            textColor = AppColors.incorrect;
                                          } else {
                                            borderColor = Theme.of(context)
                                                .colorScheme
                                                .outlineVariant
                                                .withValues(alpha: 0.5);
                                            textColor = Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.5);
                                          }
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12.0,
                                          ),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor:
                                                    backgroundColor,
                                                foregroundColor: textColor,
                                                side: BorderSide(
                                                  color: borderColor,
                                                  width: 1.0,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                      horizontal: 20,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () =>
                                                  _handleOptionSelected(
                                                    index,
                                                    currentQuestion,
                                                  ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    option.text,
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          _isAnswerRevealed &&
                                                              (isCorrectOption ||
                                                                  isSelected)
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  if (RegExp(r'[\u3040-\u309F\u30A0-\u30FF]').hasMatch(option.text))
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 2),
                                                      child: Text(
                                                        _kanaToRomaji(option.text),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: textColor.withValues(alpha: 0.6),
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                  // Show explanation after answering
                                                  if (_isAnswerRevealed &&
                                                      option.kanjiCharacter !=
                                                          null)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 6,
                                                          ),
                                                      child: Text(
                                                        _getOptionExplanation(
                                                          currentQuestion,
                                                          option,
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: textColor
                                                              .withValues(
                                                                alpha: 0.85,
                                                              ),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Skip / Don't Know button
                                    if (!_isAnswerRevealed)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4,
                                          bottom: 8,
                                        ),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: TextButton(
                                            onPressed: () =>
                                                _handleOptionSelected(
                                                  -1,
                                                  currentQuestion,
                                                ),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                            child: Text(
                                              l10n.idkSkip,
                                              style: const TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Next button
                                    if (_isAnswerRevealed)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4,
                                          bottom: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                height: 52,
                                                child: FilledButton.icon(
                                                  onPressed: _onNextPressed,
                                            icon: const Icon(
                                              Icons.arrow_forward_rounded,
                                            ),
                                            label: Text(
                                                  sessionState.currentIndex >= sessionState.tasks.length - 1
                                                      ? l10n.seeResults
                                                      : l10n.nextQuestion,
                                                  style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                              ),
                                            ),
                                          ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            );
          },
          loading: () => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.preparingQuiz),
              ],
            ),
          ),
          error: (_, __) => const Center(child: Text('Failed to load quiz.')),
        ),
      ),
    );
  }

  String _getInstructionText(QuizQuestion question, AppLocalizations l10n) {
    if (question.sentenceObj != null) {
      if (question.type == QuizType.meaning) return l10n.instructionMeaning;
      if (question.type == QuizType.reading) return l10n.instructionReading;
    }
    switch (question.type) {
      case QuizType.meaning:
        return l10n.instructionWhatMeaning;
      case QuizType.reading:
        return l10n.instructionHowReading;
      case QuizType.writing:
        return l10n.instructionDraw;
    }
  }

  String _getOptionExplanation(QuizQuestion question, QuizOption option) {
    final kanji = option.kanjiCharacter ?? '';
    final explanation = option.explanation ?? '';
    if (question.sentenceObj != null) {
      return explanation;
    }
    switch (question.type) {
      case QuizType.meaning:
        return '$kanji — $explanation';
      case QuizType.reading:
        return '$kanji — $explanation';
      default:
        return kanji.isNotEmpty ? kanji : '';
    }
  }

  Future<void> _confirmExit(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.quitQuiz),
        content: Text(l10n.quitQuizConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.quit),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      context.pop();
    }
  }

  Widget _buildWritingPad(QuizQuestion currentQuestion) {
    return Column(
      children: [
        Expanded(
          child: IgnorePointer(
            ignoring: _isAnswerRevealed,
            child: KanjiDrawingPad(
              key: ValueKey(
                currentQuestion.kanjiCharacter ?? currentQuestion.correctAnswer,
              ),
              character:
                  currentQuestion.kanjiCharacter ??
                  currentQuestion.correctAnswer,
              showBackground: _showHint || _isAnswerRevealed,
              topAction: TextButton.icon(
                onPressed: _isAnswerRevealed
                    ? null
                    : () => setState(() => _showHint = !_showHint),
                icon: Icon(
                  _showHint ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                ),
                label: Text(_showHint ? 'Hide Hint' : 'Show Hint'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              onInkChanged: (ink) => setState(() => _currentInk = ink),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (!_isAnswerRevealed)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isAnswerRevealed = true;
                    _showHint = true;
                    _selectedAnswerIndex = 1; // 1 means incorrect
                  });
                  _playCurrentAudio(currentQuestion);
                  ref.read(quizSessionProvider.notifier).answerCurrent(-1);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('I don\'t know / Skip'),
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: _isAnswerRevealed
              ? Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: _onNextPressed,
                  icon: Icon(
                    _selectedAnswerIndex == 0
                        ? Icons.check_circle_rounded
                        : Icons.close_rounded,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _selectedAnswerIndex == 0
                        ? AppColors.correct
                        : AppColors.incorrect,
                  ),
                  label: Text(
                    _selectedAnswerIndex == 0
                        ? 'Correct! → Next'
                        : 'Wrong (${currentQuestion.correctAnswer}) → Next',
                  ),
                        ),
                      ),
                    ),
                  ],
                )
              : FilledButton.icon(
                  onPressed:
                      _isChecking ||
                          _currentInk == null ||
                          _currentInk!.strokes.isEmpty
                      ? null
                      : () => _handleCheckDrawing(currentQuestion),
                  icon: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(_isChecking ? 'Checking...' : 'Check Answer'),
                ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _handleCheckDrawing(QuizQuestion currentQuestion) async {
    if (_currentInk == null || _currentInk!.strokes.isEmpty) return;

    setState(() {
      _isChecking = true;
    });

    final mlkitService = ref.read(mlkitDigitalInkServiceProvider);
    final candidates = await mlkitService.recognizeKanji(_currentInk!);

    setState(() {
      _isChecking = false;
      _isAnswerRevealed = true;
      _showHint = true;
    });

    bool isCorrect = false;
    final target =
        currentQuestion.kanjiCharacter ?? currentQuestion.correctAnswer;

    // Check if any of the candidates match the target character
    if (candidates.isNotEmpty) {
      final allCandidates = candidates.map((c) => c.text).toList();
      if (allCandidates.contains(target)) {
        isCorrect = true;
      }
    }

    // Set 0 for correct, 1 for wrong (dummy index for the notifier)
    setState(() {
      _selectedAnswerIndex = isCorrect ? 0 : 1;
    });

    _playCurrentAudio(currentQuestion);

    // We must manually add options to the question so the notifier knows about the correct index.
    // However, writing question options are already set to [k.character].
    // Let's modify the notifier's logic by just passing 0 or 1.
    // Wait, the notifier uses `answerCurrent` which expects `selectedIndex` against `correctIndex`.
    // For writing, `options` is `[targetKanji]`. So `correctIndex` is 0.
    // If it's correct, we pass 0. If wrong, we pass 1 (which is out of bounds, but it evaluates to wrong!)

    ref.read(quizSessionProvider.notifier).answerCurrent(isCorrect ? 0 : 1);
  }
}
