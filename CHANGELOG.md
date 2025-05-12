# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.9.6] - 2025-05-12
### Changed


## [1.9.5] - 2025-05-11
### Changed
- Updated GitHub Actions workflow configuration

## [1.9.4] - 2025-05-11
### Fixed
- Fixed library name resolution on Windows platform
- Fixed export errors in platform-specific extensions
- Fixed internal error handling in LibGit2Error

### Changed
- Improved library name resolution mechanism
- Enhanced platform-specific extension handling
- Removed redundant version checks in library loading

### Dependencies
- Updated ffi to ^2.1.0
- Updated meta to ^1.17.0
- Updated path to ^1.8.3

## [1.9.3] - 2025-05-09
### Changed
- Removed hardcoded libgit2 version from library name resolution
- Simplified library name resolution to use platform-specific extensions
- Removed @internal annotation from LibGit2Error constructor

## [1.9.2] - 2025-05-09
### Fixed
 - export errors and extensions

## [1.9.1] - 2025-05-09
### Added
- Updated to libgit2 version 1.9.0
- Added new caching options and controls
- Added template path configuration options
- Added SSL certificate-authority location settings
- Added fsync gitdir control
- Added strict hash verification options
- Added unsaved index safety checks
- Added pack file object limit controls

### Changed
- Updated Flutter SDK constraint from "^3.29.3" to ">=3.29.3" for better version compatibility
- Updated Dart SDK requirement to ">=3.7.2 <4.0.0"

### Dependencies
- Updated ffi to ^2.0.0
- Updated meta to ^1.16.0
- Updated path to ^1.8.1
- Updated plugin_platform_interface to ^2.0.2
- Updated pub_semver to ^2.1.3
- Updated dev dependencies:
  - ffigen to ^18.1.0
  - lints to ^5.1.1
  - test to ^1.24.0

## [1.9.0] - 2025-05-09
### Added
- Updated to libgit2 version 1.9.0
- Added new caching options and controls
- Added template path configuration options
- Added SSL certificate-authority location settings
- Added fsync gitdir control
- Added strict hash verification options
- Added unsaved index safety checks
- Added pack file object limit controls

### Changed
- Updated Flutter SDK constraint from "^3.29.3" to ">=3.29.3" for better version compatibility
- Updated Dart SDK requirement to ">=3.7.2 <4.0.0"

### Dependencies
- Updated ffi to ^2.0.0
- Updated meta to ^1.16.0
- Updated path to ^1.8.1
- Updated plugin_platform_interface to ^2.0.2
- Updated pub_semver to ^2.1.3
- Updated dev dependencies:
  - ffigen to ^18.1.0
  - lints to ^5.1.1
  - test to ^1.24.0

## [0.3.0] - 2024-03-19
### Changed
- Updated to Dart 3

## [0.2.0] - 2024-03-19
### Added
- macOS bindings

## [0.1.5] - 2024-03-19
### Fixed
- Fixed utils._checkCache call

## [0.1.4] - 2024-03-19
### Fixed
- Fixed utils._checkCache call

## [0.1.3] - 2024-03-19
### Fixed
- Fixed bindings

## [0.1.2] - 2024-03-19
### Fixed
- Fixed Windows bindings

## [0.1.1] - 2024-03-19
### Improved
- Improved bindings

## [0.1.0] - 2024-03-19
### Added
- Linux bindings

## [0.0.9] - 2024-03-19
### Fixed
- Fixed Flutter plugin on Windows

## [0.0.8] - 2024-03-19
### Added
- Load libcrypto-1_1-x64.dll on start for Windows platform

## [0.0.7] - 2024-03-19
### Fixed
- Fixed libgit2 field

## [0.0.6] - 2024-03-19
### Added
- Added libgit2Opts

## [0.0.4] - 2024-03-19
### Added
- Added entry point

## [0.0.3] - 2024-03-19
### Fixed
- Fixed reference

## [0.0.2] - 2024-03-19
### Added
- Windows bindings with GitHub Actions

## [0.0.1] - 2024-03-19
### Added
- Windows bindings

## [0.0.0] - 2024-03-19
### Added
- Initial version with Libgit2 1.6.1
