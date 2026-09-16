// phonokit - a toolkit to create phonological representations
// Author: Guilherme D. Garcia
//
// This package provides:
// - IPA transcription with tipa-style input syntax
// - Prosodic structure visualization (syllables, moras, feet, prosodic words)
// - Autosegmental representations and processes (features and tones)
// - IPA vowel charts (trapezoid) with language inventories
// - IPA consonant tables (pulmonic) with language inventories
// - Optimality Theory (OT) tableaux with violation marking and shading
// - Harmonic Grammar (HG) tableaux with weighted harmony calculations
// - Noisy Harmonic Grammar (NHG) tableaux with stochastic simulations
// - Maximum Entropy (MaxEnt) grammar tableaux with probability calculations
// - SPE-style feature matrices for phonological representations
// - Feature-geometry trees (Clements & Hume 1995; Sagey 1986)

// Import modules
#import "_config.typ": phonokit-init
#import "ipa.typ": *
#import "prosody.typ": *
#import "ot.typ": *
#import "hasse.typ": *
#import "extras.typ": *
#import "vowels.typ": *
#import "grids.typ": *
#import "consonants.typ": *
#import "features.typ": *
#import "sonority.typ": *
#import "autosegmental.typ": *
#import "multi-tier.typ": *
#import "sound-shift.typ": *
#import "ex.typ": ex, ex-rules
#import "intonational.typ": *
#import "geom.typ": *
#import "phonetics.typ": *

/// Initialize phonokit settings
///
/// Call this at the top of your document to configure package-wide settings.
/// Currently supports setting a custom font for all phonokit functions.
///
/// Arguments:
/// - font (string): Font name to use for IPA rendering (default: "Charis")
///
/// Example:
/// ```
/// #import "@preview/phonokit:0.5.7": *
/// #phonokit-init(font: "Libertinus Serif")
/// ```
#let phonokit-init = phonokit-init

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
/// Returns: IPA symbols in the configured font (default: Charis)
#let ipa = ipa

/// Visualize sonority profiles based on Parker (2011)
///
/// Generates a visual sonority profile for a given phonemic transcription.
/// Phonemes are mapped to a vertical sonority axis (1-13) based on Parker's
/// acoustic scale and connected to show the sonority contour of the word.
///
/// Features:
/// - Uses Parker (2011) hierarchy (e.g., Flaps > Laterals > Trills)
/// - Visualizes syllable boundaries using alternating background shading (white/gray)
/// - Automatic parsing of tipa-style input strings
///
/// Arguments:
/// - word (string): Phonemic string in tipa-style (use "." for syllable boundaries)
/// - syl (none): Legacy parameter, kept for API compatibility
/// - stressed (int, optional): Index of stressed syllable (default: none)
/// - box-size (float): Size of individual phoneme boxes (default: 0.8)
/// - scale (float): Overall scale factor for the diagram (default: 1.0)
/// - y-range (array): Vertical axis range for plotting (default: (0, 8))
/// - show-lines (bool): Connect phonemes with dashed lines (default: true)
///
/// Returns: CeTZ drawing of the sonority profile
///
/// Example:
/// ```
/// // Visualizes "par.to.me" with 3 distinct background zones
/// #sonority("par.to.me")
///
/// // Demonstrates Flap (R) > Lateral (l) ranking
/// #sonority("ka.Ra.lo")
/// ```
///
/// Note: Input is automatically truncated to the first 10 phonemes to prevent
/// visual overflow.
#let sonority = sonority

/// Create an illustrative F1/F2 vowel cloud for teaching.
///
/// Generates synthetic vowel tokens around built-in F1/F2 means and displays
/// them on an inverted F1/F2 diagram.
///
/// Arguments:
/// - vowels (string): Tipa-style/IPA vowel string or a built-in language name
///   such as `"english"`
/// - source (array, optional): Tabular data from `csv(...)` with required
///   columns `vowel`, `f1`, and `f2`; a plain `csv("...")` table with a
///   header row is accepted
/// - sd (float): Spread of synthetic tokens in Hz
/// - sd2 (float, optional): Optional separate F2 spread in Hz
/// - n (int): Number of tokens per vowel (default: 10)
/// - seed (int): Deterministic seed for token placement (default: 1)
/// - labels (bool): Show vowel labels at the means (default: true)
/// - points (bool): Show vowel tokens (default: true)
/// - centers (bool): Show explicit `+` mean markers (default: false)
/// - ellipse (bool): Show 1-SD ellipses centered on the means (default: false)
/// - ellipse-stroke (stroke or auto): Stroke for SD ellipses
///   (default: `0.8pt + luma(190)`)
/// - ellipse-fill (fill): Fill for SD ellipses (default: none)
/// - grid (bool): Show the background grid (default: true)
/// - color-by-vowel (bool): Use a color cycle by vowel category (default: true)
/// - point-size (int): Marker size for synthetic tokens (default: 50)
/// - point-color (color or auto): Override token color (default: auto)
/// - point-alpha (ratio): Token transparency (default: 20%)
/// - vowel-color (color): Color of vowel labels (default: black)
/// - vowel-size (length): Font size of vowel labels (default: 20pt)
/// - vowel-weight (str): Font weight of vowel labels (default: `"regular"`)
/// - axis-size (length): Font size of axis labels and tick labels (default: 10pt)
/// - scale (float): Overall scale factor for the figure (default: 1.0)
/// - x-label (content): X-axis label (default: `[F2 (Hz)]`)
/// - y-label (content): Y-axis label (default: `[F1 (Hz)]`)
/// - width (length): Diagram width (default: 10cm)
/// - height (length): Diagram height (default: 7cm)
///
/// Notes:
/// - In synthetic mode, ellipses visualize the user-provided spread parameters
///   (`sd`, `sd2`).
/// - In CSV mode, vowel means and ellipse sizes are computed from the observed
///   tokens in the input data.
///
/// Example:
/// ```
/// #formants("italian", scale: 0.6, ellipse: true, axis-size: 1.3em)
/// #formants(source: csv("extras/formants_sample.csv"), scale: 0.8)
/// ```
#let formants = formants

