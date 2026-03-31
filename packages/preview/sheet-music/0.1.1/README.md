# typst-sheet-music

Render professional sheet music directly inside Typst documents using SMuFL-aware glyph placement and CeTZ drawing primitives.

## Features

- **Pure Typst** - no WASM plugin, no external binary dependency (no LilyPond, no MuseScore CLI)
- SMuFL/Bravura-aware glyph placement with precise bounding-box anchors
- Notes, rests, chords, accidentals, key signatures, time signatures, clefs
- Dynamics, articulations, fingerings, and chord symbols - all inline in the music string
- Beams, ties, slurs, repeat barlines, dotted notes, tuplets
- Grand staff and multi-staff layout with vertical beat alignment
- System/line breaks via measures-per-line, literal `\n`, or automatic width-based breaking
- Header block with title, subtitle, composer, arranger, lyricist
- Produces crisp, resolution-independent vector PDF output

## Quick Start

1. Copy this repository (or `lib.typ` + `src/` + `fonts/` + `data/`) into your Typst project.
2. Import the library and call `score()` or `melody()`:

```typ
#import "lib.typ": score, melody

#melody(
  title: "Scale",
  key: "C",
  time: "4/4",
  music: "c4 d e f | g a b c'",
)
```

3. Compile with the bundled Bravura font:

```
typst compile your-file.typ --font-path fonts/ --root .
```

## Music String Syntax

All music is written as a single string passed to the `music:` parameter. The syntax is inspired by LilyPond.

### Notes

Notes are lowercase letters `a` through `g`:

```
c d e f g a b
```

### Octave Markers

- `'` raises one octave (repeatable): `c'` = C5, `c''` = C6
- `,` lowers one octave (repeatable): `c,` = C3, `c,,` = C2
- Default base octave is 4 (middle C octave) for treble clef, 3 for bass clef

### Accidentals

Placed immediately after the note name:

| Syntax | Meaning |
|--------|---------|
| `#` | Sharp |
| `##` | Double sharp |
| `&` | Flat |
| `&&` | Double flat |
| `=` | Natural |

Example: `c# d& e= f##`

### Duration

An integer after the note specifies the duration. Duration is **sticky** - it carries forward to subsequent notes until changed.

| Value | Duration |
|-------|----------|
| `1` | Whole note |
| `2` | Half note |
| `4` | Quarter note (default) |
| `8` | Eighth note |
| `16` | 16th note |

Example: `c4 d e f | c8 d e f g a b c'`

### Dots

`.` after the duration (or note if duration is omitted). Dots are **not** sticky.

```
c4. d8 e4 f | g2. r4
```

### Rests

`r` followed by an optional duration and dots:

```
r4 r2. r8 r1
```

### Spacers

`s` creates an invisible rest (for spacing purposes):

```
s4 c4 d e
```

### Barlines

| Syntax | Style |
|--------|-------|
| `\|` | Single barline |
| `\|\|` | Double barline |
| `\|.` | Final barline |
| `\|:` | Repeat start |
| `:\|` | Repeat end |

Example: `|: c4 d e f | g a b c' :|`

### Ties

`~` after a note connects it to the next note of the same pitch:

```
c4~ c4 e2
```

### Slurs

`(` starts a slur, `)` ends it:

```
c4( d e f) g2
```

### Articulations

Placed after the note/duration, before dynamics:

| Syntax | Articulation |
|--------|-------------|
| `>` | Accent |
| `*` | Staccato |
| `-` | Tenuto |
| `_` | Fermata |

Multiple articulations can be combined: `c4>*` (accent + staccato).

Example: `c4> d* e- f_ | g>* a b c'_`

### Dynamics

Written as `v[marking]` using standard dynamic characters (`p`, `m`, `f`, `s`, `r`, `z`):

```
c4v[pp] d ev[mf] f | gv[f] a bv[ff] c'
```

Supported markings include: `ppp`, `pp`, `p`, `mp`, `mf`, `f`, `ff`, `fff`, `sf`, `sfz`, `fp`, and more.

Dynamics are rendered below the staff using SMuFL glyphs.

### Beam Markers

`[` starts a beam group, `]` ends it:

```
c8[ d e f] g[ a b c']
```

### Chord Blocks

Simultaneous notes are enclosed in `< >` with a shared duration after the `>`:

```
<c e g>4 <d f a>2 <e g b>8
```

Chord blocks support all the same suffixes as single notes (dots, ties, articulations, dynamics, slurs, beams, chord symbols, fingerings).

### Chord Symbols

Square brackets `[...]` after a note or chord attach a chord symbol displayed above the staff. The content must start with an uppercase letter `A`-`G`:

```
c4[C] d e[F] f | g[G7] a b[Am/E] c'
```

Supported chord notation:
- Root notes: `A` through `G`
- Accidentals in chord names: `#` → ♯, `b` → ♭ (e.g., `Bb`, `F#m`)
- Qualities: `m`, `min`, `maj`, `dim`, `aug`, `sus2`, `sus4`
- Extensions: `7`, `9`, `11`, `13`, `maj7`, `add9`, etc.
- Slash chords: `C/E`, `Am/G`, `D/F#`

Chord symbols are rendered with a bold root (10pt) and smaller superscript quality/extensions (7.5pt).

### Fingerings

`n[digit]` places a fingering number **above** the note. `n_[digit]` places it **below**:

```
c4n[1] dn[2] en[3] fn[4]       // above (default)
c4n_[1] dn_[2] en_[3] fn_[4]   // below
```

