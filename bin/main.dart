// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:loc_generator/src/models/names.dart';
import 'package:loc_generator/src/utils/exceptions.dart';
import 'package:loc_generator/src/utils/generate_constants.dart';
import 'package:watcher/watcher.dart';

/// LOC Generator - Main entry point
///
/// Generates localization files and type-safe constants for Flutter applications.
/// Watches for file changes and automatically regenerates code.
///
/// Usage:
/// ```bash
/// dart run loc_generator:main --lang_path assets/lang/lang.json --ar_path assets/lang/ar.json --en_path assets/en.json
/// ```
///
/// Command line arguments:
/// - `--lang_path` (`-f`): Path to master language file (contains key-value pairs)
/// - `--ar_path` (`-a`): Path to Arabic translation output file
/// - `--en_path` (`-l`): Path to English translation output file
void main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption(
    'lang_path',
    abbr: 'f',
    help: 'Path to master language file (lang.json)',
  );
  parser.addOption(
    'ar_path',
    abbr: 'a',
    help: 'Path to Arabic translation output file',
  );
  parser.addOption(
    'en_path',
    abbr: 'l',
    help: 'Path to English translation output file',
  );

  final ArgResults argResults = parser.parse(arguments);
  final String filePath = argResults['lang_path'];
  final String arPath = argResults['ar_path'];
  final String enPath = argResults['en_path'];

  final File file = File(filePath);

  final FileWatcher watcher = FileWatcher(filePath);
  final String previousContent = file.readAsStringSync();
  watcher.events.listen((WatchEvent event) {
    if (event.type == ChangeType.MODIFY) {
      print('File changed: ${watcher.path}');
      handleFileChange(file, previousContent, enPath: enPath, arPath: arPath);
    }
  });
  final Map<String, dynamic> jsonMap = json.decode(previousContent);
  final Map<String, dynamic> jsonEnMap = await generateJsonTranslate(
    lang: 'en',
    jsonMap: jsonMap,
    path: enPath,
  );
  await generateJsonTranslate(lang: 'ar', jsonMap: jsonMap, path: arPath);
  await generateAppStrings(jsonEnMap);
  print('Watching for changes in: ${watcher.path}');
}

/// Handles file change events from the file watcher.
///
/// Compares the current file content with previous content,
/// shows a detailed diff, and triggers regeneration of all
/// translation files and Dart constants.
///
/// Parameters:
/// - [file]: The file that was modified
/// - [previousContent]: Content before the change
/// - [enPath]: Path to English translation file
/// - [arPath]: Path to Arabic translation file
void handleFileChange(
  File file,
  String previousContent, {
  required String enPath,
  required String arPath,
}) async {
  try {
    final String currentContent = file.readAsStringSync();
    final List<String> currentLines = currentContent.split('\n');
    final List<String> previousLines = previousContent.split('\n');

    for (int i = 0; i < currentLines.length; i++) {
      if (i >= previousLines.length || currentLines[i] != previousLines[i]) {
        print('Line ${i + 1} changed');
        print(
          'Previous: ${(i) >= previousLines.length ? 'null' : previousLines[i]}',
        );
        print('Current: ${currentLines[i]}');
        print('------------------------------------------------------');
      }
    }
    previousContent = currentContent;
    final Map<String, dynamic> jsonMap = json.decode(currentContent);
    final Map<String, dynamic> jsonEnMap = await generateJsonTranslate(
      lang: 'en',
      jsonMap: jsonMap,
      path: enPath,
    );
    await generateJsonTranslate(lang: 'ar', jsonMap: jsonMap, path: arPath);
    await generateAppStrings(jsonEnMap);
  } catch (e) {
    print('Uknown Key');
  }
}

