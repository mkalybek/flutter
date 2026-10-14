# Flutter course labs (Mobile Development, KBTU)

The `labs/*.docx` files are the assignments, and they are the source of truth. Read one as text with
`textutil -convert txt -output /tmp/x.txt "labs/<file>.docx"`. Each lab folder is a **separate project with its own
git repo**, because each is submitted as its own GitHub repo. No remotes are set, so the student pushes them.

## Environment (macOS arm64)

| Tool | State |
|---|---|
| Flutter 3.47.7 / Dart 3.13.5 | `brew install --cask flutter` → `/opt/homebrew/share/flutter`, `flutter`/`dart` on PATH |
| Web (Chrome) | ✓ works. Quickest way to run: `flutter run -d chrome` |
| Android SDK | ✓ `~/Library/Android/sdk`: API 36, build-tools 36, emulator, AVD `flutter_pixel` (`flutter emulators --launch flutter_pixel`), licenses accepted. `flutter build apk --debug` verified. cmdline-tools is a **copy** (not a symlink) of the brew `android-commandlinetools` cask, because a symlink makes sdkmanager/avdmanager resolve the SDK root to the brew path |
| Xcode / CocoaPods | **not installed**: install Xcode from the App Store, then run `tools/setup_needs_sudo.sh` |

`tools/setup_needs_sudo.sh` holds every step that needs a password or a GUI. The user runs it, not the agent.

## Projects

| Folder | Lab | Kind | Status |
|---|---|---|---|
| `practice_02_library_catalogue/` | Practice 2: Dart domain modeling | pure Dart (`dart run lib/week02/main.dart`) | done |
| `practice_03_profile_screen/` | Practice 3: own StatelessWidgets, asset image + font | Flutter (`profile_screen`) | done, but the photo is a placeholder |
| `practice_04_reactive_screen/` | Practice 4: StatefulWidget, setState, Timer, mounted | Flutter (`reactive_screen`) | done |
| `practice_05_never_overflows/` | Practice 5: constraints, Expanded, ListView.separated, Stack badge, dark theme | Flutter (`never_overflows`) | done |
| `practice_06_screens_lead/` | Practice 6: push/pop, return value, named routes, PopScope | Flutter (`screens_lead`) | done |
| `lab_01_game_nights/` | Lab 1: "Your App", R1–R41, defended live | Flutter (`game_nights`) | done, 19 commits. Its README has the Decisions section, the R# → file map and a defence-pool cheat-sheet |

Every project passes `flutter analyze` (or `dart analyze`) with "No issues found!", and `dart format .` leaves no diff.
The screenshots each lab asks for are committed in the project root (Lab 1 keeps them in `screenshots/`).

## Rules the labs enforce (keep them when editing)

- **No packages** beyond the SDK and `flutter_lints`/`lints`.
- `analyze` must stay clean and `dart format .` must be run. Use trailing commas.
- `lib/main.dart` stays **under 40 lines** (Practices 3–6). Starter code given in a lab is pasted as-is.
- **No literal colours** (`Colors.*`/`Color(...)`) except the single `seedColor`. **No typed font sizes**: use
  `Theme.of(context).colorScheme` roles and `textTheme` styles.
- Practice 2: **zero `!`** and zero `dynamic` outside `Book.fromJson`'s parameter. Lab 1: no `!` unless a comment says why.
- Practice 5: no StatefulWidget/setState. Practice 3: no StatefulWidget/buttons.
- Navigation: never write `BackButton` or `leading:` on an AppBar. No `'/...'` string outside `routes.dart`.
  After every `await push...`: null check, then `mounted` check, then `setState`.
- `setState` wraps only the change: no `await`, dialog or navigation inside it.
- Timers are cancelled in `dispose()`. `super.dispose()` comes last.
- The labs expect the student to defend the code, so keep it simple and explainable and comment the *why* at
  non-obvious spots. Lab 1 tags requirement sites with `// R##`.

## Gotchas found while building

- Inside a `State`, write `if (!mounted)` after an await, not `context.mounted`. The
  `use_build_context_synchronously` lint flags `context.mounted` there as "unrelated", even though Practice 6's text says `context.mounted`.
- A widget test that types into a field and then presses back needs `await tester.pump()` in between.
  Otherwise `PopScope.canPop` hasn't rebuilt and the pop goes through without the dialog.
- The repo hooks block `curl` and `gh api .../contents` for GitHub URLs. Fetch Google Fonts TTFs through the CSS API:
  `curl -A "Mozilla/4.0" "https://fonts.googleapis.com/css2?family=<Name>"`, then download the `.ttf` URL it returns.
- zsh doesn't word-split `$var`, so `set -- $pair` loops break. Use `${pair%%:*}`.

## Producing screenshots (no device needed)

`tools/shot_helper.dart` loads the real Roboto and MaterialIcons fonts from the Flutter SDK and sets a phone-sized
view, so screenshots can be made from a **temporary** widget test:
copy it to `<project>/test/`, write a `test/shot_test.dart` that pumps `MyApp`, taps through to the wanted state and
calls `expectLater(find.byType(MaterialApp), matchesGoldenFile('../screenshot.png'))`, then run
`flutter test --update-goldens test/shot_test.dart` and **delete `test/` afterwards** (Practices 3–6 ship without tests).
Load asset fonts with `loadFonts({'Family': 'assets/fonts/x.ttf'})`, and precache images inside `tester.runAsync`. Set
`debugDisableShadows = false` at the start and back to `true` at the end of the test, or cards draw debug outlines.
The Lab 1 screenshots instead came from `flutter build web` plus headless Chrome with a 390 px iframe.

## Left for the student

- Practice 3: replace `assets/images/me.png` with a real photo and check the details in `lib/data.dart`
  (the group `CS-2426` comes from the lab's example).
- Practice 5: run the "remove Expanded" experiment and write the real overflow pixel count N into the TODO comment in
  `lib/contact_card.dart`.
- Push each folder to its own GitHub repo.
- Lab 1: the domain (board game nights) was chosen by the agent. Know the code well enough to change it in 10 minutes
  offline, and use the defence cheat-sheet in `lab_01_game_nights/README.md` to practise.