/// Draw a schematic voice onset time (VOT) timeline.
///
/// Positive values show an aspiration interval between release and voicing
/// onset, zero values align release and voicing onset, and negative values
/// show prevoicing.
///
/// Arguments:
/// - vot (number): Voice onset time in milliseconds
/// - closure (number): Closure duration in milliseconds (default: 40)
/// - vowel (number): Vowel region duration in milliseconds (default: 60)
/// - scale (float): Overall scale factor for the diagram (default: 1.0)
/// - label (auto or bool): Show the VOT value label (default: auto, equivalent
///   to true)
/// - keys (bool): Show event keys and legend (`R`, `V`, and compact interval
///   keys such as `A`; default: false)
/// - ui-lang (string): UI label language. Supported aliases: en/english,
///   fr/french, pt/portuguese (default: "en")
/// - closure-label, release-label, voicing-label, vowel-label, vot-label,
///   interval-label (auto, content, string, or none): Override individual
///   labels. `auto` uses localized defaults; `interval-label: auto` is the
///   localized aspiration label. Set `interval-label: none` to hide it
/// - interval-key (auto or content): Key used when `interval-label` does not
///   fit and `keys: true` (default: auto, usually `A` for aspiration)
/// - closure-segment, interval-segment, vowel-segment (string, content, or none):
///   Optional IPA/segment labels placed below the closure, interval, and
///   vowel regions. Strings use phonokit's IPA parser (default: none)
/// - segment-size (length): Font size for segment labels (default: 10pt)
/// - fill-closure (color): Closure region fill (default: luma(230))
/// - fill-vowel (color): Vowel region fill (default: white)
/// - fill-aspiration (color): Positive-VOT interval fill (default: luma(245))
/// - voicing (bool): Draw a schematic voicing/noise waveform (default: true)
/// - voicing-stroke (stroke or auto): Stroke for the voicing waveform (default:
///   auto)
///
/// Region labels are placed above the boxes and are shown only when their
/// localized or overridden label fits the available region width. Positive-VOT
/// interval labels use the same fit logic; when they do not fit and `keys:
/// true`, the interval key is shown in the diagram and explained in the legend.
///
/// Example:
/// ```
/// #vot(65)
/// #vot(
///   65,
///   closure-segment: "t",
///   interval-segment: "\\h",
///   vowel-segment: "\\ae",
/// )
/// #vot(-60, voicing: false)
/// #vot(-60, ui-lang: "fr")
/// ```
#let vot = vot

/// Draw a single syllable's internal structure
///
/// Visualizes only the syllable (σ) level with onset, rhyme, nucleus, and coda.
///
/// Arguments:
/// - input (string): A single syllable (e.g., "ka" or "'va")
/// - scale (float): Scale factor for the diagram (default: 1.0)
/// - symbol (array): Domain labels top-down: (σ) (default: ("σ",))
/// - distance (float, optional): Horizontal distance between segments (default: none)
///
/// Returns: CeTZ drawing of syllable structure
///
/// Example: `#syllable("\\t tS \\ae t", scale: 0.9)`
#let syllable = syllable

/// Draw a mora-based structure
///
/// Visualizes mora (μ) and syllable (σ) levels, showing how syllables
/// are decomposed into moras based on weight.
///
/// Arguments:
/// - input (string): A single syllable (e.g., "kan" or "ka")
/// - coda (bool): Whether codas contribute to weight (default: false)
/// - scale (float): Scale factor for the diagram (default: 1.0)
/// - symbol (array): Domain labels top-down: (σ, μ) (default: ("σ", "μ"))
/// - distance (float, optional): Horizontal distance between segments (default: none)
///
/// Returns: CeTZ drawing of moraic structure
///
/// Examples:
/// - `#mora("\\t tS \\ae t", coda: true)` - Moraic representation with coda weight
/// - `#mora("tR \\~ a:m", coda: true)` - Long vowel represented with two moras
#let mora = mora

/// Draw a foot with syllables
///
/// Visualizes foot (Σ) and syllable (σ) levels. All syllables are part of the foot.
/// Stressed syllables are marked with an apostrophe before the syllable.
///
/// Arguments:
/// - input (string): Syllables separated by dots (e.g., "ka.'va.lo")
/// - scale (float): Scale factor for the diagram (default: 1.0)
/// - symbol (array): Domain labels top-down: (Σ, σ) (default: ("Σ", "σ"))
/// - distance (float, optional): Horizontal distance between segments (default: none)
///
/// Returns: CeTZ drawing of foot structure
///
/// Example: `#foot("'p \\h \\ae.\\*r Is", scale: 0.9)`
#let foot = foot

/// Draw a foot with moraic structure
///
/// Visualizes foot (Σ), syllable (σ), and mora (μ) levels. Combines foot
/// structure with moraic weight representation.
/// Stressed syllables are marked with an apostrophe before the syllable.
///
/// Arguments:
/// - input (string): Syllables separated by dots (e.g., "po.'Ral")
/// - coda (bool): Whether codas contribute to weight (default: false)
/// - scale (float): Scale factor for the diagram (default: 1.0)
/// - symbol (array): Domain labels top-down: (Σ, σ, μ) (default: ("Σ", "σ", "μ"))
/// - distance (float, optional): Horizontal distance between segments (default: none)
///
/// Returns: CeTZ drawing of moraic foot structure
///
/// Examples:
/// - `#foot-mora("po.'Ral", coda: true, scale: 0.9)` - Disyllabic foot with moraic structure
/// - `#foot-mora("'po.Ra.ma", coda: true, scale: 0.9)` - Dactyl with moraic structure
#let foot-mora = foot-mora

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
/// - symbol (array): Domain labels top-down: (ω, Σ, σ) (default: ("ω", "Σ", "σ"))
/// - distance (float, optional): Horizontal distance between segments (default: none)
///
/// Returns: CeTZ drawing of prosodic structure
///
/// Examples:
/// - `#word("('po.Ra).ma", scale: 0.9)` - One foot plus one unfooted syllable
/// - `#word("('po.Ra).('ma.pa)", foot: "R", scale: 0.9)` - Two feet, right-headed PWd
#let word = word

