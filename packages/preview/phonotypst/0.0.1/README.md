# Phonotypst

A phonology toolkit for Typst, providing IPA transcription with tipa-style input, prosodic structure visualization, and IPA charts for vowels and consonants.

## Features

### IPA Module

- **tipa-style input**: Use familiar LaTeX tipa notation instead of hunting for Unicode symbols
- **Comprehensive symbol support**: All IPA consonants, vowels, and other symbols from the tipa chart
- **Combining diacritics**: Nasalized (`\\~`), devoiced (`\\r`), syllabic (`\\v`); the tie (`\\t`) is also available
- **Suprasegmentals**: Primary stress (`'`), secondary stress (`,`), length (`:`)
- **Automatic character splitting**: Type `SE` instead of `S E` for efficiency (spacing is necessary around characters using backslashes)
- **Charis SIL font**: Proper rendering of all IPA symbols

### Prosody Module

- **Prosodic structure visualization**: Draw syllable structures with onset, nucleus, and coda
- **Flexible foot structure**: Use parentheses to mark explicit foot boundaries
- **Stress marking**: Mark stressed syllables with apostrophe
- **Flexible alignment**: Left or right alignment for prosodic word heads
- **Beautiful diagrams**: Clean `CeTZ`-based visualizations

### IPA Charts Module

- **Vowel charts**: Plot vowels on the IPA vowel trapezoid with accurate positioning
- **Consonant tables**: Display consonants in the pulmonic IPA consonant table
- **Language inventories**: Pre-defined inventories for major languages (English, Spanish, French, German, Italian, Portuguese, Japanese, Russian, Arabic, Mandarin)
- **Custom symbol sets**: Plot any combination of IPA symbols
- **Automatic positioning**: Symbols positioned according to phonetic properties (place, manner, voicing, frontness, height, roundedness)
- **Proper IPA formatting**: Voiceless/voiced pairs, grayed-out impossible articulations, minimal pair bullets for vowels
- **Scalable charts**: Adjust size to fit your document layout
- **Charis SIL font**: Professional IPA symbol rendering

## Installation

### Package Repository

- `http://github.com/guilhermegarcia/phonotypst`

## Usage

### IPA Transcription

```typst
// Basic transcription
#ipa("'sIRi")  // → ˈsɪti

// With nasalization
#ipa("\\~ E")  // → ɛ̃

// With devoicing
#ipa("\\r z")  // → z̥

// With voicing
#ipa("\\v n")  // → n̩

// Affricates
#ipa("\\t ts")  // → t͡s

// Complex example with multiple features
#ipa("'sIn,t \\ae ks")  // → ˈsɪnˌtæks
```

#### `tipa` Notation Quick Reference

**Single-character codes** (no space needed):

- Common vowels: `i I e E a A o O u U @`
- Common consonants: `p b t d k g f v s z S Z m n N l r`
- Stress: `'` (primary), `,` (secondary)
- Length: `:` (place after vowel)

**Multi-character codes** (with backslash, need spaces around them):

- `\\textltailn` → ɲ
- `\\ae` → æ
- See [tipa chart](http://www.tug.org/tugboat/tb17-2/tb51rei.pdf) for complete list

**Combining diacritics** (need space before target):

- `\\~` → ̃ (nasalization)
- `\\r` → ̥ (devoicing/voiceless)
- `\\v` → ̩ (voicing mark)
- `\\t` → ͡ (tie bar/liaison)

### IPA Charts

Phonotypst provides functions for visualizing IPA vowel and consonant inventories with proper phonetic positioning.

#### Vowel Charts

```typst
// Plot English vowel inventory
#vowels("english")

// Plot specific vowels
#vowels("aeiou")

// Plot French vowels with custom scale
#vowels("french", scale: 0.5)

// All available vowels
#vowels("all")
```

**Available consonant language inventories:** `all`, `english`, `spanish`, `french`, `german`, `italian`, `japanese`, `portuguese`, `russian`, `arabic`

#### Consonant Tables

```typst
// Plot complete pulmonic consonant chart
#consonants("all")

// Plot English consonant inventory
#consonants("english")

// Plot specific consonants
#consonants("ptk")

// Plot Spanish consonants with custom scale
#consonants("spanish", scale: 0.6)
```

**Available consonant language inventories:** `all`, `english`, `spanish`, `french`, `german`, `italian`, `japanese`, `portuguese`, `russian`, `arabic`

**Chart features:**

- Vowels positioned by frontness, height, and roundedness on trapezoid
- Consonants organized by place and manner of articulation
- Voiceless consonants on left, voiced on right in each cell
- Impossible articulations (e.g., pharyngeal nasals) automatically grayed out
- Minimal pair bullets for rounded/unrounded vowel pairs
- Default scale of 0.7 fits portrait pages; adjustable with `scale` parameter

### Prosodic Structures

Phonotypst provides three functions for visualizing different levels of prosodic structure. The functions `syllable()`, `foot()` and `word()` below also have a `scale` argument (float) for adjusting the size of the resulting prosodic tree. Crucially, the scaling includes the tree, the text and the thickness of the lines in the tree.

#### Syllable Level

```typst
// Visualize a single syllable's internal structure (σ)
#syllable("man")
#syllable("'to") // stress symbol makes no difference here
```

#### Foot Level

```typst
// Visualize foot (Σ) and syllable (σ) levels
#foot("man.'tal")
#foot("'man.tal")
```

#### Word Level

```typst
// Visualize prosodic word (PWd), foot (Σ), and syllable (σ) levels
#word("(ma.'va).ro")  // One binary iamb; one footless syllable

// Right-aligned prosodic word (default)
#word("ma.('va.ro)")  // One trochee; one footless syllable

// Disyllabic word
#word("('ka.va)")

// A dactyl
#word("('ka.va.mi)")

// Multiple feet, where foot = main foot/stress
#word("('ka.ta)('vas.lo)", foot: "L") 
```

**Prosody notation:**

- `.` separates syllables
- `'` before a syllable marks it as stressed (e.g., `'va`)
- `()` marks foot boundaries (used in `#word()`)
- Characters within syllables are automatically parsed into onset, nucleus, and coda
- Geminates are automatically detected for `#foot()` and `#word`
- For long vowels, use `vv` instead of using the length diacritic `:`

## Dependencies

- [CeTZ](https://github.com/cetz-package/cetz) 0.3.2 - For drawing prosodic structures and IPA charts

## License

MIT

## Author

**Guilherme D. Garcia**
Email: <guilherme.garcia@lli.ulaval.ca>

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Fonts

This package includes **Charis SIL**, a Unicode-based font family designed for broad phonetic transcription and supporting comprehensive IPA symbols. Charis SIL is developed by SIL International and distributed under the SIL Open Font License (OFL).

- **Font**: Charis SIL
- **Version**: 6.200 (or later)
- **Copyright**: © 1997-2023 SIL International
- **License**: SIL Open Font License 1.1
- **Website**: <https://software.sil.org/charis/>

The inclusion of Charis SIL ensures consistent and accurate rendering of IPA symbols across all systems without requiring users to install additional fonts.

## Acknowledgments

This package was developed to make phonological notation and visualization easier for linguists using Typst.

Special thanks to SIL International for developing and maintaining Charis SIL, an essential resource for linguistic typography.