/// Generates translation JSON files for a specific language.
///
/// Processes the master language file and creates properly formatted
/// JSON translation files with snake_case keys.
///
/// For the 'en' language, uses the original text as translation.
/// For other languages, uses the provided translation values.
///
/// Parameters:
/// - [lang]: Language code ('en', 'ar', etc.)
/// - [jsonMap]: Master language data from lang.json
/// - [path]: Output file path for the generated translation
///
/// Returns: Map of generated translations
Future<Map<String, dynamic>> generateJsonTranslate({
  required String lang,
  required Map<String, dynamic> jsonMap,
  required String path,
}) async {
  final StringBuffer buffer = StringBuffer();
  final String filePath = lang == 'en'
      ? path
      : lang == 'ar'
      ? path
      : '';
  final File file = File(filePath);
  buffer.writeln('{');
  // String content = file.readAsStringSync().trim();
  // final Map<String, dynamic> fileMap = json.decode(content);
  // List<String> lines = content.split('\n');
  // List<String> linesWithoutLastCurlBrace = lines.sublist(0, lines.length - 1);
  // buffer.writeAll(linesWithoutLastCurlBrace, '\n');
  // String bufferStringTrim = buffer.toString().trim();
  // bufferStringTrim = '$bufferStringTrim,';
  // buffer.clear();
  // buffer.writeln(bufferStringTrim);
  int counter = 0;
  //print('fileMap ${fileMap.toString()}');
  jsonMap.forEach((String key, dynamic value) {
    //print('$lang($counter)  "$key": "$value"');
    try {
      final Names keyNames = Names.fromString(key);
      // if (!fileMap.containsKey(keyNames.snakeCase)) {
      //print('$lang($counter)  !containsKey "${keyNames.snakeCase}" ');
      lang == 'en'
          ? buffer.write('  "${keyNames.snakeCase}": "${keyNames.original}"')
          : buffer.write('  "${keyNames.snakeCase}": "$value"');
      if (counter < jsonMap.length - 1) {
        buffer.write(',');
        // }
        buffer.writeln();
      }
    } on NamesException {
      final String keyStr = '[$key]';
      const String errorMessage = 'is not valid!';
      print(
        '${GenerateConstants.blueColorCode} $keyStr ${GenerateConstants.redColorCode}$errorMessage',
      );
    }
    counter++;
  });
  final List<String> linesAfterWrite = buffer.toString().trim().split('\n');
  String lastLineOfLinesAfterWrite = linesAfterWrite.last.trimRight();
  //print('lastLineOfLinesAfterWrite $lastLineOfLinesAfterWrite');
  if (lastLineOfLinesAfterWrite[lastLineOfLinesAfterWrite.length - 1] == ',') {
    lastLineOfLinesAfterWrite = lastLineOfLinesAfterWrite.substring(
      0,
      lastLineOfLinesAfterWrite.length - 1,
    );
    linesAfterWrite[linesAfterWrite.length - 1] = lastLineOfLinesAfterWrite;
    buffer.clear();
    buffer.writeAll(linesAfterWrite, '\n');
  }
  buffer.writeln();
  buffer.writeln('}');
  await file.writeAsString(buffer.toString());
  print(
    '${GenerateConstants.greenColorCode} Lang Json File Updated successfully at $filePath ${GenerateConstants.resetColorCode}',
  );
  return json.decode(buffer.toString());
}

/// Generates the LocaleKeys Dart class with type-safe constants.
///
/// Creates a Dart file containing:
/// - Static const strings for each translation key
/// - Getter methods that call .tr() for easy_localization integration
/// - Proper camelCase naming for Dart conventions
///
/// The generated class provides compile-time safety and IDE
/// auto-completion for all localization keys.
///
/// Parameters:
/// - [jsonMap]: English translations map (used as reference)
Future<void> generateAppStrings(Map<String, dynamic> jsonMap) async {
  final StringBuffer buffer = StringBuffer();
  // String content = file.readAsStringSync();
  // List<String> lines = content.split('\n');
  // List<String> linesWithoutLastCurlBrace = lines.sublist(0, lines.length - 1);
  // buffer.writeln();
  // buffer.writeAll(linesWithoutLastCurlBrace, '\n');
  // buffer.writeln();
  buffer.writeln(
    'import \'package:easy_localization/easy_localization.dart\';',
  );
  buffer.writeln();
  buffer.writeln('abstract class LocaleKeys {');
  jsonMap.forEach((String key, _) {
    try {
      final Names keyNames = Names.fromString(key);
      buffer.writeln(
        "  static const String _${keyNames.camelCase} = '${keyNames.original}';",
      );
      buffer.writeln(
        '  static String get ${keyNames.camelCase} => _${keyNames.camelCase}.tr();',
      );
      buffer.writeln();
    } on NamesException {
      final String keyStr = '[$key]';
      const String errorMessage = 'is not valid!';
      print(
        '${GenerateConstants.blueColorCode} $keyStr ${GenerateConstants.redColorCode}$errorMessage',
      );
    }
  });
  buffer.writeln('}');
  final File file = File(GenerateConstants.outputStringsFilePath);
  if (!await file.exists()) {
    await file.create(recursive: true);
  }
  await file.writeAsString(buffer.toString());
  print(
    '${GenerateConstants.greenColorCode} class AppStrings Generated successfully at ${GenerateConstants.outputStringsFilePath} ${GenerateConstants.resetColorCode}',
  );
}
