# Kanji Lesson 🇯🇵

Aplikasi Flutter belajar JLPT Kanji — offline-first, SRS-based, dengan kuis interaktif.

---

## 📋 Deskripsi

**Kanji Lesson** adalah aplikasi belajar bahasa Jepang komprehensif yang fokus pada penguasaan Kanji, Vocabulary, dan Sentences melalui active recall. Aplikasi ini menggunakan Spaced Repetition System (SRS) dan kuis interaktif untuk memastikan retensi jangka panjang. Dibangun dengan arsitektur offline-first sehingga tetap bisa digunakan tanpa koneksi internet.

---

## ✨ Core Features

### 🎓 Curriculum & Learning
- **JLPT-Based Progression**: Organisasi materi dari N5 (Beginner) hingga N1 (Advanced) dengan persentase mastery per level
- **Kanji Dictionary**: Detail lengkap — On'yomi, Kun'yomi, Stroke Order, Meanings, Radical breakdown, Contoh Kalimat
- **Vocabulary Browser**: Jelajahi dan cari vocab JLPT N5–N1 dengan furigana
- **Global Search**: Pencarian terpadu Kanji + Vocabulary dari layar mana pun
- **Bookmarks**: Simpan Kanji favorit, akses instan dari layar bookmark
- **Dual Language Support**: Arti dalam Bahasa Inggris dan Indonesia

### 🧠 Smart Quizzes
- **Meaning Quiz**: Tebak arti Kanji/Vocab
- **Reading Quiz**: Tes pronunciation (pilihan ganda)
- **Writing Quiz**: Gambar Kanji di layar, dikoreksi AI via Google ML Kit Digital Ink Recognition
- **Sentence Quiz**: Baca kalimat Jepang asli (Tatoeba), identifikasi arti/reading Kanji dalam konteks
- **Penalty-Aware Hints**: Petunjuk (reading/romaji) tersedia tapi mempengaruhi mastery
- **Quiz History & Retakes**: Riwayat detail, bisa retake kuis tertentu

### 🧠 Spaced Repetition System (SRS)
- **SM-2 Algorithm**: Implementasi Simplified SM-2
- **4 Rating Levels**: Again (reset), Hard, Good, Easy
- **Status Progression**: unseen → learning → reviewing → mastered
- **Auto-Scheduling**: Jadwal review otomatis berdasarkan performa
- **SRS Transitions**: Tracking detail status per kartu

### 📊 Progress Tracking & Gamification
- **Dashboard Analytics**: Daily Goals, Weak Kanji, Recently Learned
- **Calendar & Streaks**: Kalender interaktif + streak counter
- **Weekly Activity Chart**: Bar chart jumlah review/item learned per hari
- **Progress Summary**: Total learned, mastered, reviewing, correct/wrong counts
- **Weak Kanji Detection**: Sortir otomatis item dengan akurasi terendah

### ☁️ Cloud Sync (Firebase)
- **Firestore Sync**: Progress, daily, dan quiz history tersinkron ke cloud
- **Delta Sync**: Hanya upload row yang berubah sejak sinkron terakhir
- **Two-Way Sync**: Download dari cloud + upload lokal, last-write-wins
- **Batch Commit**: Chunk 450 ops per batch (limit Firestore 500)
- **Debounced Auto-Sync**: Otomatis 800ms setelah perubahan lokal

### 🔔 Additional
- **Daily Notifications**: Pengingat belajar via flutter_local_notifications
- **Android Home Widget**: Kanji of the Day, rotasi otomatis tiap hari
- **Accent Color Customization**: Pilih warna aksen tema
- **Dark/Light Mode**: Toggle tema
- **Locale Switching**: EN/ID

---

## 🏗️ Spesifikasi Teknis

### Arsitektur
- **Pattern**: Clean Architecture (data / domain / presentation)
- **State Management**: Riverpod (flutter_riverpod + riverpod_annotation)
- **Navigation**: go_router + StatefulShellRoute (bottom nav)
- **Database**: drift (SQLite) — offline-first
- **API Client**: dio
- **Code Generation**: build_runner, drift_dev, riverpod_generator

### Struktur Proyek

