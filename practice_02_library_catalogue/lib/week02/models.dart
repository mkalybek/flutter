// Level 1 + Level 2: the domain model.

class Author {
  const Author({required this.name, this.country});

  final String name;
  final String? country; // nullable: the starter data sometimes omits it

  @override
  String toString() => '$name (${country ?? 'unknown country'})';
}

enum Genre {
  craft('Craft'),
  theory('Theory'),
  unknown('Unknown');

  const Genre(this.label);

  final String label;

  /// Anything unexpected, including null, becomes [Genre.unknown].
  static Genre fromString(String? raw) =>
      values.firstWhere((g) => g.name == raw, orElse: () => unknown);
}

/// extends — "this is a kind of".
abstract class LibraryItem {
  const LibraryItem({required this.title, required this.year});

  final String title;
  final int year;

  String describe();

  bool get isOld => DateTime.now().year - year > 20;
}

/// with — "this can also do". `on LibraryItem` lets it read [title].
mixin Borrowable on LibraryItem {
  String borrowLabel() => 'Borrow "$title"';
}

class Book extends LibraryItem with Borrowable {
  const Book({
    required super.title,
    required super.year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  });

  /// The only place `dynamic` is allowed. Missing keys get their defaults
  /// here, so no caller ever has to deal with an incomplete map.
  factory Book.fromJson(Map<String, dynamic> json) => Book(
    title: json['title'] as String? ?? 'Untitled',
    year: json['year'] as int? ?? 0,
    pages: json['pages'] as int? ?? 0,
    author: Author(
      name: json['author'] as String? ?? 'Unknown',
      country: json['country'] as String?,
    ),
    genre: Genre.fromString(json['genre'] as String?),
    description: json['description'] as String?,
  );

  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  bool get isLong => pages > 400;

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  }) => Book(
    title: title ?? this.title,
    year: year ?? this.year,
    pages: pages ?? this.pages,
    author: author ?? this.author,
    genre: genre ?? this.genre,
    description: description ?? this.description,
  );

  @override
  String describe() => '$title by ${author.name}, $year, $pages pages';

  @override
  String toString() =>
      'Book($title, $year, $pages p., $author, ${genre.label}'
      '${description == null ? '' : ', "$description"'})';
}

class Magazine extends LibraryItem {
  const Magazine({
    required super.title,
    required super.year,
    required this.issue,
  });

  final int issue;

  @override
  String describe() => '$title #$issue ($year)';
}

/// implements — "this behaves like". Nothing is inherited: every member of
/// LibraryItem, fields included, is written here by hand.
class Ghost implements LibraryItem {
  const Ghost({required this.title, required this.year});

  @override
  final String title;

  @override
  final int year;

  @override
  String describe() => 'Ghost: "$title" is in the index but not on the shelf';

  @override
  bool get isOld => false;
}
