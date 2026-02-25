# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

<!-- insertion marker -->
## [0.5.2](https://github.com/npikall/rubber-article/releases/tag/0.5.2) - 2026-02-25

<small>[Compare with v0.5.1](https://github.com/npikall/rubber-article/compare/v0.5.1...0.5.2)</small>

### Reverts

- add env variable typst-root back into justfile ([7adb6ad](https://github.com/npikall/rubber-article/commit/7adb6ad7b4a25cbedd2389c85247248dac813f2c) by npikall).
- strict placement of maketitle in the top from v0.4.2 ([1087a62](https://github.com/npikall/rubber-article/commit/1087a628e668521696d706415ca12babb60ce8de) by npikall).

### Code Refactoring

- move frontmatter into box with an inset ([e9f6fc1](https://github.com/npikall/rubber-article/commit/e9f6fc1d8e66f8c81beb02f37b8b3825bc01de4c) by npikall).


## [v0.5.1](https://github.com/npikall/rubber-article/releases/tag/v0.5.1) - 2026-01-18

<small>[Compare with v0.5.0](https://github.com/npikall/rubber-article/compare/v0.5.0...v0.5.1)</small>

### Bug Fixes

- separate outline link styling from main body ([54e09af](https://github.com/npikall/rubber-article/commit/54e09af1f6eff4387256205ad80706c35dd10a91) by Nikolas Pikall).

## [v0.5.0](https://github.com/npikall/rubber-article/releases/tag/v0.5.0) - 2025-07-21

<small>[Compare with v0.4.2](https://github.com/npikall/rubber-article/compare/v0.4.2...v0.5.0)</small>

- new option to set default font
- new option to set spacings around the title-block
- new option to set paragraph spacing
- new option to set the paper size
- new function to have a common vertical spacer between paragraphs
- patch of justify option
- refactor of the argument names
- better documentation

## [v0.4.2](https://github.com/npikall/rubber-article/releases/tag/v0.4.2) - 2025-06-16

<small>[Compare with v0.4.1](https://github.com/npikall/rubber-article/compare/v0.4.1...v0.4.2)</small>

- new function for abstract
- new option to set columns for entire document
- changed default behaviour of metadata in `maketitle`
- added `balance` function for balancing columns in the document

## [v0.4.1](https://github.com/npikall/rubber-article/releases/tag/v0.4.1) - 2025-05-05

<small>[Compare with v0.4.0](https://github.com/npikall/rubber-article/compare/v0.4.0...v0.4.1)</small>

- new function for the list of figures
- new function for the list of tables
- new feature for short and long captions (one outlined, one with the figure)
- fixed figure and table outline style

## [v0.4.0](https://github.com/npikall/rubber-article/releases/tag/v0.4.0) - 2025-04-16

<small>[Compare with v0.3.2](https://github.com/npikall/rubber-article/compare/v0.3.2...v0.4.0)</small>

- added tests
- fixed spacings of the paragraphs, figures and equations
- removed appendix and bibliography feature, because of redundancy
- fixed Table cell spaces
- changed the template

## [v0.3.2](https://github.com/npikall/rubber-article/releases/tag/v0.3.2) - 2025-04-11

<small>[Compare with v0.3.1](https://github.com/npikall/rubber-article/compare/v0.3.1...v0.3.2)</small>

- fragmentized, cleared up codebase
- table function with standard formatting
- header linewidth

### Bug Fixes

- typo in function arguments (#19) (#20) ([3f91c98](https://github.com/npikall/rubber-article/commit/3f91c98f0f71aa0c5e59bd5923e692ef1dc97445) by imanuilovkirill).

## [v0.3.1](https://github.com/npikall/rubber-article/releases/tag/v0.3.1) - 2025-02-21

<small>[Compare with v0.3.0](https://github.com/npikall/rubber-article/compare/v0.3.0...v0.3.1)</small>

- new function to only format the appendix

## [v0.3.0](https://github.com/npikall/rubber-article/releases/tag/v0.3.0) - 2025-02-20

<small>[Compare with v0.2.0](https://github.com/npikall/rubber-article/compare/v0.2.0...v0.3.0)</small>

- integrated bibliography
- better handling of the figure captions
- chapterwise numbering of equations
- headers have been updated
- an appendix can be added

## [v0.2.0](https://github.com/npikall/rubber-article/releases/tag/v0.2.0) - 2025-02-12

<small>[Compare with v0.1.0](https://github.com/npikall/rubber-article/compare/v0.1.0...v0.2.0)</small>

- Added some more funcitonality to the package.
- Headers are now integrated, useing hydra.
- List indentation are now set to 1.5em.

## [v0.1.0](https://github.com/npikall/rubber-article/releases/tag/v0.1.0) - 2024-09-04

<small>[Compare with first commit](https://github.com/npikall/rubber-article/compare/5cf6b00d59d09aaab97650b902b6d96225b20d58...v0.1.0)</small>

- initial Release
