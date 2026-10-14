// Temporary screenshot harness (deleted after use): real fonts + phone size.
import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _fonts = '/opt/homebrew/share/flutter/bin/cache/artifacts/material_fonts';

Future<ByteData> _file(String path) async =>
    ByteData.sublistView(File(path).readAsBytesSync());

Future<void> loadFonts([Map<String, String> extra = const {}]) async {
  final roboto = FontLoader('Roboto');
  for (final w in ['Regular', 'Medium', 'Bold']) {
    roboto.addFont(_file('$_fonts/Roboto-$w.ttf'));
  }
  await roboto.load();
  await (FontLoader('MaterialIcons')
        ..addFont(_file('$_fonts/MaterialIcons-Regular.otf')))
      .load();
  for (final e in extra.entries) {
    await (FontLoader(e.key)..addFont(_file(e.value))).load();
  }
}

void phone(WidgetTester t, {Brightness brightness = Brightness.light}) {
  t.view.physicalSize = const Size(1080, 2340);
  t.view.devicePixelRatio = 3;
  t.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(() {
    t.view.reset();
    t.platformDispatcher.clearPlatformBrightnessTestValue();
  });
}
