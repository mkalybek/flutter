import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final library = Library()..open();
  for (final json in rawBooks) {
    library.add(Book.fromJson(json));
  }
  library
    ..add(const Magazine(title: 'Flutter Weekly', year: 2025, issue: 42))
    ..add(const Ghost(title: 'The Missing Manual', year: 2001));

  print('Opened at: ${library.openedAt}');
  print('');
  for (final item in library.items) {
    print(item.describe());
  }

  print('\n--- Levels 1-3 ---');
  final clean = library.findByTitle('Clean Code');
  print(clean);
  print(clean?.borrowLabel());
  print('Is long: ${clean?.isLong}, is old: ${clean?.isOld}');
  print(clean?.copyWith(title: 'Clean Code, 2nd ed.', year: 2025));
  print('Not found: ${library.findByTitle('Nope')}');
  print('Country of Design Patterns: ${library.countryOf('Design Patterns')}');
  print('Country of Refactoring: ${library.countryOf('Refactoring')}');
  print('Country of Nope: ${library.countryOf('Nope')}');

  print('\n--- Level 4 ---');
  print('Titles: ${library.titles}');
  print('After 2010: ${library.booksAfter2010.map((b) => b.title)}');
  print('Average pages: ${library.averagePages.toStringAsFixed(1)}');
  print('Books per author: ${library.booksPerAuthor}');
  print('Authors: ${library.authorNames}');
  print('Genres: ${library.genres.map((g) => g.label)}');
  print('');
  print(library.report());

  print('\n--- Level 5 ---');
  final (:count, :avgPages) = statsOf(library.books);
  print('statsOf: count=$count, avgPages=${avgPages.toStringAsFixed(1)}');
  for (final state in [
    const Empty(),
    Ready(library.books),
    const Broken('shelf collapsed'),
  ]) {
    print(describe(state));
  }
}
