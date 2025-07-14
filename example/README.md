# LOC Generator Example

This example demonstrates how to use the `loc_generator` package to generate localization files for a Flutter application.

## Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the LOC Generator:**
   ```bash
   dart run loc_generator:main --lang_path assets/lang/lang.json --ar_path assets/lang/ar.json --en_path assets/en.json
   ```

3. **Run the example app:**
   ```bash
   flutter run
   ```

## File Structure

```
example/
├── assets/
│   ├── lang/
│   │   ├── lang.json      # Master language file (Arabic translations)
│   │   ├── ar.json        # Generated Arabic translations
│   │   └── en.json        # Generated English translations
│   └── en.json            # Alternative English file path
├── lib/
│   ├── main.dart          # Example Flutter app
│   └── src/
│       └── config/
│           └── language/
│               └── locale_keys.g.dart  # Generated locale keys
└── pubspec.yaml
```

## How It Works

### 1. Master Language File (`assets/lang/lang.json`)

This file contains the source translations with two supported formats:

**Basic Format:**
```json
{
  "Welcome": "مرحباً",
  "Sign In": "تسجيل الدخول"
}
```

**Advanced Format with Custom Keys:**
```json
{
  "home #$ Home": "الرئيسية",
  "passValidation #$ Password must be at least 8 characters long": "كلمة المرور يجب أن تكون على الأقل 8 أحرف"
}
```

### 2. Generated Files

The generator creates:

- **`ar.json`**: Arabic translations in snake_case format
- **`en.json`**: English translations in snake_case format  
- **`locale_keys.g.dart`**: Type-safe Dart constants and getters

### 3. Usage in Flutter

```dart
import 'package:flutter/material.dart';
import 'src/config/language/locale_keys.g.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(LocaleKeys.welcome),     // Type-safe!
        Text(LocaleKeys.signIn),      // Auto-completion!
        Text(LocaleKeys.home),        // No typos!
      ],
    );
  }
}
```

## Development Workflow

1. Edit `assets/lang/lang.json` with new translations
2. The generator automatically updates all files (if running in watch mode)
3. Use the generated `LocaleKeys` in your Flutter widgets
4. Hot reload works seamlessly!

## Key Features Demonstrated

- ✅ **Type Safety**: No more string typos in localization keys
- ✅ **Auto-completion**: IDE support for all locale keys
- ✅ **Hot Reload**: Automatic regeneration on file changes
- ✅ **Multi-language**: Support for Arabic and English
- ✅ **Smart Naming**: Automatic conversion to appropriate case formats
- ✅ **Validation**: Clear error messages for invalid keys

## Running the Generator

### One-time Generation
```bash
dart run loc_generator:main --lang_path assets/lang/lang.json --ar_path assets/lang/ar.json --en_path assets/en.json
```

### Watch Mode (Recommended for Development)
The generator automatically watches for file changes and regenerates code:
```bash
dart run loc_generator:main --lang_path assets/lang/lang.json --ar_path assets/lang/ar.json --en_path assets/en.json
# Keep this running during development
```

## Output Example

When you run the generator, you'll see colorful output like:

```
✅ Lang Json File Updated successfully at assets/lang/en.json
✅ Lang Json File Updated successfully at assets/lang/ar.json  
✅ class AppStrings Generated successfully at lib/src/config/language/locale_keys.g.dart
🔍 Watching for changes in: assets/lang/lang.json
```

## Troubleshooting

### Invalid Key Names
If you see blue and red error messages, it means some keys contain invalid characters:
```
[Welcome!!!] is not valid!
```

Fix by using only alphanumeric characters, spaces, and basic punctuation.

### File Not Found
Make sure all file paths exist or the generator will create them automatically.

### JSON Syntax Errors
Validate your JSON syntax in `lang.json` - the generator will show helpful error messages.
