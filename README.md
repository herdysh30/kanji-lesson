# Kanji Lesson 🇯🇵

A modern, offline-first Flutter application designed to help users master Japanese Kanji and Vocabulary through a smart Spaced Repetition System (SRS) inspired by WaniKani and Anki.

## 📱 What is this app?
**Kanji Lesson** is a comprehensive Japanese learning companion that allows users to study Kanji characters and JLPT vocabulary. Instead of just passive reading, the app enforces active recall through multiple-choice quizzes (Meaning & Reading) and interactive drawing quizzes (Writing). It tracks your learning progress over time, scheduling reviews exactly when you are about to forget them.

## 🔗 Data Sources & Technologies
This app seamlessly integrates multiple APIs and SDKs to provide a rich learning experience:
- **KanjiAPI.dev**: Serves as the core database for Kanji metadata, JLPT character lists, readings (On'yomi & Kun'yomi), and English meanings.
- **Google Translate API**: Used internally to translate English meanings into Indonesian (Bahasa Indonesia) on-the-fly, allowing dual-language support.
- **Google ML Kit (Digital Ink Recognition)**: Powers the "Writing Quiz" by accurately recognizing hand-drawn Kanji strokes directly on the device screen.
- **KanjiVG (via SVG)**: Provides beautiful, animated stroke-order guides for Kanji characters to help users learn proper handwriting techniques.
- **Drift (SQLite)**: Ensures an offline-first architecture by aggressively caching Kanji details, Vocab lists, and user progress.

## ✨ Key Features & Recent Updates

### 🧠 Smart Learning & SRS
- **Spaced Repetition System**: Automatically calculates the next review interval based on your correct/wrong answers (incorporating an "Ease" factor).
- **Comprehensive Quizzes**: Test your knowledge across 3 dimensions:
  - **Meaning Quiz**: Guess the meaning of a Kanji/Vocab.
  - **Reading Quiz**: Guess the pronunciation (On'yomi/Kun'yomi).
  - **Writing Quiz**: Draw the Kanji on a digital canvas and have it evaluated by AI.

### 🎨 User Experience (UX) Enhancements
- **Semantic & Phonetic Hints**: Stuck on a quiz? Tap the "Show Hint" bulb icon! Meaning quizzes will hint the Reading, and Reading quizzes will hint the Meaning.
- **"I don't know / Skip" Option**: Prevents the SRS algorithm from being ruined by lucky guesses. If you don't know, skip it, learn from the revealed answer, and try again later.
- **Responsive & Unified Typography**: Employs dynamic scaling (`FittedBox`) to ensure long vocabulary words look just as stunning and readable as single Kanji characters.

### ⚙️ Intelligent Logic Under the Hood
- **Contextual Readings**: Automatically formats On'yomi readings into Hiragana during quizzes to prevent beginner confusion, while combining both On'yomi and Kun'yomi as a unified primary reading reference.
- **Smart Distractors**: Multiple-choice options are no longer generic "Wrong 1" texts. The app intelligently pulls random distractors from real cached Japanese/Indonesian vocabulary pools.
- **Robust Quiz Generator**: Dynamically adjusts to your learned pool size. Even if you've only learned 3 Kanji, the quiz generator will gracefully adapt instead of crashing.
- **Offline-First Resilience**: Smart caching ensures that once you've learned a Kanji, you can review it entirely offline without needing to re-fetch data.

---

*Developed with Flutter & Riverpod. Ready to conquer the JLPT!*
