# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
### Changed
### Removed

## [v0.1.2] - 2023-01-29
### Changed
- Included `.formatter.exs` in the published package to enable `import_deps: [:ex_union]`

## [v0.1.1] - 2022-11-16
### Changed
- [#2](https://github.com/sascha-wolf/ex_union/pull/2): Resolve dialyzer warnings ([@sascha-wolf])

## [v0.1.0] - 2022-10-16

### Added

- Implement the core `ExUnion.defunion` macro and generate a struct for each union case
- Accept for type annotations of union case fields and use them to generate `@type` and `@spec` annotations
- Generate shortcut functions for each union case
- Generate a guard whose name is inferred from the top-level module

[Unreleased]: https://github.com/sascha-wolf/ex_union/compare/v0.1.2...main
[v0.1.2]: https://github.com/sascha-wolf/ex_union/compare/v0.1.1...v0.1.2
[v0.1.1]: https://github.com/sascha-wolf/ex_union/compare/v0.1.0...v0.1.1
[v0.1.0]: https://github.com/sascha-wolf/ex_union/compare/744dd7dc078c5e9d2311f11a223f326665d9a38b...v0.1.0

[@sascha-wolf]: https://github.com/sascha-wolf