/// Draw a prosodic word structure with moraic representation
///
/// Visualizes prosodic word (PWd), foot (Σ), syllable (σ), and mora (μ) levels.
/// Combines prosodic word structure with moraic weight representation.
/// Use parentheses to mark foot boundaries.
/// Stressed syllables are marked with an apostrophe before the syllable.
///
/// Arguments:
/// - input (string): Syllables with optional foot markers in parentheses
/// - foot (string): "R" (right-aligned) or "L" (left-aligned) for PWd alignment (default: "R")
/// - coda (bool): Whether codas contribute to weight (default: false)
/// - scale (float): Scale factor for the diagram (default: 1.0)
/// - symbol (array): Domain labels top-down: (ω, Σ, σ, μ) (default: ("ω", "Σ", "σ", "μ"))
/// - distance (float, optional): Horizontal distance between segments (default: none)
///
/// Returns: CeTZ drawing of moraic prosodic structure
///
/// Examples:
/// - `#word-mora("('po.Ra).ma", coda: true, scale: 0.9)` - Trochee with unfooted syllable
/// - `#word-mora("('po.Ra).('ma.pa)", foot: "L", coda: true, scale: 0.9)` - Two feet, left-headed PWd
#let word-mora = word-mora

/// Create a metrical grid representation for stress and rhythm analysis
///
/// Visualizes hierarchical stress levels using stacked × marks above syllables.
/// This follows metrical grid theory where each level represents a different
/// metrical prominence tier.
///
/// Supports two input formats:
/// 1. String format (simple, but not IPA-compatible):
///    - Syllables separated by dots, each ending with a stress level number
/// 2. Array format (IPA-compatible):
///    - Array of (syllable, level) tuples
///
/// Arguments:
/// - ..args: Either a single string or multiple (syllable, level) tuples
///   - String format: syllables separated by dots, each ending with stress level (e.g., "te2.ne1.see3")
///   - Tuple format: pairs of (syllable, level) passed as separate arguments
/// - ipa (bool): Automatically convert strings to IPA notation (default: true)
///
/// Returns: Table showing syllables with stacked × marks indicating stress levels
///
/// Examples:
/// - `#met-grid("bu3.tter1.fly2")` - String format
/// - `#met-grid(
///          ("b2", 3),
///          ("R \\schwar", 1),
///          ("flaI", 2),
///        )` - Array format
///
/// Note: The string format uses numbers to indicate stress levels, which conflicts
/// with IPA numeric symbols. For IPA compatibility, use the array format.
#let met-grid = met-grid


/// Plot vowels on an IPA vowel trapezoid
///
/// Visualizes vowels on the IPA vowel chart (trapezoid) with proper positioning
/// based on frontness, height, and roundedness. Supports language-specific
/// inventories, custom vowel sets, or tipa-style IPA notation.
///
/// Arguments:
/// - vowel-string (string): Vowel symbols to plot, language name, or tipa-style IPA
/// - lang (string, optional): Explicit language parameter (e.g., lang: "spanish")
/// - width (float): Base width of trapezoid (default: 8)
/// - height (float): Base height of trapezoid (default: 6)
/// - rows (int): Number of horizontal grid lines (default: 3)
/// - cols (int): Number of vertical grid lines (default: 2)
/// - scale (float): Scale factor for entire chart (default: 0.7)
/// - nasals (bool): Draw schematic nasalized copies near their oral
///   counterparts. For preset languages, this currently adds only the French
///   nasal vowels; for custom strings, only vowels explicitly nasalized in the
///   input are shown in the nasal layer (default: false)
/// - arrows (array): List of (from-vowel, to-vowel) tuples for drawing directed
///   arrows between vowel positions (e.g. diphthongs). Each vowel string accepts
///   tipa-style notation. Unknown vowels are silently skipped. (default: ())
/// - arrow-color (color): Color for arrow lines and heads (default: black)
/// - arrow-style (string): "solid" or "dashed" line style for arrows (default: "solid")
/// - curved (bool): Curve arrows with a quadratic bezier arc (default: false)
/// - shift (array): List of (vowel, x-offset, y-offset) tuples. Draws a copy of
///   the vowel symbol offset from its canonical trapezoid position by (x, y) in
///   CeTZ canvas units. If the vowel is already plotted, an additional copy is
///   drawn; otherwise it is created. Unknown vowels are silently skipped. (default: ())
/// - shift-color (color): Color for shifted vowel symbols (default: gray)
/// - shift-size (length, optional): Font size for shifted vowels; none uses the
///   same size as regular vowels (default: none)
/// - highlight (array): List of tipa strings whose background circle is highlighted (default: ())
/// - highlight-color (color): Circle color for highlighted vowels (default: luma(220))
///
/// Returns: CeTZ drawing of IPA vowel chart with positioned vowels
///
/// Examples:
/// - `#vowels("english", scale: 0.6)` - Plot English vowel inventory
/// - `#vowels("french", scale: 0.6)` - Plot French vowel inventory
/// - `#vowels("aãioõu", nasals: true)` - Add only the nasal vowels marked in the custom inventory
/// - `#vowels("french", nasals: true)` - Add the French nasal vowels
/// - `#vowels("english", arrows: (("a", "U"), ("a", "I"), ("e", "I"), ("O", "I"), ("o", "U")), curved: true)` - Diphthong trajectories
///
/// Note: Diacritics and non-vowel symbols are ignored during plotting. Nasal
/// overlays are illustrative only and are not language-specific placements.
///
/// Available languages: english, spanish, portuguese, italian, french, german,
/// japanese, russian, arabic
#let vowels = vowels

