import 'package:equatable/equatable.dart';

class Sentence extends Equatable {
  final String japanese;
  final String english;
  final String indonesian;
  final String romaji;

  const Sentence({
    required this.japanese,
    required this.english,
    required this.indonesian,
    this.romaji = '',
  });

  String get hiragana {
    if (romaji.isEmpty) return '';
    final map = {
      'kya': 'きゃ', 'kyu': 'きゅ', 'kyo': 'きょ',
      'sha': 'しゃ', 'shu': 'しゅ', 'sho': 'しょ',
      'cha': 'ちゃ', 'chu': 'ちゅ', 'cho': 'ちょ',
      'nya': 'にゃ', 'nyu': 'にゅ', 'nyo': 'にょ',
      'hya': 'ひゃ', 'hyu': 'ひゅ', 'hyo': 'ひょ',
      'mya': 'みゃ', 'myu': 'みゅ', 'myo': 'みょ',
      'rya': 'りゃ', 'ryu': 'りゅ', 'ryo': 'りょ',
      'gya': 'ぎゃ', 'gyu': 'ぎゅ', 'gyo': 'ぎょ',
      'ja': 'じゃ', 'ju': 'じゅ', 'jo': 'じょ',
      'bya': 'びゃ', 'byu': 'びゅ', 'byo': 'びょ',
      'pya': 'ぴゃ', 'pyu': 'ぴゅ', 'pyo': 'ぴょ',
      'ka': 'か', 'ki': 'き', 'ku': 'く', 'ke': 'け', 'ko': 'こ',
      'sa': 'さ', 'shi': 'し', 'su': 'す', 'se': 'せ', 'so': 'そ',
      'ta': 'た', 'chi': 'ち', 'tsu': 'つ', 'te': 'て', 'to': 'と',
      'na': 'な', 'ni': 'に', 'nu': 'ぬ', 'ne': 'ね', 'no': 'の',
      'ha': 'は', 'hi': 'ひ', 'fu': 'ふ', 'he': 'へ', 'ho': 'ほ',
      'ma': 'ま', 'mi': 'み', 'mu': 'む', 'me': 'め', 'mo': 'も',
      'ya': 'や', 'yu': 'ゆ', 'yo': 'よ',
      'ra': 'ら', 'ri': 'り', 'ru': 'る', 're': 'れ', 'ro': 'ろ',
      'wa': 'わ', 'wo': 'を', 'nn': 'ん', 'n ': 'ん ', 'n': 'ん',
      'ga': 'が', 'gi': 'ぎ', 'gu': 'ぐ', 'ge': 'げ', 'go': 'ご',
      'za': 'ざ', 'ji': 'じ', 'zu': 'ず', 'ze': 'ぜ', 'zo': 'ぞ',
      'da': 'だ', 'de': 'で', 'do': 'ど',
      'ba': 'ば', 'bi': 'び', 'bu': 'ぶ', 'be': 'べ', 'bo': 'ぼ',
      'pa': 'ぱ', 'pi': 'ぴ', 'pu': 'ぷ', 'pe': 'ぺ', 'po': 'ぽ',
      'a': 'あ', 'i': 'い', 'u': 'う', 'e': 'え', 'o': 'お',
      '-': 'ー',
    };
    String result = romaji.toLowerCase();
    
    // Normalize macrons (long vowels) used by Google Translate
    result = result.replaceAll('ā', 'aa')
                   .replaceAll('ī', 'ii')
                   .replaceAll('ū', 'uu')
                   .replaceAll('ē', 'ee')
                   .replaceAll('ō', 'ou');
                   
    // Remove punctuation that shouldn't be converted
    result = result.replaceAll(RegExp(r'[.?!,]'), ' ');
                   
    result = result.replaceAllMapped(RegExp(r'([bcdfghjklmpqrstvwxyz])\1'), (m) => 'っ${m.group(1)}');
    map.forEach((k, v) {
      result = result.replaceAll(k, v);
    });
    return result;
  }

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
      japanese: json['japanese'] as String? ?? '',
      english: json['english'] as String? ?? '',
      indonesian: json['indonesian'] as String? ?? '',
      romaji: json['romaji'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'japanese': japanese,
      'english': english,
      'indonesian': indonesian,
      'romaji': romaji,
    };
  }

  @override
  List<Object?> get props => [japanese, english, indonesian, romaji];
}
