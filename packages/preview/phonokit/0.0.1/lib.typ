// Phonokit - Phonology toolkit for Typst
// Author: Guilherme D. Garcia
//
// A comprehensive toolkit for phonological and phonetic notation in Typst.
//
// This package provides:
// - IPA transcription with tipa-style input syntax
// - Prosodic structure visualization (syllables, feet, prosodic words)
// - IPA vowel charts (trapezoid) with language inventories
// - IPA consonant tables (pulmonic) with language inventories

// Import modules
#import "ipa.typ": ipa
#import "prosody.typ": syllable, foot, word
#import "vowels.typ": vowels
#import "consonants.typ": consonants

// Re-export IPA function
/// Convert tipa-style notation to IPA symbols
///
/// Supports:
/// - IPA consonants and vowels
/// - Combining diacritics (\\~, \\r, \\v, \\t for nasal, devoiced, voiced, tie)
/// - Suprasegmentals (' and , for primary and secondary stress; : for length)
/// - Automatic character splitting for efficiency
///
/// Example: `#ipa("'hEloU")` produces ˈhɛloʊ
///
/// Arguments:
/// - input (string): tipa-style notation
///
/// Returns: IPA symbols in Charis SIL font
#let ipa = ipa

// Re-export Prosody functions
/// Draw a single syllable's internal structure
///
/// Visualizes only the syllable (σ) level with onset, rhyme, nucleus, and coda.
///
/// Arguments:
/// - input (string): A single syllable (e.g., "ka" or "'va")
/// - scale (float): Scale factor for the diagram (default: 1.0)
///
/// Returns: CeTZ drawing of syllable structure
///
/// Example: `#syllable("man", scale: 0.8)`
#let syllable = syllable

/// Draw a foot with syllables
///
/// Visualizes foot (Σ) and syllable (σ) levels. All syllables are part of the foot.
/// Stressed syllables are marked with an apostrophe before the syllable.
///
/// Arguments:
/// - input (string): Syllables separated by dots (e.g., "ka.'va.lo")
/// - scale (float): Scale factor for the diagram (default: 1.0)
///
/// Returns: CeTZ drawing of foot structure
///
/// Example: `#foot("man.'tal", scale: 1.2)`
#let foot = foot

/// Draw a prosodic word structure with explicit foot boundaries
///
/// Visualizes prosodic word (PWd), foot (Σ), and syllable (σ) levels.
/// Use parentheses to mark foot boundaries.
/// Stressed syllables are marked with an apostrophe before the syllable.
///
/// Arguments:
/// - input (string): Syllables with optional foot markers in parentheses
/// - foot (string): "R" (right-aligned) or "L" (left-aligned) for PWd alignment (default: "R")
/// - scale (float): Scale factor for the diagram (default: 1.0)
///
/// Returns: CeTZ drawing of prosodic structure
///
/// Examples:
/// - `#word("(ka.'va).lo")` - One iamb with two syllables, one footless syllable
/// - `#word("('ka.va)", foot: "L")` - Trochee
/// - `#word("ka.va", scale: 0.7)` - Two footless syllables, smaller
#let word = word

// Re-export IPA Chart functions
/// Plot vowels on an IPA vowel trapezoid
///
/// Visualizes vowels on the IPA vowel chart (trapezoid) with proper positioning
/// based on frontness, height, and roundedness. Supports language-specific
/// inventories or custom vowel sets.
///
/// Arguments:
/// - vowel-string (string): Vowel symbols to plot, or a language name
/// - lang (string, optional): Explicit language parameter (e.g., lang: "spanish")
/// - width (float): Base width of trapezoid (default: 8)
/// - height (float): Base height of trapezoid (default: 6)
/// - rows (int): Number of horizontal grid lines (default: 3)
/// - cols (int): Number of vertical grid lines (default: 2)
/// - scale (float): Scale factor for entire chart (default: 0.7)
///
/// Returns: CeTZ drawing of IPA vowel chart with positioned vowels
///
/// Examples:
/// - `#vowels("english")` - Plot English vowel inventory
/// - `#vowels("aeiou")` - Plot specific vowels
/// - `#vowels("french", scale: 0.5)` - Smaller French vowel chart
///
/// Available languages: english, spanish, portuguese, italian, french, german,
/// japanese, mandarin, russian, arabic
#let vowels = vowels

/// Plot consonants on an IPA consonant table
///
/// Visualizes consonants on the pulmonic IPA consonant chart with proper
/// positioning by place and manner of articulation. Voiceless/voiced pairs
/// are shown left/right in each cell. Impossible articulations are grayed out.
///
/// Arguments:
/// - consonant-string (string): Consonant symbols to plot, or a language name
/// - lang (string, optional): Explicit language parameter (e.g., lang: "russian")
/// - cell-width (float): Width of each cell (default: 1.8)
/// - cell-height (float): Height of each cell (default: 1.2)
/// - label-width (float): Width of row labels (default: 3.5)
/// - label-height (float): Height of column labels (default: 1.2)
/// - scale (float): Scale factor for entire table (default: 0.7)
///
/// Returns: CeTZ drawing of IPA consonant table with positioned consonants
///
/// Examples:
/// - `#consonants("all")` - Show complete pulmonic consonant chart
/// - `#consonants("english")` - Plot English consonant inventory
/// - `#consonants("ptk")` - Plot specific consonants
/// - `#consonants("spanish", scale: 0.5)` - Smaller Spanish consonant chart
///
/// Available languages: all, english, spanish, french, german, italian,
/// japanese, portuguese, russian, arabic
#let consonants = consonants
