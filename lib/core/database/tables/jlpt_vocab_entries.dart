import 'package:drift/drift.dart';

@DataClassName('JlptVocabEntry')
class JlptVocabEntries extends Table {
  TextColumn get word => text()();
  TextColumn get meaning => text()();
  TextColumn get meaningId => text().nullable()();
  TextColumn get furigana => text()();
  TextColumn get romaji => text()();
  IntColumn get level => integer()();
  
  @override
  Set<Column> get primaryKey => {word};
}