```
lib/
├── main.dart
├── app.dart
├── firebase_options.dart
├── l10n/                          # Lokalisasi (ARB)
├── core/
│   ├── constants/                 # api_constants, app_constants, srs_constants
│   ├── database/                  # app_database.dart (7 tables)
│   │   └── tables/                # jlpt_vocab_entries.dart
│   ├── network/                   # dio_client, app_exception
│   ├── router/                    # app_router.dart
│   ├── services/                  # notification, translation, kanjivg, mlkit, widget
│   ├── theme/                     # app_colors, app_theme
│   ├── utils/                     # date_utils, dll
│   └── widgets/                   # shared widgets
└── features/
    ├── auth/                      # Login, Google Sign-In
    ├── home/                      # Dashboard, Widget UI
    ├── kanji/                     # JLPT Selection, List, Detail, Vocab, Search, Bookmark, Writing
    ├── progress/                  # Progress Screen, Weak Kanji, Quiz History
    ├── quiz/                      # Setup, Session, Result
    ├── review/                    # SRS Review, Session, Result
    ├── settings/                  # Theme, Locale, Accent, Account, Sync
    ├── splash/                    # Splash Screen
    └── sync/                      # Cloud Firestore Sync Service
```

### Database Tables (7)
| Table | Primary Key | Description |
|---|---|---|
| `KanjiEntries` | character | Cache Kanji dari KanjiAPI |
| `VocabularyEntries` | id (auto) | Cache vocabulary per Kanji |
| `UserKanjiProgressEntries` | kanjiCharacter | Progress belajar user per item |
| `DailyProgressEntries` | date | Progress harian (yyyy-MM-dd) |
| `QuizResultEntries` | id (auto) | Riwayat kuis |
| `SimilarKanjiEntries` | id (auto) | Relasi Kanji mirip |
| `JlptVocabEntries` | — | Vocab JLPT dari API eksternal |

### Screens (22+)

| Route | Screen | Description |
|---|---|---|
| `/splash` | SplashScreen | Splash + init |
| `/login` | LoginScreen | Email/Google sign-in |
| `/` | HomeScreen | Dashboard, stats, widget |
| `/learn` | JlptSelectionScreen | Pilih level N5–N1 |
| `/learn/:level` | KanjiListScreen | Daftar Kanji per level |
| `/learn/:level/:kanji` | KanjiDetailScreen | Detail Kanji + stroke order |
| `/learn/:level/practice` | WritingPracticeScreen | Latihan menulis |
| `/learn/:level/vocab/:word` | VocabDetailScreen | Detail vocabulary |
| `/review` | ReviewScreen | Daftar review SRS |
| `/review/session` | ReviewSessionScreen | Sesi review |
| `/review/result` | ReviewResultScreen | Hasil review |
| `/quiz` | QuizSetupScreen | Setup tipe kuis |
| `/quiz/session` | QuizScreen | Sesi kuis |
| `/quiz/result` | QuizResultScreen | Hasil kuis |
| `/progress` | ProgressScreen | Dashboard progress |
| `/progress/weak` | WeakKanjiScreen | Kanji lemah |
| `/progress/quiz-history` | QuizHistoryScreen | Riwayat kuis |
| `/progress/quiz-history-detail` | QuizHistoryDetailScreen | Detail kuis |
| `/search` | GlobalSearchScreen | Pencarian global |
| `/bookmarks` | BookmarkScreen | Kanji tersimpan |
| `/vocab` | VocabularyBrowserScreen | Browser vocab |
| `/settings` | SettingsScreen | Pengaturan |

### SRS Engine (SM-2 Simplified)
| Rating | Ease Change | Interval | Repetitions |
|---|---|---|---|
| Again | -0.20 | 1 menit | Reset ke 0 |
| Hard | -0.15 | 1 hari (atau ×1.2) | +1 |
| Good | 0 | 1 hari (atau ×ease) | +1 |
| Easy | +0.15 | 4 hari (atau ×ease×1.3) | +1 |

**Status threshold**: mastered jika interval ≥ 21 hari, akurasi ≥ 85%, repetisi ≥ 3.

---

## 🛠️ Tech Stack

### Framework & Language
- **Flutter** (SDK ^3.8.0)
- **Dart** (^3.8.0)

### State Management
| Package | Version | Penggunaan |
|---|---|---|
| flutter_riverpod | ^2.6.1 | State management reaktif |
| riverpod_annotation | ^2.6.1 | Code generation Riverpod |

