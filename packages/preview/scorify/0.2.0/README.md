# Scorify

Render sheet music directly inside Typst using SMuFL-aware glyph placement and CeTZ drawing primitives.

## Features

- Pure Typst: no WASM plugin and no LilyPond or MuseScore CLI dependency.
- Notes, rests, spacers, chords, accidentals, key signatures, time signatures, and supported clefs.
- Inline annotations: dynamics, hairpins, articulations, fingerings, chord symbols, expression text, staff text, staff markers, and lyrics.
- Notation features: beams, ties, slurs, tuplets, octave lines, trills, grace notes / acciaccaturas, repeat barlines, endings, and dotted notes.
- Inline clef changes, inline time-signature changes, manual spacing via repeated spaces, and explicit system breaks.
- Single-staff, grand-staff, and bracketed multi-staff layout with vertical beat alignment.
- Alternate SMuFL font support via `music-font` and `music-font-metadata`.
- Crisp vector PDF output.

## Quick Start

```typ
#import "@preview/scorify:0.2.0": score, melody

#melody(
  title: "Scale",
  key: "C",
  time: "4/4",
  music: "c4 d e f | g a b c'",
)
```

Compile with Bravura available to Typst:

```text
typst compile your-file.typ --font-path /path/to/bravura/
```

### Font Setup