For chord blocks, multiple fingerings are space-separated:

```
<c e g>4n[1 3 5]
```

Fingerings and chord symbols can appear in either order:

```
c4n[3][C]    // fingering then chord symbol
c4[C]n[3]    // chord symbol then fingering
```

#### Per-Staff Fingering Position

You can set `fingering-position: "below"` on a staff dict to default all fingerings on that staff to below. Individual `n_[...]` still overrides to below, and `n[...]` defers to the staff setting:

```typ
staves: (
  (clef: "treble", music: "c4n[1] d e f"),                              // above (default)
  (clef: "bass", fingering-position: "below", music: "c4n[1] d e f"),   // below
)
```

### Tuplets

Curly braces define tuplet groups. `{n ...}` means "play n notes in the space of the next lower power of 2". Use `{n:m ...}` for explicit ratios:

```
{3 c8 d e}       // triplet: 3 notes in the space of 2
{5:4 c16 d e f g} // quintuplet: 5 in the space of 4
```

### Line Breaks

A literal newline character (`\n`) in the music string forces a system break at that point.

### Parse Order

For each note, the parser processes modifiers in this order:

```
note → accidental → octave → duration → dots → tie → articulations → dynamic → slurs → beams → chord-symbol / fingering
```

## API Reference

### `score()`

The primary entry point. Renders one or more staves with full layout control.

```typ
#score(
  staves: (
    (clef: "treble", music: "c4 d e f | g a b c'"),
    (clef: "bass", music: "c2 g | c1"),
  ),
  key: "C",
  time: "4/4",
  title: "My Piece",
  composer: "Composer Name",
  staff-group: "grand",
)
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `staves` | array | `()` | Array of staff dicts (see below) |
| `key` | string | `"C"` | Key signature (`"C"`, `"G"`, `"D"`, `"Bb"`, `"f#"`, etc.) |
| `time` | string | `"4/4"` | Time signature (`"4/4"`, `"3/4"`, `"6/8"`, `"C"`, `"C\|"`) |
| `title` | string | `none` | Piece title |
| `subtitle` | string | `none` | Subtitle |
| `composer` | string | `none` | Composer name |
| `arranger` | string | `none` | Arranger name |
| `lyricist` | string | `none` | Lyricist name |
| `staff-group` | string | `"none"` | `"none"`, `"grand"` (brace + spanning barlines) |
| `staff-size` | length | `1.75mm` | Staff space distance |
| `system-spacing` | length | `12mm` | Vertical space between systems |
| `staff-spacing` | length | `8mm` | Vertical space between staves within a system |
| `width` | length/auto | `auto` | Explicit width or auto (fills page) |
| `measures-per-line` | int | `none` | Force this many measures per system |

**Staff dict fields:**

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `clef` | string | `"treble"` | `"treble"`, `"bass"`, `"alto"`, `"tenor"`, `"treble-8"`, `"percussion"` |
| `music` | string | `""` | Music string (see syntax above) |
| `fingering-position` | string | `"above"` | Default fingering position: `"above"` or `"below"` |

### `melody()`

Convenience wrapper for a single-staff score.

```typ
#melody(
  music: "c4 d e f | g a b c'",
  key: "C",
  time: "4/4",
  clef: "treble",
  title: "My Melody",
  composer: "Composer",
)
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `music` | string | `""` | Music string |
| `key` | string | `"C"` | Key signature |
| `time` | string | `"4/4"` | Time signature |
| `clef` | string | `"treble"` | Clef |
| `title` | string | `none` | Title |
| `composer` | string | `none` | Composer |
| `staff-size` | length | `1.75mm` | Staff space |
| `width` | length/auto | `auto` | Width |
| `measures-per-line` | int | `none` | Measures per system |

### `lead-sheet()`

Melody with lyrics (lyrics not yet implemented).

```typ
#lead-sheet(
  music: "c4 d e f | g a b c'",
  key: "C",
  time: "4/4",
  title: "Song Title",
)
```

## Full Example

Here is the Ode to Joy example demonstrating a grand staff with fingerings, chord symbols, dynamics, and articulations:

```typ
#import "lib.typ": score

#set page(margin: 1.5cm)

#score(
  title: "Ode to Joy",
  composer: "L. van Beethoven",
  key: "D",
  time: "4/4",
  staff-group: "grand",
  staves: (
    (
      clef: "treble",
      music: "
        f#4n[3][D] f# g a | a8[D/A] b g4 f#[A] e |
        d[D] d e f# | f#4.[A] e8 e2 |
        f#4[D] f# g a | a[A] g f# e |
        d[D] d e f# | e4.[A] d8 d2[D] |
      ",
    ),
    (
      clef: "bass",
      fingering-position: "below",
      music: "
        d1n[1] | a, | d | a, |
        d | a, | d | a,2 d4 r |
      ",
    ),
  ),
)
```

## Compiling

```bash
typst compile examples/ode-to-joy.typ --font-path fonts/ --root .
```

The `--font-path fonts/` flag ensures the bundled Bravura SMuFL font is available. The `--root .` flag sets the project root for imports.

## Notes

- This project uses the Bravura SMuFL font for accurate music glyph placement. The font is bundled in `fonts/`.
- Spacing parameters (note spacing base, duration factors, accidental padding, dot size) are tunable in `src/constants.typ`.
- The library requires Typst 0.14.0+ and CeTZ 0.4.2.

## Contributing

Bug reports, feature requests, and pull requests are welcome.

## License

MIT - see [LICENSE](LICENSE).
