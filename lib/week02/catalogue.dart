// Level 3 (null safety) + Level 4 (collections).
import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  /// Assigned in [open], not in the constructor.
  late final DateTime openedAt;

  String? _cachedReport;

  void add(LibraryItem item) {
    items.add(item);
    _cachedReport = null; // the report is stale now
  }

  void open() => openedAt = DateTime.now();

  /// null when there is none — never throws.
  Book? findByTitle(String title) =>
      books.where((b) => b.title == title).firstOrNull;

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  /// Built once, then served from the cache.
  String report() => _cachedReport ??= display.join('\n');

  // ---- Level 4: one expression each, no for loops ----

  List<Book> get books => items.whereType<Book>().toList();

  List<String> get titles => items.map((i) => i.title).toList();

  List<Book> get booksAfter2010 => books.where((b) => b.year > 2010).toList();

  // fold, not reduce: reduce must return the element type (Book), not an int,
  // and it throws on an empty list; fold starts from 0 and works on [].
  double get averagePages => books.isEmpty
      ? 0
      : books.fold<int>(0, (sum, b) => sum + b.pages) / books.length;

  Map<String, int> get booksPerAuthor => books.fold<Map<String, int>>(
    {},
    (counts, b) => {...counts, b.author.name: (counts[b.author.name] ?? 0) + 1},
  );

  Set<String> get authorNames => books.map((b) => b.author.name).toSet();

  Set<Genre> get genres => books.map((b) => b.genre).toSet();

  /// One literal: header, collection-for, spread, collection-if.
  List<String> get display => [
    'CATALOGUE',
    for (final b in books) '${b.title} (${b.year})',
    ...authorNames,
    if (books.any((b) => b.pages == 0)) '(incomplete data)',
  ];
}
