# ascii-ipa

This package allows you to easily convert different ASCII representations of the International Phonetic Alphabet (IPA) to and from the IPA.
It also offers some minor utilities to make phonetic transcriptions easier to use overall.

Note: This is an extended port of the [`ipa-translate`][ipa-translate] Rust crate by [tirimid][tirimid]'s conversion features into native Typst.
All conversions are implemented according to [this Wikipedia article][ipa-wikipedia].

## Usage

### Conversion

The package supports several different ASCII representations for the IPA with one function each:

| Notation | Function name   |
|----------|-----------------|
| Branner  | `#branner(...)` |
| Praat    | `#praat(...)`   |
| SIL      | `#sil(...)`     |
| X-SAMPA  | `#xsampa(...)`  |

They all return the converted value as `content` and accept the same parameters:

| Parameter       | Type      | Positional / Named | Default | Description                                                                                                                      |
|-----------------|-----------|--------------------|---------|----------------------------------------------------------------------------------------------------------------------------------|
| `value`         | `string`  | positional         |         | Main input to the function. Usually the transcription in the corresponsing ASCII-based notation.                                 |
| `reverse`       | `boolean` | named              | `false` | Reverses the conversion. Pass Unicode IPA into `value` to get the corresponsing ASCII-based notation back.                       |
| `override-font` | `boolean` | named              | `false` | Overrides the active font and forces rendering in Linux Libertine. Use this if your font has lackluster support for Unicode IPA. |

#### Examples

All examples use the Russian word ⟨привет⟩ [prʲɪvʲet] for the conversion.

```ts
#import "@preview/ascii-ipa:1.0.0": *

// Branner
#branner("prj^Ivj^et") // -> prʲɪvʲet
#branner("prʲɪvʲet", reverse: true) // -> prj^Ivj^et

// Praat
#praat("pr\\^j\\icv\\^jet") // -> prʲɪvʲet
#praat("prʲɪvʲet", reverse: true) // -> pr\\^j\\icv\\^jet

// SIL
#sil("prj^i=vj^et") // -> prʲɪvʲet
#sil("prʲɪvʲet", reverse: true) // -> prj^i=vj^et

// X-SAMPA
#xsampa("pr_jIv_jet") // -> prʲɪvʲet
#xsampa("prʲɪvʲet", reverse: true) // -> pr_jIv_jet

// Font override
#xsampa("prj^Ivj^et", override-font: true) // -> prʲɪvʲet, but in Linux Libertine
```

#### Deviations from [Wikipedia][ipa-wikipedia]

Not everything is implemented fully compliant with the information in the article.

- Branner
  - `ts))` is instead represented as `t))s`
- SIL
  - The only supported superscript characters are: `ʰ`, `ʷ`, `ʲ`, `ˠ`, `ˤ`, `ⁿ`, `ˡ`

### Brackets & Braces

You can easily mark your notation text as phonetic, phonemic, orthographic, or prosodic.

```ts
#import "@preview/ascii-ipa:1.0.0": *

#phonetic("prʲɪˈvʲet") // -> [prʲɪˈvʲet]
#phnt("prʲɪˈvʲet") // -> [prʲɪˈvʲet]

#phonemic("prɪvet") // -> /prɪvet/
#phnm("prɪvet") // -> /prɪvet/

#orthographic("привет") // -> ⟨привет⟩
#orth("привет") // -> ⟨привет⟩

#prosodic("prʲɪˈvʲet") // -> {prʲɪˈvʲet}
#prsd("prʲɪˈvʲet") // -> {prʲɪˈvʲet}
```

[ipa-translate]: https://github.com/tirimid/ipa-translate
[tirimid]: https://github.com/tirimid
[ipa-wikipedia]: https://en.wikipedia.org/wiki/Comparison_of_ASCII_encodings_of_the_International_Phonetic_Alphabet