### Navigation
| Package | Version | Penggunaan |
|---|---|---|
| go_router | ^14.8.1 | Routing + bottom nav shell |

### Networking
| Package | Version | Penggunaan |
|---|---|---|
| dio | ^5.7.0 | HTTP client |
| flutter_dotenv | ^6.0.1 | Environment variables |

### Local Database
| Package | Version | Penggunaan |
|---|---|---|
| drift | ^2.23.1 | ORM SQLite |
| drift_flutter | ^0.2.4 | Flutter adapter drift |
| sqlite3_flutter_libs | ^0.5.28 | Native SQLite |
| path_provider | ^2.1.5 | Path penyimpanan |

### Storage
| Package | Version | Penggunaan |
|---|---|---|
| shared_preferences | ^2.3.4 | Key-value storage |
| flutter_secure_storage | ^9.2.4 | Secure storage (token) |

### UI
| Package | Version | Penggunaan |
|---|---|---|
| google_fonts | ^6.2.1 | Typography |
| flutter_svg | ^2.3.0 | SVG rendering (KanjiVG) |
| fl_chart | ^0.70.2 | Chart (weekly activity) |
| curved_navigation_bar | ^1.0.6 | Bottom navigation curved |

### Multimedia & TTS
| Package | Version | Penggunaan |
|---|---|---|
| flutter_tts | ^4.2.0 | Text-to-Speech Jepang |
| stroke_order_animator | ^3.3.1 | Animasi stroke order |
| video_player | ^2.11.1 | Video assets |
| just_audio | ^0.10.6 | Audio playback |

### Machine Learning
| Package | Version | Penggunaan |
|---|---|---|
| google_mlkit_digital_ink_recognition | ^0.14.2 | Recognisi tulisan tangan Kanji |

### Firebase
| Package | Version | Penggunaan |
|---|---|---|
| firebase_core | ^4.14.0 | Firebase initialization |
| firebase_auth | ^6.6.0 | Authentication |
| cloud_firestore | ^6.9.0 | Cloud sync |
| google_sign_in | ^6.3.0 | Google Sign-In |

### Notifications & Scheduling
| Package | Version | Penggunaan |
|---|---|---|
| flutter_local_notifications | ^22.3.0 | Notifikasi lokal |
| table_calendar | ^3.2.1 | Kalender streak |
| timezone | ^0.11.1 | Timezone data |
| flutter_timezone | ^5.1.0 | Deteksi timezone |

### Widget
| Package | Version | Penggunaan |
|---|---|---|
| home_widget | ^0.9.3 | Android Home Screen Widget |

### Internationalization
| Package | Version | Penggunaan |
|---|---|---|
| intl | 0.20.2 | Lokalisasi (EN/ID) |
| Flutter l10n | — | ARB-based localization |

### Utilities
| Package | Version | Penggunaan |
|---|---|---|
| equatable | ^2.0.7 | Value equality |
| collection | ^1.19.1 | Collection utilities |

### Data Sources (External APIs)
| API | Penggunaan |
|---|---|
| [KanjiAPI.dev](https://github.com/onlyskin/kanjiapi.dev) | Data Kanji, JLPT, readings, meanings |
| [KanjiAlive API](https://kanjialive.com) | Radical breakdown data |
| [JLPT Vocab API](https://github.com/wkei/jlpt-vocab-api) | Daftar vocabulary JLPT |
| [Tatoeba API](https://tatoeba.org) | Contoh kalimat bahasa Jepang |
| Google Translate API | Terjemahan EN→ID, generate Romaji |
| Google ML Kit | Digital Ink Recognition (writing quiz) |
| KanjiVG (SVG) | Stroke order animation |

### Dev Tools
| Package | Version | Penggunaan |
|---|---|---|
| flutter_test | — | Unit testing |
| flutter_lints | ^5.0.0 | Linting |
| build_runner | ^2.4.14 | Code generation |
| drift_dev | ^2.23.1 | Drift generator |
| riverpod_generator | ^2.6.3 | Riverpod generator |
| flutter_launcher_icons | ^0.14.3 | App icon |

---

## 🔗 Links

- **Repository**: [herdysh30/kanji-lesson](file:///d:/Project/KanjiLesson)
- **Platform**: Android (iOS via build)
- **Min SDK**: Flutter ^3.8.0 / Dart ^3.8.0
