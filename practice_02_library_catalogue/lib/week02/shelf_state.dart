// Level 5: Dart 3 — sealed classes, patterns, records.
import 'models.dart';

sealed class ShelfState {
  const ShelfState();
}

final class Empty extends ShelfState {
  const Empty();
}

final class Ready extends ShelfState {
  const Ready(this.books);
  final List<Book> books;
}

final class Broken extends ShelfState {
  const Broken(this.message);
  final String message;
}

/// No default: add a fourth subtype and the compiler lists this switch.
String describe(ShelfState state) => switch (state) {
  Empty() => 'The shelf is empty',
  Ready(:final books) => 'Ready with ${books.length} books',
  Broken(:final message) => 'Broken: $message',
};

({int count, double avgPages}) statsOf(List<Book> books) => (
  count: books.length,
  avgPages: books.isEmpty
      ? 0
      : books.fold<int>(0, (sum, b) => sum + b.pages) / books.length,
);