/// Plot consonants on an IPA consonant table
///
/// Visualizes consonants on the pulmonic IPA consonant chart with proper
/// positioning by place and manner of articulation. Voiceless/voiced pairs
/// are shown left/right in each cell. Impossible articulations are grayed out.
///
/// Arguments:
/// - consonant-string (string): Consonant symbols to plot, language name, or tipa-style IPA
/// - lang (string, optional): Explicit language parameter (e.g., lang: "russian")
/// - ui-lang (string): UI label language. Supported aliases: en/english, fr/french,
///   pt/portuguese (default: "en")
/// - affricates (bool): Show affricate row after fricatives (default: false)
/// - aspirated (bool): Show aspirated plosive/affricate rows (default: false)
/// - abbreviate (bool): Use abbreviated place/manner labels (default: false)
/// - simplify (bool): Automatically drop empty rows and columns (default: false)
/// - delete-cols (array): 0-indexed column indices to remove (0=Bilabial ... 10=Glottal)
/// - delete-rows (array): 0-indexed row indices to remove (0=Plosive ... 7=Lateral approximant)
/// - cell-width (float): Width of each cell (default: 1.8)
/// - cell-height (float): Height of each cell (default: 0.9)
/// - label-width (float): Width of row labels (default: 3.5)
/// - label-height (float): Height of column labels (default: 1.2)
/// - scale (float): Scale factor for entire table (default: 0.7)
///
/// Returns: CeTZ drawing of IPA consonant table with positioned consonants
///
/// Examples:
/// - `#consonants("italian", affricates: true, abbreviate: true)` - Italian inventory
/// - `#consonants("ts{ts}psS \\*r g{tS} {k \\h}", affricates: true, aspirated: true)` - Custom inventory
/// - `#consonants("english", affricates: true, simplify: true)` - Simplified English inventory
/// - `#consonants("italian", affricates: true, simplify: true, ui-lang: "fr")` - Localized labels
///
/// Notes:
/// - /w/ (labiovelar) appears in both bilabial and velar columns when /ɰ/ is not present; otherwise only bilabial
/// - Affricates appear in a separate row when affricates: true (displayed without tie bars)
/// - Aspirated consonants appear in separate rows when aspirated: true (e.g., "Plosive (aspirated)")
/// - Both aspirated consonants and affricates must be wrapped with curly brackets: {p \\h} will produce an aspirated p, and {ts} will produce a voiceless alveolar affricate
/// - Diacritics and non-consonant symbols are ignored during plotting
///
/// Available languages: all, english, spanish, french, german, italian,
/// japanese, portuguese, russian, arabic
#let consonants = consonants

/// Create an Optimality Theory tableau
///
/// Generates a formatted OT tableau with candidates, constraints, violations,
/// and shading for irrelevant cells after fatal violations.
///
/// Arguments:
/// - input (string or content): The input form (can use IPA notation)
/// - candidates (array): Array of candidate forms (strings or content)
/// - constraints (array): Array of constraint names (strings)
/// - violations (array): 2D array of violation strings (use "*" for violations, "!" for fatal)
/// - winner (int): Index of the winning candidate (0-indexed)
/// - dashed-lines (array): Indices of constraints to show with dashed borders (optional)
/// - scale (number, optional): Scale factor for the tableau (default: none)
/// - shade (bool): Whether cells should be shaded after fatal violations (default: true)
/// - prosody-scale (float): Scale factor for prosodic structures in candidates (default: 0.5)
/// - letters (bool): Use letter labels (a, b, c, ...) for candidates (default: false)
/// - gloss (string, optional): Gloss text displayed below the input (default: none)
///
/// Returns: Table showing OT tableau with winner marked by ☞
///
/// Example:
/// ```
/// #tableau(
///   input: "kraTa",
///   candidates: ("kra.Ta", "ka.Ta", "ka.ra.Ta"),
///   constraints: ("Max", "Dep", "*Complex"),
///   violations: (
///     ("", "", "*"),
///     ("*!", "", ""),
///     ("", "*!", ""),
///   ),
///   winner: 0, // <- Position of winning cand
///   dashed-lines: (0,) // <- Note the comma
/// )
/// ```
#let tableau = tableau

/// Create a Maximum Entropy (MaxEnt) grammar tableau
///
/// Generates a MaxEnt tableau showing harmony scores, probabilities,
/// and optional probability visualizations.
///
/// Arguments:
/// - input (string or content): The input form
/// - candidates (array): Array of candidate forms
/// - constraints (array): Array of constraint names
/// - weights (array): Array of constraint weights (numbers)
/// - violations (array): 2D array of violation counts (numbers)
/// - visualize (bool): Whether to show probability bars (default: true)
/// - sort (bool): Whether to sort candidates by probability, most to least (default: false)
/// - scale (number, optional): Scale factor for the tableau (default: none)
/// - letters (bool): Use letter labels (a, b, c, ...) for candidates (default: false)
///
/// Returns: Table showing MaxEnt tableau with H(x), P*(x), and P(x) columns
///
/// Example:
/// ```
/// #maxent(
///   input: "kraTa",
///   candidates: ("[kra.Ta]", "[ka.Ta]", "[ka.ra.Ta]"),
///   constraints: ("Max", "Dep", "Complex"),
///   weights: (2.5, 1.8, 1),
///   violations: (
///     (0, 0, 1),
///     (1, 0, 0),
///     (0, 1, 0),
///   ),
///   visualize: true,
/// )
/// ```
#let maxent = maxent

/// Create a Harmonic Grammar (HG) tableau
///
/// Generates an HG tableau showing harmony scores calculated from
/// weighted constraint violations. HG is deterministic: the candidate
/// with the highest harmony wins.
///
/// Arguments:
/// - input (string or content): The input form
/// - candidates (array): Array of candidate forms
/// - constraints (array): Array of constraint names
/// - weights (array): Array of constraint weights (numbers)
/// - violations (array): 2D array of violation counts (negative numbers)
/// - scale (number): Optional scale factor (default: auto-scales for >6 constraints)
/// - letters (bool): Use letter labels (a, b, c, ...) for candidates (default: false)
///
/// Returns: Table showing HG tableau with constraint weights and h(y) harmony column
///
/// Example:
/// ```
/// #hg(
///  input: "kraTa",
///  candidates: ("[kra.Ta]", "[ka.Ta]", "[ka.ra.Ta]"),
///  constraints: ("Max", "Dep", "*Complex"),
///  weights: (2.5, 1.8, 1),
///  violations: (
///    (0, 0, -1),
///    (-1, 0, 0),
///    (0, -1, 0),
///  ),
/// )
/// ```
///
/// Note: h(y) = Σ(weight × violation). Candidate with highest (least negative) harmony wins.
#let hg = hg

/// Create a Noisy Harmonic Grammar (NHG) tableau with symbolic noise
///
/// Pedagogical version showing noise as symbolic formulas (e.g., "-n₁").
/// Useful for teaching how noise affects harmony calculations.
///
/// Arguments:
/// - input (string or content): The input form
/// - candidates (array): Array of candidate forms
/// - constraints (array): Array of constraint names
/// - weights (array): Array of constraint weights
/// - violations (array): 2D array of violation counts (negative numbers)
/// - probabilities (array): Optional array of probability values to display
/// - scale (number): Scale factor (default: auto-scales for >6 constraints)
/// - letters (bool): Use letter labels (a, b, c, ...) for candidates (default: false)
///
/// Returns: Table with h(y), ε(y) (symbolic), and optional P(y) columns
///
/// Example:
/// ```
/// #nhg-demo(
///  input: "kraTa",
///  candidates: ("[kra.Ta]", "[ka.Ta]", "[ka.ra.Ta]"),
///  constraints: ("Max", "Dep", "*Complex"),
///  weights: (2.5, 1.8, 1),
///  violations: (
///    (0, 0, -1),
///    (-1, 0, 0),
///    (0, -1, 0),
///  ),
///  probabilities: (0.673, 0.08, 0.247),
///)
/// ```
#let nhg-demo = nhg-demo

