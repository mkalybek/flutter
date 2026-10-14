# Practice 2 — Library Catalogue (pure Dart)

```sh
dart pub get
dart run lib/week02/main.dart   # prints the report
dart analyze                    # No issues found!
```

| File | Level |
|------|-------|
| `lib/week02/data.dart` | starter data (copied as given) |
| `lib/week02/models.dart` | L1 `Author`, `Genre`, `Book` · L2 `LibraryItem`, `Magazine`, `Borrowable`, `Ghost` |
| `lib/week02/catalogue.dart` | L3 `Library` (null safety) · L4 one-expression queries + display list |
| `lib/week02/shelf_state.dart` | L5 sealed `ShelfState`, `describe`, `statsOf` record |
| `lib/week02/main.dart` | wires it up |
