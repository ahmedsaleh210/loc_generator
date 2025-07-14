# LOC Generator

A powerful Dart package for generating localization files and constants for Flutter applications. This package automatically generates strongly-typed locale keys and translation files from a master language configuration file.

## Features

- 🚀 **Automatic Code Generation**: Generates type-safe locale keys and getters
- 🔄 **Hot Reload Support**: Watches for file changes and regenerates code automatically
- 🌍 **Multi-language Support**: Supports multiple languages (currently Arabic and English)
- 📝 **Smart Key Conversion**: Converts user-friendly keys to snake_case and camelCase
- ✅ **Validation**: Validates key names and provides helpful error messages
- 🎨 **Colored Output**: Beautiful terminal output with color-coded messages
- 🔧 **Easy Integration**: Works seamlessly with `easy_localization` package

## Installation

Add this package to your `pubspec.yaml` file:

```yaml
dev_dependencies:
  loc_generator: ^1.0.0
```

Or install it globally:

```bash
dart pub global activate loc_generator
```

## Usage

### Basic Usage

Run the generator with the following command:

```bash
dart run loc_generator:main --lang_path assets/lang/lang.json --ar_path assets/lang/ar.json --en_path assets/en.json
```

### Command Line Arguments

- `--lang_path` (`-f`): Path to the master language file (contains key-value pairs)
- `--ar_path` (`-a`): Path to the Arabic translation file
- `--en_path` (`-l`): Path to the English translation file

### File Structure

Create the following directory structure in your Flutter project:

```
assets/
  lang/
    lang.json     # Master language file (Arabic translations)
    ar.json       # Generated Arabic file
    en.json       # Generated English file
lib/
  src/
    config/
      language/
        locale_keys.g.dart  # Generated locale keys
```

## Master Language File Format

The master language file (`lang.json`) should contain key-value pairs where:
- **Key**: The display text in your default language (English)
- **Value**: The translation in the target language (Arabic)

### Basic Format

```json
{
  "Welcome": "مرحباً",
  "Sign In": "تسجيل الدخول",
  "Email": "البريد الإلكتروني"
}
```

### Advanced Format with Custom Keys

You can specify custom keys using the `#$` separator:

```json
{
  "home #$ Home": "الرئيسية",
  "product #$ Product": "المنتج",
  "passValidation #$ Password must be at least 8 characters long": "كلمة المرور يجب أن تكون على الأقل 8 أحرف"
}
```

In this format:
- `home` becomes the generated key
- `Home` becomes the English translation
- `الرئيسية` becomes the Arabic translation

## Generated Files

### 1. English Translation File (`en.json`)

```json
{
  "welcome": "Welcome",
  "sign_in": "Sign In",
  "email": "Email",
  "home": "Home",
  "product": "Product"
}
```

### 2. Arabic Translation File (`ar.json`)

```json
{
  "welcome": "مرحباً",
  "sign_in": "تسجيل الدخول",
  "email": "البريد الإلكتروني",
  "home": "الرئيسية",
  "product": "المنتج"
}
```

### 3. Locale Keys Class (`locale_keys.g.dart`)

```dart
import 'package:easy_localization/easy_localization.dart';

abstract class LocaleKeys {
  static const String _welcome = 'welcome';
  static String get welcome => _welcome.tr();

  static const String _signIn = 'sign_in';
  static String get signIn => _signIn.tr();

  static const String _email = 'email';
  static String get email => _email.tr();

  static const String _home = 'home';
  static String get home => _home.tr();

  static const String _product = 'product';
  static String get product => _product.tr();
}
```

## Usage in Flutter App

### 1. Setup Easy Localization

First, add the necessary dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  easy_localization: ^3.0.0

flutter:
  assets:
    - assets/lang/
```

### 2. Initialize Easy Localization

```dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ar')],
      path: 'assets/lang',
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: MyHomePage(),
    );
  }
}
```

### 3. Use Generated Locale Keys

```dart
import 'package:flutter/material.dart';
import 'src/config/language/locale_keys.g.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.welcome), // "Welcome" or "مرحباً"
      ),
      body: Column(
        children: [
          Text(LocaleKeys.signIn),     // "Sign In" or "تسجيل الدخول"
          Text(LocaleKeys.email),      // "Email" or "البريد الإلكتروني"
          ElevatedButton(
            onPressed: () => context.setLocale(Locale('ar')),
            child: Text('العربية'),
          ),
          ElevatedButton(
            onPressed: () => context.setLocale(Locale('en')),
            child: Text('English'),
          ),
        ],
      ),
    );
  }
}
```

## Key Naming Rules

The generator follows these naming conventions:

1. **Snake Case Keys**: All JSON keys are converted to snake_case
   - `"Sign In"` → `"sign_in"`
   - `"Phone Number"` → `"phone_number"`

2. **Camel Case Getters**: All Dart getters use camelCase
   - `"sign_in"` → `signIn`
   - `"phone_number"` → `phoneNumber`

3. **Valid Characters**: Keys must contain only alphanumeric characters, spaces, and basic punctuation
   - ✅ Valid: `"Welcome"`, `"Sign In"`, `"Password123"`
   - ❌ Invalid: `"Welcome!!!"`, `"@#$%"`

## File Watching

The generator includes a file watcher that automatically regenerates files when the master language file changes. Simply run the command once, and it will continue watching for changes:

```bash
dart run loc_generator:main --lang_path assets/lang/lang.json --ar_path assets/lang/ar.json --en_path assets/en.json
```

You'll see output like:
```
✅ Lang Json File Updated successfully at assets/lang/en.json
✅ Lang Json File Updated successfully at assets/lang/ar.json
✅ class AppStrings Generated successfully at lib/src/config/language/locale_keys.g.dart
🔍 Watching for changes in: assets/lang/lang.json
```

## Error Handling

The generator provides helpful error messages:

- **Invalid Key Names**: Keys with invalid characters will be highlighted in blue and red
- **File Not Found**: Clear error messages for missing files
- **JSON Syntax Errors**: Helpful parsing error information

## Configuration

You can customize the output paths by modifying the constants in `lib/src/utils/generate_constants.dart`:

```dart
abstract class GenerateConstants {
  static const String outputStringsFilePath = 'lib/src/config/language/locale_keys.g.dart';
  // ... other constants
}
```

## Examples

Check the `example/` directory for a complete Flutter application demonstrating the usage of this package.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.