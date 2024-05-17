# Changelog of `ascii-ipa`

follows [semantic versioning](https://semver.org)

## 2.0.0

> [!CAUTION]
> This release contains breaking changes

- General
  - **BREAKING:** Dropped support for `override-font` to avoid [`str`](https://typst.app/docs/reference/foundations/str/)/[`content`](https://typst.app/docs/reference/foundations/content/) ambiguity
  - Added bracket & braces support for [precise, morphophonemic, indistinguishable, obscured, and transliterated](https://en.wikipedia.org/wiki/International_Phonetic_Alphabet#Brackets_and_transcription_delimiters) notations
  - Added support for converting [`raw`](https://typst.app/docs/reference/text/raw/)
- Branner
  - **BREAKING:** Infixed `))` (e.g. `t))s`) is no longer supported and must now be used as a postfix (e.g. `ts))`) as per the official specification
  - Added support for more IPA characters and diacritics according to official specification
- Praat
  - Added support for more IPA characters and diacritics according to official specification
- SIL
  - Added support for more IPA characters and diacritics according to official specification
  - Added support for subscripts
  - Added support for right-bar tone glides
  - Added support for left-bar tones
  - Added Unicode support for hooks (palatal, retroflex)
  - Added Unicode support for middle tildes (velar, pharyngeal)
  - Added Unicode support for superscripts
- X-SAMPA
  - Added support for more IPA characters and diacritics according to official specification

## 1.1.1

- Fixed a bug in X-SAMPA where ``` ` ``` falsely took precedence over ``` @` ``` (https://github.com/imatpot/typst-packages/issues/1)

## 1.1.0

- Translations will now return a [`str`](https://typst.app/docs/reference/foundations/str/) if the font is not overridden
- The library now explicitly exposes functions via a "gateway" entrypoint
- Update internal project structure
- Update package metadata
- Update documentation

## 1.0.0

- Initial release