/// Create a Noisy Harmonic Grammar (NHG) tableau with Monte Carlo simulation
///
/// Samples noise from N(0,1), calculates probabilities via simulation.
/// Noise is added to constraint weights, and the candidate with highest
/// noisy harmony wins each trial.
///
/// Arguments:
/// - input (string or content): The input form
/// - candidates (array): Array of candidate forms
/// - constraints (array): Array of constraint names
/// - weights (array): Array of constraint weights
/// - violations (array): 2D array of violation counts (negative numbers)
/// - num-simulations (int): Number of Monte Carlo trials (default: 1000)
/// - seed (int, optional): Random seed for reproducibility (default: none)
/// - show-epsilon (bool): Whether to show epsilon column (default: true)
/// - scale (number): Scale factor (default: auto-scales for >6 constraints)
/// - letters (bool): Use letter labels (a, b, c, ...) for candidates (default: false)
///
/// Returns: Table with h(y), optional ε(y) (one sample), and P(y) (from simulation)
///
/// Example:
/// ```
/// #nhg(
///   input: "kraTa",
///   candidates: ("[kra.Ta]", "[ka.Ta]", "[ka.ra.Ta]"),
///   constraints: ("Max", "Dep", "*Complex"),
///   weights: (2.5, 1.8, 1),
///   violations: (
///     (0, 0, -1),
///     (-1, 0, 0),
///     (0, -1, 0),
///   ),
/// )
/// ```
///
/// Note: Probabilities are estimated empirically. More simulations = more accurate
/// but slower compilation. Default 1000 is usually sufficient.
#let nhg = nhg

/// Create a Hasse diagram for Optimality Theory constraint rankings
///
/// Generates a visual representation of the partial order of constraint rankings.
///
/// Features:
/// - Supports partial orders (not all constraints need to be ranked)
/// - Handles floating constraints with no ranking relationships
/// - Supports dashed and dotted line styles for different edge types
/// - Auto-scales for complex hierarchies
///
/// Arguments:
/// - rankings (array): Array of tuples representing rankings:
///   - Three-element tuple `(A, B, level)` means A dominates B, and A is at stratum `level` (REQUIRED)
///   - Four-element tuple `(A, B, level, style)` means A dominates B, A at stratum `level`, with line `style`
///   - Single-element tuple `(A,)` means A is floating (no ranking)
///   - Line styles: "solid" (default), "dashed", "dotted"
///   - Note: Level specification is REQUIRED for all edges to ensure proper stratification
/// - scale (number or auto): Scale factor for diagram (default: auto-scales based on complexity)
/// - node-spacing (number): Horizontal spacing between nodes (default: 2.5)
/// - level-spacing (number): Vertical spacing between levels (default: 1.5)
///
/// Returns: A Hasse diagram showing the constraint hierarchy
///
/// Examples:
/// ```
/// // Basic scenario
/// #hasse(
///   (
///     ("*Complex", "Max", 0),
///     ("*Complex", "Dep", 0),
///     ("Onset", "Max", 0),
///     ("Onset", "Dep", 0),
///     ("Max", "NoCoda", 1),
///     ("Dep", "NoCoda", 1),
///   ),
///   scale: 0.9
/// )
/// ```
#let hasse = hasse

// SPE/Feature function
/// Create a feature matrix in SPE notation
///
/// Displays phonological features in a vertical matrix with square brackets,
/// commonly used in Sound Pattern of English (SPE) style representations.
///
/// Arguments:
/// - ..args: Features as separate arguments or comma-separated string
///
/// Returns: Mathematical vector notation with features
///
/// Examples:
/// - `#feat("+cons", "-son", "+voice")` - Three features as separate args
/// - `#feat("+cons,-son,+voice")` - Three features as comma-separated string
#let feat = feat

/// Display complete distinctive feature matrix for an IPA segment
///
/// Takes an IPA symbol and displays its complete distinctive feature specification
/// from Hayes (2009) Introductory Phonology. Features are shown in SPE-style
/// vertical matrix notation.
///
/// Arguments:
/// - segment (string): IPA symbol using Unicode or tipa-style notation
/// - all (bool): Show all features including unspecified (0) values (default: false)
/// - ui-lang (string): UI label language. Supported aliases: en/english, fr/french,
///   pt/portuguese (default: "en")
///
/// Returns: Complete feature matrix in SPE notation
///
/// Examples:
/// - `#feat-matrix("p")` - Shows feature matrix for /p/
/// - `#feat-matrix("\\ae")` - Shows feature matrix for /æ/
/// - `#feat-matrix("\\t tS")` - Affricate using tipa-inspired notation
/// - `#feat-matrix("i", all: true)` - Shows all features including 0 values
///
/// Note: Based on Hayes (2009) feature system. Includes manner, laryngeal,
/// and place features for consonants; syllabic, height, backness, and rounding
/// features for vowels.
#let feat-matrix = feat-matrix