Scorify defaults to [Bravura](https://github.com/steinbergmedia/bravura) plus bundled Bravura metadata.

1. Download `Bravura.otf` from the [Bravura releases page](https://github.com/steinbergmedia/bravura/releases).
2. Either install it system-wide, or keep it in a project folder and pass that folder with `--font-path`.

#### Alternate SMuFL Fonts

You can switch fonts with:

- `music-font`: Typst font family name
- `music-font-metadata`: optional SMuFL metadata dictionary, usually loaded with `json(...)`

```typ
#import "@preview/scorify:0.2.0": melody

#melody(
  music: "c4 d e f | g a b c'",
  music-font: "Your SMuFL Font",
  music-font-metadata: json("your-smufl-metadata.json"),
)
```

## API Reference

### `score()`

Primary entry point for one or more staves.

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

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `staves` | array | `()` | Array of staff dictionaries |
| `key` | string | `"C"` | Key signature like `"C"`, `"G"`, `"Bb"`, `"f#"` |
| `time` | string | `none` | Time signature like `"4/4"`, `"6/8"`, `"common"`, `"cut"` |
| `title` | string | `none` | Piece title |
| `subtitle` | string | `none` | Subtitle |
| `composer` | string | `none` | Composer name |
| `arranger` | string | `none` | Arranger name |
| `lyricist` | string | `none` | Lyricist name |
| `staff-group` | string | `"none"` | `"none"`, `"grand"`, or `"bracket"` |
| `staff-size` | length | `1.75mm` | Staff space distance |
| `system-spacing` | length | `12mm` | Vertical space between systems |
| `staff-spacing` | length | `8mm` | Vertical space between staves in a system |
| `lyric-line-spacing` | length | `none` | Override stacked lyric line spacing |
| `music-font` | string | `"Bravura"` | SMuFL font family |
| `music-font-metadata` | dictionary/none | `none` | Optional metadata dictionary |
| `width` | length/auto | `auto` | Explicit width or auto |
| `measures-per-line` | int | `none` | Force a fixed number of measures per system |

Staff dictionaries support:

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `clef` | string | `none` | Any supported clef, including octave-clef variants and `"percussion"` |
| `music` | string | `""` | Music string |
| `fingering-position` | string | `"above"` | Default fingering position: `"above"` or `"below"` |

### `melody()`

Single-staff convenience wrapper around `score()`.

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

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `music` | string | `""` | Music string |
| `key` | string | `"C"` | Key signature |
| `time` | string | `none` | Time signature |
| `clef` | string | `none` | Clef |
| `title` | string | `none` | Title |
| `composer` | string | `none` | Composer |
| `staff-size` | length | `1.75mm` | Staff space |
| `system-spacing` | length | `12mm` | Vertical space between systems |
| `lyric-line-spacing` | length | `none` | Override stacked lyric line spacing |
| `music-font` | string | `"Bravura"` | SMuFL font family |
| `music-font-metadata` | dictionary/none | `none` | Optional metadata dictionary |
| `width` | length/auto | `auto` | Width |
| `measures-per-line` | int | `none` | Force a fixed number of measures per system |

## Full Example

```typ
#import "@preview/scorify:0.2.0": score

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

## Examples

Useful starting points in `examples/`:

- `ode-to-joy.typ`: grand staff with chord symbols, fingerings, and dynamics
- `techniques.typ`: dense mixed-notation showcase
- `inline-clef-changes.typ`: mid-system clef changes
- `grace-notes.typ`: grace notes and acciaccaturas
- `lyrics-demo.typ`: lyrics and multi-line lyric layout
- `clef-variants.typ` and `alto-tenor-demo.typ`: alternate clefs
- `three-endings.typ`: repeat endings / voltas

## Supported Clefs

Scorify supports:

- `"treble"`, `"bass"`, `"alto"`, `"tenor"`
- `"treble-8a"`, `"treble-8b"`, `"treble-15a"`, `"treble-15b"`
- `"bass-8a"`, `"bass-8b"`, `"bass-15a"`, `"bass-15b"`
- `"percussion"`

Example:

```typ
#score(
  staves: (
    (clef: "alto", music: "c4 d e f"),
    (clef: "tenor", music: "g,4 a b c"),
  ),
)
```

## Time Signatures

Examples of accepted inputs:

| Input | Meaning |
|-------|---------|
| `"4/4"` | Four quarter notes per measure |
| `"3/4"` | Three quarter notes per measure |
| `"6/8"` | Compound duple |
| `"2/2"` | Alla breve |
| `"common"` or `"C"` | Common time symbol |
| `"cut"` or `"C|"` | Cut time symbol |

```typ
#melody(music: "c4 d e f", time: "common")
#melody(music: "c2 d", time: "cut")
```

## Music String Cheat Sheet

- **Notes and rhythm**: `c4`, `d8.`, `f#4`, `g'2`, `a,16`
  - Accidentals: `#`, `##`, `&`, `&&`, `=`
  - Octave markers: `'` raises, `,` lowers
  - Duration is sticky: `c4 d e f`

- **Rests, spacers, and manual spacing**: `r4`, `r8.`, `s4`
  - Repeated spaces add extra horizontal gap: `c e   g c`

- **Chords**: `<c e g>4`

- **Articulations**: `>` accent, `*` staccato, `-` tenuto, `_` fermata

- **Ties and slurs**: `c4~ c4`, `c4( d e) f`

- **Inline attachments**
  - Dynamics: `v[pp]`, `v[mf]`, `v[ff]`
  - Staff text above: `text[Solo]`
  - Expression text below: `exp[dolce]`
  - Fingerings: `n[3]`, `n_[2]`, `n[1 3 5]`
  - Chord symbols: `[C]`, `[Am7]`, `[D/F#]`
  - Staff markers: `bm` (breath mark), `//` (caesura), `ds`, `coda`

- **Spans and ornaments**
  - Hairpins: `cresc{c e g c}`, `decresc{c' b a g}`
  - Trills: `c4tr`, `tr{d'4 e' f' g'}`
  - Grace notes: `grace{c16 d e} f4`
  - Acciaccatura-style slash: `grace{f#16 g a/} b4`
  - Octave lines: `8a{...}`, `8b{...}`, `15a{...}`, `15b{...}`
  - Tuplets: `{2,3:d4 e d}`
  - Endings / voltas: `end{1.: f d e c | g g c c}`

- **Structure**
  - Barlines: `|`, `||`, `|.`, `|:`, `||:`, `:|`, `:||`, `:|:`, `:||:`
  - Forced beaming: `[` and `]` where they are not parsed as chord symbols
  - Inline clef changes: `... bass ... treble ...` (cue-sized mid-system)
  - Inline time-signature changes: `... 3/4 ... 5/4 ... common ... cut ...`
  - Literal newlines force a system break

- **Lyrics**
  - Attach with `l[...]`: `c4l[text]`
  - Hyphen continuation: `l[text-]`
  - Melisma/extender: `l[text_]`
  - Carry the previous lyric state with plain `l`
  - Stack multiple lyric lines by attaching multiple lyric entries to one event

Short example:

```typ
#score(
  staff-group: "grand",
  staves: (
    (clef: "treble", music: "c4[Am]n[1] dtext[Solo] e4tr f | cresc{g a b c'} | end{1.: d'4 e' f' g'}"),
    (clef: "bass", music: "c,4 e, g, c bass b, a, g, | grace{c16 d e/} f4 | 3/4 c e g"),
  ),
)
```

See `examples/` and `tests/test-render-basic.typ` for more combinations and edge cases.

## Notes

- Scorify defaults to the Bravura SMuFL font and bundled Bravura metadata.
- Alternate SMuFL fonts may need spacing adjustments depending on their metadata quality.
- Core spacing constants live in `src/constants.typ`.
- The library requires Typst `0.14.0+` and CeTZ `0.4.2`.

## Contributing

Bug reports, feature requests, and pull requests are welcome in the [official repository](https://github.com/justinbornais/typst-sheet-music).

## License

MIT - see [LICENSE](LICENSE).
