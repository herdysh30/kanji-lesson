import 'package:equatable/equatable.dart';

class KanjiAliveData extends Equatable {
  final String character;
  final String englishMeaning;
  final String? romajiOnyomi;
  final String? romajiKunyomi;
  final String? videoMp4Url;
  final String? videoWebmUrl;
  final List<String> strokeImages;
  final KanjiAliveRadical? radical;
  final List<KanjiAliveExample> examples;

  const KanjiAliveData({
    required this.character,
    required this.englishMeaning,
    this.romajiOnyomi,
    this.romajiKunyomi,
    this.videoMp4Url,
    this.videoWebmUrl,
    this.strokeImages = const [],
    this.radical,
    this.examples = const [],
  });

  factory KanjiAliveData.fromJson(Map<String, dynamic> json) {
    final kanji = json['kanji'] as Map<String, dynamic>;
    final video = kanji['video'] as Map<String, dynamic>?;
    final strokes = kanji['strokes'] as Map<String, dynamic>?;
    
    final onyomi = kanji['onyomi'] as Map<String, dynamic>?;
    final kunyomi = kanji['kunyomi'] as Map<String, dynamic>?;

    final examplesList = json['examples'] as List?;

    return KanjiAliveData(
      character: kanji['character'] as String? ?? '',
      englishMeaning: (kanji['meaning'] as Map<String, dynamic>?)?['english'] as String? ?? '',
      romajiOnyomi: onyomi?['romaji'] as String?,
      romajiKunyomi: kunyomi?['romaji'] as String?,
      videoMp4Url: video?['mp4'] as String?,
      videoWebmUrl: video?['webm'] as String?,
      strokeImages: (strokes?['images'] as List?)?.map((e) => e as String).toList() ?? [],
      radical: json['radical'] != null 
          ? KanjiAliveRadical.fromJson(json['radical'] as Map<String, dynamic>)
          : null,
      examples: examplesList != null
          ? examplesList.map((e) => KanjiAliveExample.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }

  @override
  List<Object?> get props => [
        character,
        englishMeaning,
        romajiOnyomi,
        romajiKunyomi,
        videoMp4Url,
        videoWebmUrl,
        strokeImages,
        radical,
        examples,
      ];
}

class KanjiAliveRadical extends Equatable {
  final String character;
  final String image;
  final String hiraganaName;
  final String englishMeaning;

  const KanjiAliveRadical({
    required this.character,
    required this.image,
    required this.hiraganaName,
    required this.englishMeaning,
  });

  factory KanjiAliveRadical.fromJson(Map<String, dynamic> json) {
    return KanjiAliveRadical(
      character: json['character'] as String? ?? '',
      image: json['image'] as String? ?? '',
      hiraganaName: (json['name'] as Map<String, dynamic>?)?['hiragana'] as String? ?? '',
      englishMeaning: (json['meaning'] as Map<String, dynamic>?)?['english'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [character, image, hiraganaName, englishMeaning];
}

class KanjiAliveExample extends Equatable {
  final String japanese;
  final String englishMeaning;
  final String? audioMp3Url;

  const KanjiAliveExample({
    required this.japanese,
    required this.englishMeaning,
    this.audioMp3Url,
  });

  factory KanjiAliveExample.fromJson(Map<String, dynamic> json) {
    final audio = json['audio'] as Map<String, dynamic>?;
    return KanjiAliveExample(
      japanese: json['japanese'] as String? ?? '',
      englishMeaning: (json['meaning'] as Map<String, dynamic>?)?['english'] as String? ?? '',
      audioMp3Url: audio?['mp3'] as String?,
    );
  }

  @override
  List<Object?> get props => [japanese, englishMeaning, audioMp3Url];
}