/// Create an autosegmental representation
///
/// Generates an autosegmental representation visualizing features or tones
/// on a separate tier from segments. Supports spreading (one-to-many associations),
/// delinking, multiple linking, and floating features/tones. Ideal for illustrating
/// phonological processes like tone spreading, vowel harmony, or feature geometry.
///
/// Arguments:
/// - segments (array): Segment strings (use "" for empty timing slots)
/// - features (array): Feature/tone labels corresponding to segments (use "" for no association)
/// - links (array): Tuples of (feature-index, segment-index) for association lines (default: ())
/// - delinks (array): Tuples of (feature-index, segment-index) for delinking marks (default: ())
/// - spacing (float): Horizontal spacing between segments (default: 1.5)
/// - arrow (bool): Show arrow between representations (for process diagrams) (default: false)
/// - tone (bool): Whether the representation shows tones vs features (default: false)
/// - highlight (array): Indices of segments to highlight with background color (default: ())
/// - float (array): Indices of floating (unassociated) features/tones (default: ())
/// - multilinks (array): Tuples of (feature-index, (seg1, seg2, ...)) for one-to-many links (default: ())
/// - baseline (ratio): Vertical alignment of the box (default: 40%)
/// - gloss (string): Optional gloss text below baseline (default: "")
/// - dash (string): Line style for dashed association lines (default: "dashed")
///
/// Returns: Autosegmental representation
///
/// Examples:
/// ```
/// // Basic tone spreading: L tone spreads to multiple syllables
/// #autoseg(
///   ("a", "", "g", "a", "f", "i"),
///   features: ("L", "", "", "H", "", ""),
///   links: ((0, 3),),
///   delinks: ((3, 3),),
///   tone: true,
///   spacing: 0.5,
///   multilinks: ((3, (3, 5)),),
/// )
///
/// // Feature spreading with arrow (showing phonological process)
/// #autoseg(
///   ("t", "a", "n"),
///   features: ("+nasal", "", ""),
///   links: ((0, 0),),
///   arrow: true,
/// )
///
/// // Floating tone with highlighting
/// #autoseg(
///   ("m", "a", "m", "a"),
///   features: ("H", "L", "", ""),
///   float: (0,),
///   highlight: (1, 3),
///   tone: true,
/// )
/// ```
///
/// Note: Index numbering is 0-based. Use empty strings "" in segments or features
/// arrays to create timing slots without content or features without associations.
#let autoseg = autoseg

/// Create a multi-tier phonological representation
///
/// Draws N-tier diagrams for CV phonology, skeletal tier structures, and other
/// multi-level representations. Each tier is a row of labels connected by
/// association lines. Supports auto-linking, floating elements, highlighting,
/// dashed lines, and delinking marks.
///
/// Arguments:
/// - levels (array): Array of arrays; each inner array is a tier of label strings (use "" for empty positions).
///   Entries can be "label", ("label", col) for fractional columns, or ("label", col, level) for fractional levels.
/// - links (array): Extra solid lines as either `((level1, col1), (level2, col2))`
///   tuples or `("name1", "name2")` pairs (default: ())
/// - dashed (array): Dashed lines as either coordinate tuples or string-name pairs (default: ())
/// - delinks (array): Cross marks on connections as either coordinate tuples or string-name pairs (default: ())
/// - arrows (array): Rectangular-path arrows as either coordinate tuples or string-name pairs (default: ()).
///   Top-level arrows arc above; bottom-level arrows arc below. Arrowhead at destination.
/// - arrow-delinks (array): Indices of arrows that should have a delink mark (||) at the midpoint (default: ())
/// - float (array): Positions excluded from auto-linking as `(level, col)` tuples or `"name"` strings (default: ())
/// - highlight (array): Positions with circle highlight as `(level, col)` tuples or `"name"` strings (default: ())
/// - ipa (array): Level indices whose labels should be rendered as IPA (default: ())
/// - tier-labels (array): Labels for tiers as (level, "label") tuples, placed to the right (default: ())
/// - spacing (float): Horizontal spacing between columns (default: 1.5)
/// - level-spacing (float): Vertical spacing between tiers (default: 1.2)
/// - stroke-width (length): Line thickness (default: 0.05em)
/// - baseline (string): Vertical alignment (default: 40%)
/// - scale (float): Uniform scale factor (default: 1.0)
/// - show-grid (bool): Show background grid for debugging layout (default: false)
///
/// Returns: Multi-tier phonological representation
///
/// Example:
/// ```
/// // From Goad (2012)
/// #multi-tier(
///   levels: (
///     ("O", "R", "", "O", "R", "O", "R"),
///     ("", "N1", "", "", "N2", "", "N3"),
///     ("", "x", "x", "x", "x", "x", "x"),
///     ("", "", "s", "t", "E", "m", ""),
///   ),
///   links: (
///     ("r2", "x2"),
///   ),
///   ipa: (3,),
///   arrows: (
///     ("t1", "s1"),
///     ("r2", "r1"),
///   ),
///   arrow-delinks: (
///     (1,)
///   ),
///   spacing: 1,
/// )
/// ```
///
/// Note: Trailing digits in labels are automatically rendered as subscripts
/// (e.g., "O1" becomes O₁). Standalone "x" is rendered as "×" (multiplication sign).
/// Non-empty labels also receive automatic reference names in reading order
/// (e.g., `sigma1`, `sigma2`, `x3`), which can be used in `links`, `dashed`,
/// `delinks`, `float`, `highlight`, and `arrows`.
#let multi-tier = multi-tier

/// Create free-positioned sound-shift diagrams
///
/// Draws IPA labels at arbitrary 2D positions and connects them with arrows.
/// This is useful for historical or schematic shift diagrams that are awkward
/// to represent in an IPA trapezoid.
///
/// Arguments:
/// - nodes (array): Array of dictionaries describing nodes. Each node needs
///   `at: (x, y)` and `label:`. When `label` is a string, it also serves as
///   the node identifier by default. Use `id:` only when labels are duplicated
///   or when the visible label should differ from the reference key.
/// - arrows (array): Array of arrow specs. Each arrow can be a `(from, to)`
///   tuple or a dictionary with `from:` and `to:`. Endpoints can be node ids
///   or raw coordinate pairs.
/// - highlights (array): Node ids or coordinate pairs to highlight with a
///   background circle (default: ())
/// - node-size (length): Default IPA font size for nodes (default: 2.2em)
/// - text-fill (color): Default node color (default: black)
/// - highlight-fill (fill): Default node/highlight fill (default: `luma(230)`)
/// - highlight-radius (float): Default circle radius in canvas units (default: 0.42)
/// - arrow-color (color): Default arrow color (default: black)
/// - arrow-style (str): Default arrow style: `"solid"`, `"dashed"`, or `"dotted"`
/// - arrow-width (length): Default arrow stroke width (default: 0.8pt)
/// - arrow-size (float): Default arrowhead scale (default: 1.0)
/// - curved (bool): Curve arrows by default (default: false)
/// - curve (float): Default curvature multiplier for curved arrows (default: 0.45)
/// - scale (float): Uniform diagram scale factor (default: 1.0)
///
/// Returns: A CeTZ-based sound-shift diagram
///
/// Example:
/// ```
/// #sound-shift(
///   nodes: (
///     (label: "I", at: (-4.2, 2.8)),
///     (label: "E", at: (-1.9, 1.0)),
///     (label: "2", at: (0.9, 1.0)),
///     (label: "O", at: (3.8, 1.0)),
///     (label: "A", at: (2.4, -1.5)),
///     (label: "\\ae", at: (-1.0, -1.5)),
///   ),
///   arrows: (
///     ("E", "2"),
///     ("2", "O"),
///     ("O", "A"),
///     ("A", "\\ae"),
///     ("I", "E"),
///     (from: "\\ae", to: "I", curved: true, curve: 0.28),
///   ),
///   scale: 0.7,
/// )
/// ```
#let sound-shift = sound-shift

