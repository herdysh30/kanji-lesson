# Kanji Lesson 🇯🇵

A modern, offline-first Flutter application designed to help users master Japanese Kanji and Vocabulary through a smart Spaced Repetition System (SRS) inspired by WaniKani and Anki.

## 📱 What is this app?
**Kanji Lesson** is a comprehensive Japanese learning companion that allows users to study Kanji characters and JLPT vocabulary. Instead of just passive reading, the app enforces active recall through multiple-choice quizzes (Meaning & Reading) and interactive drawing quizzes (Writing). It tracks your learning progress over time, scheduling reviews exactly when you are about to forget them.

## 🔗 Data Sources & Technologies
This app seamlessly integrates multiple APIs and SDKs to provide a rich learning experience:
- **KanjiAPI.dev** ([github.com/onlyskin/kanjiapi.dev](https://github.com/onlyskin/kanjiapi.dev)): Serves as the core database for Kanji metadata, JLPT character lists, readings (On'yomi & Kun'yomi), and English meanings.
- **JLPT Vocab API** ([github.com/wkei/jlpt-vocab-api](https://github.com/wkei/jlpt-vocab-api)): Provides comprehensive JLPT vocabulary lists along with readings and meanings.
- **Google Translate API**: Used internally to translate English meanings into Indonesian (Bahasa Indonesia) on-the-fly, allowing dual-language support.
- **Google ML Kit (Digital Ink Recognition)**: Powers the "Writing Quiz" by accurately recognizing hand-drawn Kanji strokes directly on the device screen.
- **KanjiVG (via SVG)**: Provides beautiful, animated stroke-order guides for Kanji characters to help users learn proper handwriting techniques.
- **Drift (SQLite)**: Ensures an offline-first architecture by aggressively caching Kanji details, Vocab lists, and user progress.

## ✨ Main Features

- **JLPT-Based Curriculum**: Organized progression from JLPT N5 (Beginner) to N1 (Advanced).
- **Spaced Repetition System (SRS)**: The app remembers what you struggle with and schedules reviews automatically using scientifically proven spaced repetition algorithms.
- **Interactive Quizzes**:
  - **Meaning Quiz**: Test your knowledge of what a Kanji or Vocabulary word means.
  - **Reading Quiz**: Test your pronunciation (On'yomi and Kun'yomi).
  - **Writing Quiz**: Draw Kanji directly on the screen and have an AI check your stroke accuracy.
- **Dual Language Support**: Study meanings in both English and Indonesian natively.
- **Smart Hints & Fallbacks**: Features like semantic hints (revealing readings for meaning quizzes) and skip buttons to keep the learning flow smooth.
- **Offline-First & Fast**: Everything you learn is cached locally in SQLite. Study anywhere, anytime, without an internet connection.
- **Detailed Progress Tracking**: Keep an eye on your daily goals, weak Kanji, and overall mastery percentages directly from the home screen.

---

*Developed with Flutter & Riverpod. Ready to conquer the JLPT!*
