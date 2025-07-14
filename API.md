# API Documentation

This document provides detailed information about the LOC Generator package's API and internal structure.

## Command Line Interface

### Main Command

```bash
dart run loc_generator:main [OPTIONS]
```

### Options

| Option | Short | Required | Description |
|--------|-------|----------|-------------|
| `--lang_path` | `-f` | Yes | Path to the master language file (JSON) |
| `--ar_path` | `-a` | Yes | Path to the Arabic translation output file |
| `--en_path` | `-l` | Yes | Path to the English translation output file |

### Example

```bash
dart run loc_generator:main \
  --lang_path assets/lang/lang.json \
  --ar_path assets/lang/ar.json \
  --en_path assets/en.json
```

## Core Classes

### Names Class

The `Names` class handles key transformations and naming conventions.

```dart
class Names {
  String original;     // Original text from JSON
  String camelCase;    // camelCase version for Dart getters
  String snakeCase;    // snake_case version for JSON keys
  String classCase;    // PascalCase version (currently unused)
}
```

#### Factory Constructor

```dart
Names.fromString(String input)
```

Creates a `Names` instance from input string, handling:
- Custom key format with `#$` separator
- Character validation
- Case conversions

#### Example Usage

```dart
// Basic format
final names1 = Names.fromString("Welcome");
// names1.original = "Welcome"
// names1.snakeCase = "welcome" 
// names1.camelCase = "welcome"

// Custom key format
final names2 = Names.fromString("home #$ Home");
// names2.original = "Home"
// names2.snakeCase = "home"
// names2.camelCase = "home"
```

### GenerateConstants Class

Contains configuration constants for file paths and terminal colors.

```dart
abstract class GenerateConstants {
  // Terminal Colors
  static const String blueColorCode = '\x1B[34m';
  static const String orangeColorCode = '\x1B[33m';
  static const String redColorCode = '\x1B[31m';
  static const String greenColorCode = '\x1B[32m';
  static const String resetColorCode = '\x1B[0m';
  
  // File Paths
  static const String outputStringsFilePath = 'lib/src/config/language/locale_keys.g.dart';
  static const String projectFeaturesPath = 'lib/src/features';
  static const String requestsAssetsPath = 'assets/requests';
}
```

## Core Functions

### main()

Entry point that:
1. Parses command line arguments
2. Sets up file watcher
3. Performs initial generation
4. Listens for file changes

```dart
void main(List<String> arguments) async
```

### handleFileChange()

Handles file modification events:
1. Compares current vs previous content
2. Shows diff information
3. Triggers regeneration

```dart
void handleFileChange(
  File file,
  String previousContent, {
  required String enPath,
  required String arPath,
}) async
```

### generateJsonTranslate()

Generates translation JSON files:
1. Processes master language file
2. Converts keys to snake_case
3. Applies appropriate translations
4. Writes formatted JSON output

```dart
Future<Map<String, dynamic>> generateJsonTranslate({
  required String lang,
  required Map<String, dynamic> jsonMap,
  required String path,
}) async
```

### generateAppStrings()

Generates the LocaleKeys Dart class:
1. Creates static constants for each key
2. Generates getter methods with `.tr()` calls
3. Writes formatted Dart code

```dart
Future<void> generateAppStrings(Map<String, dynamic> jsonMap) async
```

## File Formats

### Master Language File Format

The master file supports two formats:

#### Basic Format
```json
{
  "Display Text": "Translation"
}
```

#### Advanced Format with Custom Keys
```json
{
  "customKey #$ Display Text": "Translation"
}
```

### Generated JSON Format

All generated JSON files use snake_case keys:

```json
{
  "welcome": "Welcome",
  "sign_in": "Sign In",
  "phone_number": "Phone Number"
}
```

### Generated Dart Class Format

```dart
import 'package:easy_localization/easy_localization.dart';

abstract class LocaleKeys {
  static const String _keyName = 'key_name';
  static String get keyName => _keyName.tr();
  
  // ... more keys
}
```

## Validation Rules

### Key Name Validation

Keys must pass the following validation:

1. **Valid Characters**: Only alphanumeric characters, spaces, and basic punctuation
2. **Non-empty**: Cannot be empty or whitespace-only
3. **Pattern Match**: Must match `NamesHelper.validCharactersPattern`

### Invalid Examples
- `""` (empty)
- `"!!!"` (only punctuation)
- `"@#$%"` (invalid characters)

### Valid Examples
- `"Welcome"`
- `"Sign In"`
- `"Password123"`
- `"User Profile"`

## Error Handling

### NamesException

Thrown when key names fail validation:

```dart
class NamesException implements Exception {
  final String message;
  NamesException(this.message);
}
```

### Error Output

Invalid keys are displayed with colored terminal output:

```
[InvalidKey!!!] is not valid!
```

- Blue: Key name in brackets
- Red: Error message

## File Watching

The package uses the `watcher` package to monitor file changes:

```dart
final FileWatcher watcher = FileWatcher(filePath);
watcher.events.listen((WatchEvent event) {
  if (event.type == ChangeType.MODIFY) {
    // Handle file change
  }
});
```

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `args` | ^2.7.0 | Command line argument parsing |
| `watcher` | ^1.1.2 | File system watching |

## Integration with easy_localization

The generated code is designed to work with the `easy_localization` package:

```dart
// Generated getter
static String get welcome => _welcome.tr();

// Usage in Flutter
Text(LocaleKeys.welcome) // Automatically translated
```

## Extending the Package

### Adding New Languages

To add support for additional languages:

1. Add new command line option in `main.dart`
2. Modify `generateJsonTranslate()` to handle new language
3. Update master file format if needed

### Custom Output Paths

Modify constants in `GenerateConstants`:

```dart
static const String outputStringsFilePath = 'your/custom/path/locale_keys.g.dart';
```

### Custom Naming Conventions

Extend the `Names` class or `NamesHelper` utility to support different naming patterns.

## Performance Considerations

- File watching is efficient and doesn't block the main thread
- JSON parsing is done incrementally for large files
- Generated files are written atomically to prevent corruption
- Diff detection minimizes unnecessary regeneration
