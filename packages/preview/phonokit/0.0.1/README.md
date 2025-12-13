# Phonokit 🪶

A phonology toolkit for Typst, providing IPA transcription with tipa-style input, prosodic structure visualization, and IPA charts for vowels and consonants.

🚨 **Charis SIL font is needed** for this package to work as intended. If you don't already have this font installed, visit <https://software.sil.org/charis/download/>.

## Features

### IPA Module

- **tipa-style input**: Use familiar LaTeX `tipa` notation instead of hunting for Unicode symbols
- **Comprehensive symbol support**: All IPA consonants, vowels, and other symbols from the `tipa` chart
- **Combining diacritics**: Nasalized (`\\~`), devoiced (`\\r`), syllabic (`\\v`); the tie (`\\t`) is also available
- **Suprasegmentals**: Primary stress (`'`), secondary stress (`,`), length (`:`)
- **Automatic character splitting**: Type `SE` instead of `S E` for efficiency (spacing is necessary around characters using backslashes)

### Prosody Module

- **Prosodic structure visualization**: Draw syllable structures with onset, nucleus, and coda
- **Flexible foot structure**: Use parentheses to mark explicit foot boundaries and stress mark to identify headedness (iambs, trochees)
- **Stress marking**: Mark stressed syllables with apostrophe `'`
- **Flexible alignment**: Left or right alignment for prosodic word heads

### IPA Charts Module

- **Vowel charts**: Plot vowels on the IPA vowel trapezoid with accurate positioning
- **Consonant tables**: Display consonants in the pulmonic IPA consonant table
- **Language inventories**: Pre-defined inventories for some languages (English, Spanish, French, German, Italian, Portuguese, Japanese, Russian, Arabic, Mandarin)
- **Custom symbol sets**: Plot any combination of IPA symbols
- **Automatic positioning**: Symbols positioned according to phonetic properties (place, manner, voicing, frontness, height, roundedness)
- **Proper IPA formatting**: Voiceless/voiced pairs, grayed-out impossible articulations, minimal pair bullets for vowels
- **Scalable charts**: Adjust size to fit your document layout (scaling includes text as expected)

## Installation

### Package Repository

- `http://github.com/guilhermegarcia/phonokit`

### Package website

For the most up-to-date information about the package, vignettes and demos, visit <https://gdgarcia.ca/phonokit>.

## Usage

### IPA Transcription

```typst
// Basic transcription
#ipa("'sIRi")  // → ˈsɪɾi

// With nasalization
#ipa("\\~ E")  // → ɛ̃

// With devoicing
#ipa("\\r z")  // → z̥

// Syllabic segments 
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

**Multi-character codes**

- `\\textltailn` → ɲ
- `\\ae` → æ
- See [`tipa` chart](https://gdgarcia.ca/typst/tipachart.pdf) for complete list

**Diacritics currently supported**:

- Stress: `'` (primary), `,` (secondary)
- Length: `:` (place after segment)
- Liaison: `\\t` (place before segment)
- Devoicing: `\\r` (place before segment)
- Syllabicity: `\\v` (place before segment)
- Aspiration: `\\h` (place after segment)
- Nasal: `\\~` (place before segment)
- C cedilla: `\\c{c}` (of course, simply typing `ç` is easier depending on your keyboard layout)
- Unreleased: `\\*` (place after segment)

**Spacing**:

- Empty space: `\\s` (important if you want to transcribe sentences)

### IPA Charts

Phonokit provides functions for visualizing IPA vowel and consonant inventories with proper phonetic positioning.

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

Phonokit provides three functions for visualizing different levels of prosodic structure. The functions `syllable()`, `foot()` and `word()` below also have a `scale` argument (float) for adjusting the size of the resulting prosodic tree. Crucially, the scaling includes the tree, the text and the thickness of the lines in the tree. Furthermore, the length of each line dynamically adapts to the complexity of the representation, which results in a visually balanced figure.

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
- Geminates are automatically detected for `#foot()` and `#word()`
- For long vowels, use `vv` instead of using the length diacritic `:`

## License

MIT

## Author

**Guilherme D. Garcia**
Email: <guilherme.garcia@lli.ulaval.ca>

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.
