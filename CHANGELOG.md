# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-14

### Added
- Initial release of LOC Generator
- Automatic generation of type-safe locale keys from JSON files
- Support for English and Arabic translations
- File watching capability for hot reload during development
- Smart key conversion (snake_case for JSON, camelCase for Dart)
- Custom key naming with `#$` separator syntax
- Validation of key names with helpful error messages
- Colored terminal output for better developer experience
- Integration with `easy_localization` package
- Command-line interface with configurable file paths

### Features
- Generate `LocaleKeys` class with static getters
- Auto-convert display text to appropriate naming conventions
- Watch mode for continuous file monitoring
- Multi-language support (extensible architecture)
- Comprehensive error handling and validation
