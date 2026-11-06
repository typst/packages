# `ascii-ipa`

🔄 ASCII / IPA conversion for Typst

This package allows you to easily convert different ASCII representations of the International Phonetic Alphabet (IPA) to and from the IPA.
It also offers some minor utilities to make phonetic transcriptions easier to use overall.
The package is being maintained [here][repo].

Note: This is an extended port of the [`ipa-translate`][ipa-translate] Rust crate by [tirimid][tirimid]'s conversion features into native Typst.
Most conversions are implemented according to [this Wikipedia article][ipa-wikipedia] with the [following exceptions](#deviations-from-wikipedia).

## Conversion

The package supports multiple ASCII representations for the IPA with one function each:

| Notation | Function name   |
|----------|-----------------|
| Branner  | `#branner(...)` |
| Praat    | `#praat(...)`   |
| SIL      | `#sil(...)`     |
| X-SAMPA  | `#xsampa(...)`  |

They all return the converted value as either [`string`][typst-str] or [`content`][typst-content]* and accept the set of same parameters:

| Parameter          | Type                    | Positional / Named | Default | Description                                                                                                                                                                                |
|--------------------|-------------------------|--------------------|---------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `value`            | [`string`][typst-str]   | positional         |         | Main input to the function. Usually the transcription in the corresponsing ASCII-based notation.                                                                                           |
| `reverse`          | [`boolean`][typst-bool] | named              | `false` | Reverses the conversion. Pass Unicode IPA into `value` to get the corresponsing ASCII-based notation back.                                                                                 |
| `override-font`\* | [`boolean`][typst-bool] | named              | `false` | Overrides the active font and forces rendering in Linux Libertine. Use this if your font has lackluster support for Unicode IPA. If set to `true`, the function will return [`content`][typst-content]. |

### Examples

All examples use the Russian word ⟨привет⟩ [prʲɪvʲet] for the conversion.

```typst
#import "@preview/ascii-ipa:1.1.1": *

// Branner
#branner("prj^Ivj^et") // prʲɪvʲet
#branner("prʲɪvʲet", reverse: true) // prj^Ivj^et

// Praat
#praat("pr\\^j\\icv\\^jet") // prʲɪvʲet
#praat("prʲɪvʲet", reverse: true) // pr\\^j\\icv\\^jet

// SIL
#sil("prj^i=vj^et") // prʲɪvʲet
#sil("prʲɪvʲet", reverse: true) // prj^i=vj^et

// X-SAMPA
#xsampa("pr_jIv_jet") // prʲɪvʲet
#xsampa("prʲɪvʲet", reverse: true) // pr_jIv_jet

// Font override
#xsampa("prj^Ivj^et", override-font: true) // prʲɪvʲet, but as content rendered in Linux Libertine
```

### Deviations from [Wikipedia][ipa-wikipedia]

Not everything could be implemented fully compliant with the information in the article.

- Branner
  - `ts))` is represented as `t))s`
- SIL
  - The only supported superscript characters are: `h` (`ʰ`), `j` (`ʲ`), `l` (`ˡ`), `n` (`ⁿ`), `w` (`ʷ`), `ɣ` (`ˠ`), `ʕ` (`ˤ`)

## Brackets & Braces

You can easily mark your notation text as phonetic, phonemic, orthographic, or prosodic.

```typst
#import "@preview/ascii-ipa:1.1.1": *

#phonetic("prʲɪˈvʲet") // [prʲɪˈvʲet]
#phnt("prʲɪˈvʲet") // [prʲɪˈvʲet]

#phonemic("prɪvet") // /prɪvet/
#phnm("prɪvet") // /prɪvet/

#orthographic("привет") // ⟨привет⟩
#orth("привет") // ⟨привет⟩

#prosodic("prʲɪˈvʲet") // {prʲɪˈvʲet}
#prsd("prʲɪˈvʲet") // {prʲɪˈvʲet}
```

[repo]: https://github.com/imatpot/typst-packages
[ipa-translate]: https://github.com/tirimid/ipa-translate
[tirimid]: https://github.com/tirimid
[ipa-wikipedia]: https://en.wikipedia.org/wiki/Comparison_of_ASCII_encodings_of_the_International_Phonetic_Alphabet
[typst-content]: https://typst.app/docs/reference/foundations/content/
[typst-str]: https://typst.app/docs/reference/foundations/str/
[typst-bool]: https://typst.app/docs/reference/foundations/bool/