/// Create a numbered linguistic example
///
/// Generates numbered examples (1), (2), etc. similar to linguex in LaTeX.
/// Wrap content directly for a single example, or use list syntax for
/// automatically lettered sub-examples. Use `labels` to make individual
/// sub-examples referenceable.
///
/// Arguments:
/// - body (content): The example content
/// - number-dy (length): Vertical offset for the number (optional; default: 0.4em)
/// - caption (string): Caption for outline (hidden in document; optional)
/// - title (string, optional): Title for the example (default: none)
/// - labels (array): Array of labels for sub-examples (default: ())
/// - columns (array): Column widths for data columns (default: ())
///
/// Returns: Numbered example that can be labeled and referenced
///
/// Example:
/// ```
/// #ex(caption: "A phonology example", labels: (<ex-anba>, <ex-anka>), columns: (5em, 2em, 5em))[
///   - #ipa("/anba/") & #a-r & #ipa("[amba]")
///   - #ipa("/anka/") & #a-r & #ipa("[aNka]")
/// ] <phon-ex>
/// ```
#let ex = ex

/// Show rules for linguistic examples
///
/// Apply this to enable proper reference formatting for ex().
/// References render as (1), (1a), (1b), etc.
///
/// Usage: `#show: ex-rules`
#let ex-rules = ex-rules

/// Arrow symbols for phonological rules and processes
///
/// Convenience symbols for showing derivations, mappings, and processes.
/// All arrows use New Computer Modern font for consistent styling.
///
/// Available arrows:
/// - `#a-r` → right arrow
/// - `#a-l` ← left arrow
/// - `#a-u` ↑ up arrow
/// - `#a-d` ↓ down arrow
/// - `#a-lr` ↔ bidirectional arrow
/// - `#a-ud` ↕ vertical bidirectional arrow
/// - `#a-sr` ↝ squiggly right arrow
/// - `#a-sl` ↜ squiggly left arrow
/// - `#a-r-large` → large right arrow with horizontal spacing
///
/// Example: `#ipa("/anba/") #a-r #ipa("[amba]")` produces /anba/ → [amba]
#let a-r = a-r
#let a-l = a-l
#let a-u = a-u
#let a-d = a-d
#let a-lr = a-lr
#let a-ud = a-ud
#let a-sr = a-sr
#let a-sl = a-sl
#let a-r-large = a-r-large

/// Upright Greek symbols for phonological notation
///
/// Convenience bindings for commonly used Greek letters in phonology.
/// These render upright in text mode (unlike math-mode `$sigma$` which italicizes).
///
/// Lowercase:
/// - `#alpha` α, `#beta` β, `#gamma` γ, `#delta` δ
/// - `#lambda` λ, `#mu` μ, `#phi` φ, `#pi` π
/// - `#sigma` σ, `#tau` τ, `#omega` ω
///
/// Uppercase:
/// - `#cap-sigma` Σ (foot), `#cap-phi` Φ (phonological phrase), `#cap-omega` Ω (utterance)
///
/// Example: `The syllable #sigma contains an onset and a rhyme.`
#let alpha = alpha
#let beta = beta
#let gamma = gamma
#let delta = delta
#let lambda = lambda
#let mu = mu
#let phi = phi
#let pi = pi
#let sigma = sigma
#let tau = tau
#let omega = omega
#let cap-phi = cap-phi
#let cap-sigma = cap-sigma
#let cap-omega = cap-omega

/// Create an underline blank for fill-in exercises or SPE rules
///
/// Generates a horizontal line (underline) useful for worksheets,
/// exercises, or indicating missing/redacted content.
///
/// Arguments:
/// - width (length): Width of the blank line (default: 2em)
///
/// Returns: A box with bottom stroke
///
/// Example: `The word #blank() means "house".`
#let blank = blank

/// Mark extrametrical content with angle brackets
///
/// Wraps content in ⟨angle brackets⟩ to indicate extrametricality
/// in metrical phonology representations.
///
/// Arguments:
/// - content: The content to mark as extrametrical
///
/// Returns: Content wrapped in ⟨⟩
///
/// Example: `#extra[tion]` produces ⟨tion⟩
#let extra = extra

/// Place a ToBI intonation label above the current inline text position
///
/// Designed to be placed inline immediately after the syllable or word being annotated.
/// The label floats above the text at the insertion point, optionally connected by
/// a vertical stem.
///
/// Arguments:
/// - label (string): ToBI label, e.g., "*L", "H%", "L+H*", "!H*"
/// - line (boolean): draw a vertical stem connecting label to text (default: true)
/// - height (length): stem length — controls how far above the text the label sits (default: 2em)
/// - lift (length): gap between stem bottom and text baseline (default: 0.8em)
/// - gap (length): horizontal gap around the annotation (default: 0.22em)
/// - en-dash (bool): render dashes as en-dashes instead of non-breaking hyphens (default: true)
///
/// Example:
/// ```
/// You're a we#int("*L")rewolf?#h(2em)#int("H%", line: false)
/// ```
#let int = int

