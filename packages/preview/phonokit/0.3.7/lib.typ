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
#import "ex.typ": *

/// Initialize phonokit settings
///
/// Call this at the top of your document to configure package-wide settings.
/// Currently supports setting a custom font for all phonokit functions.
///
/// Arguments:
/// - font (string): Font name to use for IPA rendering (default: "Charis SIL")
///
/// Example:
/// ```
/// #import "@preview/phonokit:0.3.7": *
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
/// Returns: IPA symbols in the configured font (default: Charis SIL)
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

/// Draw a single syllable's internal structure
///
/// Visualizes only the syllable (σ) level with onset, rhyme, nucleus, and coda.
///
/// Arguments:
/// - input (string): A single syllable (e.g., "ka" or "'va")
/// - scale (float): Scale factor for the diagram (default: 1.0)
/// - symbol (array): Domain labels top-down: (σ) (default: ("σ",))
///
/// Returns: CeTZ drawing of syllable structure
///
/// Example: `#syllable("man", scale: 0.8)`
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
///
/// Returns: CeTZ drawing of moraic structure
///
/// Examples:
/// - `#mora("kan")` - CVN syllable with one mora (coda doesn't count)
/// - `#mora("kan", coda: true)` - CVN syllable with two moras (coda counts)
/// - `#mora("ka")` - CV syllable with one mora
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
///
/// Returns: CeTZ drawing of foot structure
///
/// Example: `#foot("man.'tal", scale: 1.2)`
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
///
/// Returns: CeTZ drawing of moraic foot structure
///
/// Examples:
/// - `#foot-mora("po.'Ral", coda: true)` - Disyllabic foot with moraic structure
/// - `#foot-mora("'po.Ra.ma")` - Dactyl with moraic structure
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
///
/// Returns: CeTZ drawing of prosodic structure
///
/// Examples:
/// - `#word("(ka.'va).lo")` - One iamb with two syllables, one footless syllable
/// - `#word("('ka.va)", foot: "L")` - Trochee
/// - `#word("ka.va", scale: 0.7)` - Two footless syllables, smaller
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
///
/// Returns: CeTZ drawing of moraic prosodic structure
///
/// Examples:
/// - `#word-mora("('po.Ra).ma", coda: true)` - Trochee with unfooted syllable
/// - `#word-mora("('po.Ra).('ma.pa)", foot: "L")` - Two feet, left-headed PWd
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
/// - `met-grid(
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
///
/// Returns: CeTZ drawing of IPA vowel chart with positioned vowels
///
/// Examples:
/// - `#vowels("english")` - Plot English vowel inventory
/// - `#vowels("aeiou")` - Plot specific vowels
/// - `#vowels("i e E a o O u")` - Plot vowels using tipa-style notation
/// - `#vowels("french", scale: 0.5)` - Smaller French vowel chart
///
/// Note: Diacritics and non-vowel symbols are ignored during plotting
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
/// - affricates (bool): Show affricate row after fricatives (default: false)
/// - aspirated (bool): Show aspirated plosive/affricate rows (default: false)
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
/// - `#consonants("T D s z S Z")` - Plot consonants using tipa-style notation
/// - `#consonants("t \\t s d \\t z", affricates: true)` - Show affricates row
/// - `#consonants("spanish", scale: 0.5)` - Smaller Spanish consonant chart
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
/// - shade (bool): Whether cells should be shaded after fatal violations (default: true)
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
///   dashed-lines: (1,) // <- Note the comma
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
///   visualize: true  // Show probability bars (default)
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
///
/// Returns: Table showing HG tableau with constraint weights and h(y) harmony column
///
/// Example:
/// ```
/// #hg(
///  input: "kraTa",
///  candidates: ("[kra.Ta]", "[ka.Ta]", "[ka.ra.Tu]"),
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
///
/// Returns: Table with h(y), ε(y) (symbolic), and optional P(y) columns
///
/// Example:
/// ```
/// #nhg-demo(
///  input: "kraTa",
///  candidates: ("[kra.Ta]", "[ka.Ta]", "[ka.ra.Tu]"),
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
/// - seed (int): Random seed for reproducibility (default: 12345)
/// - show-epsilon (bool): Whether to show epsilon column (default: true)
/// - scale (number): Scale factor (default: auto-scales for >6 constraints)
///
/// Returns: Table with h(y), optional ε(y) (one sample), and P(y) (from simulation)
///
/// Example:
/// ```
/// #nhg(
///   input: "kraTa",
///   candidates: ("[kra.Ta]", "[ka.Ta]", "[ka.ra.Tu]"),
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
/// - spacing (float): Horizontal spacing between segments (default: 0.8)
/// - arrow (bool): Show arrow between representations (for process diagrams) (default: false)
/// - tone (bool): Whether the representation shows tones vs features (default: false)
/// - highlight (array): Indices of segments to highlight with background color (default: ())
/// - float (array): Indices of floating (unassociated) features/tones (default: ())
/// - multilinks (array): Tuples of (feature-index, (seg1, seg2, ...)) for one-to-many links (default: ())
/// - baseline (string): Optional baseline text below segments (default: "")
/// - gloss (string): Optional gloss text below baseline (default: "")
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

/// Create a numbered linguistic example
///
/// Generates numbered examples (1), (2), etc. similar to linguex in LaTeX.
/// Use with tables and subex-label() for aligned, labelable sub-examples.
///
/// Arguments:
/// - body (content): The example content (typically a table)
/// - number-dy (length): Vertical offset for the number (optional; default: 0.4em)
/// - caption (string): Caption for outline (hidden in document; optional)
///
/// Returns: Numbered example that can be labeled and referenced
///
/// Example:
/// ```
/// #ex(caption: "A phonology example")[
///   #table(
///     columns: 3, // <- where we may specify widths
///     stroke: none,
///     align: left,
///     [#ipa("/anba/")], [#a-r], [#ipa("[amba]")],
///     [#ipa("/anka/")], [#a-r], [#ipa("[aNka]")],
///   )
/// ] <ex-phon1>
///
/// See @ex-phon1.
/// ```
#let ex = ex

/// Create a sub-example label for use in tables
///
/// Generates automatic lettering (a., b., c., ...) for table rows.
/// Place in the first column of each row and attach a label after it.
///
/// Returns: Labelable letter marker (a., b., c., ...)
///
/// Example:
/// ```
/// #ex(caption: "A phonology example")[
///   #table(
///     columns: 4, // <- where we may specify widths
///     stroke: none,
///     align: left,
///     [#subex-label()<ex-anba>], [#ipa("/anba/")], [#a-r], [#ipa("[amba]")],
///     [#subex-label()<ex-anka>], [#ipa("/anka/")], [#a-r], [#ipa("[aNka]")],
///   )
/// ] <ex-phon2>
///
/// See @ex-phon2, @ex-anba, and @ex-anka.
/// ```
#let subex-label = subex-label

/// Show rules for linguistic examples
///
/// Apply this to enable proper reference formatting for ex() and subex-label().
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
