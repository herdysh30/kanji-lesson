# Kanji Lesson 🇯🇵

A modern, beautifully designed offline-first Flutter application to help users master Japanese Kanji, Vocabulary, and Sentences through a smart Spaced Repetition System (SRS) and interactive quizzes.

## 📱 What is this app?
**Kanji Lesson** is a comprehensive Japanese learning companion designed to go beyond passive reading. It enforces active recall through Meaning, Reading, Writing, and Sentence quizzes. The app seamlessly tracks your learning progress, mastery, streaks, and schedules reviews when you need them most, ensuring long-term retention. 

## 🔗 Data Sources & Technologies
This app integrates multiple APIs and robust local architecture to provide a rich, offline-capable learning experience:

- **KanjiAPI.dev** ([github.com/onlyskin/kanjiapi.dev](https://github.com/onlyskin/kanjiapi.dev)): Serves as the core database for Kanji metadata, JLPT character lists, readings (On'yomi & Kun'yomi), and English meanings.
- **JLPT Vocab API** ([github.com/wkei/jlpt-vocab-api](https://github.com/wkei/jlpt-vocab-api)): Provides comprehensive JLPT vocabulary lists along with readings and meanings.
- **Tatoeba API** ([tatoeba.org](https://tatoeba.org)): Used to fetch real-world Japanese example sentences for Kanji and Vocabulary contextual learning.
- **Google Translate API**: Used internally to translate English meanings into Indonesian (Bahasa Indonesia) on-the-fly, allowing native dual-language support, and generating Romaji for Sentences.
- **Google ML Kit (Digital Ink Recognition)**: Powers the "Writing Quiz" by accurately recognizing hand-drawn Kanji strokes directly on the device screen.
- **Flutter TTS (Text-to-Speech)**: Synthesizes high-quality native Japanese audio for Kanji, Vocab, and Sentences to train listening skills.
- **KanjiVG (via SVG)**: Provides beautiful, animated stroke-order guides for Kanji characters to help users learn proper handwriting techniques.
- **Drift (SQLite)**: Ensures an offline-first architecture by aggressively caching Kanji details, Vocab lists, Sentences, and detailed user progress histories.
- **Riverpod**: Used for reactive, predictable, and scalable state management across the app.

## ✨ Main Features

### 🎓 Curriculum & Learning
- **JLPT-Based Breakdown**: Organized progression from JLPT N5 (Beginner) to N1 (Advanced) with clear mastery percentages.
- **Detailed Dictionary**: Explore Kanji details including On'yomi, Kun'yomi, Stroke Orders, Meanings, and Example Sentences.
- **Dual Language Support**: Study meanings in both English and Indonesian natively across the entire app.

### 🧠 Smart Quizzes & SRS
- **Meaning Quiz**: Test your knowledge of what a Kanji or Vocabulary word means.
- **Reading Quiz**: Test your pronunciation via multiple-choice options.
- **Writing Quiz**: Draw Kanji directly on the screen and have an AI check your stroke accuracy.
- **Sentence Quiz**: Read real Japanese sentences and identify the meaning/reading of specific Kanji in context.
- **Penalty-Aware Hints**: Use semantic hints (revealing readings or romaji) to avoid getting stuck, which factor into your mastery progress.

### 📊 Progress Tracking & Gamification
- **Dashboard Analytics**: Track your Daily Goals, Weak Kanji, and recently Learned items.
- **Calendar & Streaks**: Visualize your learning consistency with an interactive monthly calendar and streak counter.
- **Weekly Activity Chart**: A beautiful bar chart tracking the number of reviews and items learned over the past week.
- **Quiz History & Retakes**: Review detailed logs of your past quizzes (correct/incorrect answers) and easily retake specific quiz sessions to score 100%.
- **Spaced Repetition System (SRS)**: The app remembers what you struggle with and schedules weak items automatically.

### 🎨 Beautiful UI/UX
- **Modern Aesthetics**: Built with premium UI design, glassmorphism elements, dynamic color themes, and smooth micro-animations.

---

*Developed with Flutter & Riverpod. Ready to conquer the JLPT!*