/// Draw a feature-geometry tree for a consonant or vocoid
///
/// Produces a hierarchical diagram following Clements & Hume (1995)
/// or Sagey (1986). All feature nodes are optional; parent nodes are inferred
/// automatically from their children.
///
/// Use `ph` to load a built-in segment preset and optionally override individual
/// features. The preset label (e.g. "/i/") is shown above the root unless
/// `segment` is given.
///
/// Arguments:
/// - ph (str): Segment preset key in tipa-style notation. Supported segments
///   include common vowels (a e i o u E O I U y W 7 \o \oe 2 A 6 @ 1 0 \ae)
///   and consonants (p b t d k g f v s z S Z n m N \N j h ? T D x G F B V M
///   \:t \:d \:s \:z \:n r l J C \T). Wrap in slashes/brackets to override the
///   auto segment label: `ph: "/a/"`.
/// - model (str): `"ch"` (default) for Clements & Hume 1995 (aperture nodes for
///   height); `"sagey"` for Sagey 1986 (dorsal sub-features for height/backness,
///   `[round]` under labial). Affects preset vowels only; consonant presets are
///   identical in both models.
/// - ui-lang (string): UI label language. Supported aliases: en/english, fr/french,
///   pt/portuguese (default: "en")
/// - root (array): Root matrix features, e.g. `("+son", "-vocoid")`.
/// - laryngeal (bool): Show "laryngeal" class node explicitly.
/// - nasal (bool, str): `[nasal]`. Values: `true` → `[nasal]`,
///   `"+"` → `[+nasal]`, `"-"` → `[−nasal]`.
/// - spread (bool): `[spread glottis]` under laryngeal.
/// - constricted (bool): `[constricted glottis]` under laryngeal.
/// - voice (bool, str): `[voice]` under laryngeal. Same sign convention as `nasal`.
/// - continuant (bool, str): `[continuant]` under oral cavity. Same sign convention.
///   Pass an array of two values for affricates: `continuant: ("-", "+")`.
/// - labial (bool, array): `[labial]`. Array adds sub-features:
///   `labial: ("round",)`.
/// - coronal (bool, array): `[coronal]`. Array replaces `anterior`/`distributed`:
///   `coronal: ("+ant", "-distr")`.
/// - anterior (bool, str): `[anterior]` under coronal. Same sign convention.
/// - distributed (bool): `[distributed]` under coronal.
/// - dorsal (bool, array): `[dorsal]`. Array adds sub-features (Sagey-style):
///   `dorsal: ("+hi", "-back")`.
/// - radical (bool): `[rad]` (pharyngeal/radical place).
/// - vocalic (bool): Show "vocalic" class node (vocoid branch).
/// - vplace (bool): Show "V-place" under vocalic. Inferred automatically when
///   vocalic is active and any place feature is supplied.
/// - aperture (bool, array): "aperture" node under vocalic (CH model). Array of
///   up to 3 values controls `[open1]`/`[open2]`/`[open3]`:
///   `aperture: ("-", "+", "-")` → close-mid height.
/// - tense (bool, str): `[tense]` under vocalic. Same sign convention as `nasal`.
/// - scale (number): Uniform scale factor (default: 1.0).
/// - position (array): Manual layout tweaks. Each entry: `("node-key", dx, dy)`.
///   Node keys are bare argument names, e.g. `"continuant"`, `"oral-cavity"`.
/// - delinks (array): Node keys whose line to their parent is replaced with a
///   delink mark, e.g. `delinks: ("c-place",)`.
/// - segment (content): Label shown above root. Defaults to the `ph` value
///   wrapped in slashes when `ph` is set.
/// - prefix (string): Prefix text before the segment label (default: "")
/// - suffix (string): Suffix text after the segment label (default: "")
/// - highlight (array): Node names to highlight; all others are dimmed.
/// - timing (auto, false, array, or string): Timing tier specification. `auto` infers
///   from `ph` (e.g., long vowels get two timing slots), `false` hides the tier (default: auto)
///
/// Returns: CeTZ drawing of the feature-geometry tree
///
/// Examples:
/// ```
/// // Preset segment
/// #geom(ph: "i")
///
/// // Manual consonant: voiceless alveolar stop
/// #geom(root: ("-son", "-approx", "-vocoid"),
///        coronal: true, anterior: "+", voice: "-", continuant: "-",
///        segment: "/t/")
///
/// // Sagey-model vowel /y/
/// #geom(ph: "y", model: "sagey", scale: 1.2)
/// ```
#let geom = geom

/// Draw two or more feature-geometry trees side by side with optional inter-tree arrows
///
/// Each tree is specified as a spec dict (the same keys as `geom()`, all optional).
/// The `model` and `scale` parameters apply uniformly to all trees.
///
/// Cross-tree arrows connect nodes by their anchor names. Node names are formed
/// by lowercasing the argument name, replacing spaces with hyphens, and appending
/// the 1-based tree index: `"labial1"`, `"oral-cavity2"`, `"c-place1"`.
///
/// Arguments:
/// - ..trees (arguments): Positional spec dicts, one per tree. Each may include
///   a `ph` key to load a preset, plus any `geom()` keys to override features.
///   A per-tree `scale` key (number) scales that tree's coordinates and font
///   size relative to the group `scale`.
/// - arrows (array): Cross-tree arrows. Each entry is either `(from, to)` or a
///   dict `(from: str, to: str, color: color, ctrl: (number, number))`.
///   - `ctrl`: two Y-lifts `(lift1, lift2)`, one per endpoint. Positive lifts
///     the departure upward; negative dips the arrival below the target.
///     Overrides `curved` when set.
///   All keys except `from`/`to` are optional.
/// - gap (number): Canvas-unit gap between trees (default: 1.5).
/// - scale (number): Uniform scale factor for the whole group (default: 1.0).
/// - ui-lang (string): UI label language. Supported aliases: en/english, fr/french,
///   pt/portuguese (default: "en")
/// - model (str): `"ch"` (default) or `"sagey"`. Applies to all trees.
/// - position (array): Layout tweaks. Each entry: `("node-key-with-index", dx, dy)`,
///   e.g. `("continuant1", -0.2, 0.3)`. Arrows follow the adjusted positions.
/// - delinks (array): Node anchor names (with tree index) whose parent line is
///   replaced with a delink mark, e.g. `delinks: ("c-place1",)`.
/// - curved (bool): Draw arrows as obstacle-avoiding Bézier curves (default: false).
/// - highlight (array): Node anchor names to highlight; all others are dimmed.
///
/// Returns: CeTZ drawing of all trees in one canvas
///
/// Example:
/// ```
/// // Spreading: nasal spreading from n to a
/// #geom-group(
/// (ph: "a"),
/// (ph: "n"),
/// arrows: ((from: "nasal2", to: "root1", ctrl: (1.1, -1.5)),),
/// curved: true,
/// )
/// ```
#let geom-group = geom-group
