# Scorify

Render sheet music directly inside Typst with a WASM-backed SVG renderer.

Full API and syntax documentation: [docs/reference.md](https://github.com/justinbornais/typst-sheet-music/blob/v0.3.0/docs/reference.md)

## Usage

### Via Typst Package Manager

```typ
#import "@preview/scorify:0.3.0": score, melody
```

Compile normally:

```text
typst compile your-file.typ
```

## Font Setup

Scorify uses `Leland` by default. `Leland` is built directly into `scorify_wasm.wasm`, so the default setup does not require a system-installed music font or `--font-path`.

If you choose another supported SMuFL font with `music-font`, Typst must be able to find that font from your system fonts or from a directory passed with `--font-path`. If Typst cannot find it, compilation still runs, but Typst will warn about the missing font family.

Use `music-font-metadata` when you want to provide external SMuFL metadata explicitly, usually via `json(...)`.

### Supported Fonts

- `Leland` (default, bundled in the WASM)
- `Bravura`
- `Petaluma`
- `Sebastian`
- `Leipzig`
- `Finale Ash`
- `Finale Broadway`
- `Finale Engraver`
- `Finale Jazz`
- `Finale Legacy`
- `Finale Maestro`

## Example

```typ
#import "@preview/scorify:0.3.0": melody

#melody(
  title: "Scale",
  key: "C",
  time: "4/4",
  music: "c4 d e f | g a b c'",
)
```

## Example: Grand Staff

```typ
#import "@preview/scorify:0.3.0": score

#score(
  title: "Ode to Joy",
  composer: "L. van Beethoven",
  key: "D",
  time: "4/4",
  staves: (
    (
      clef: "treble",
      brace-start: true,
      music: "f#4 g a b | a g f# e | d2 e2 | f#1",
    ),
    (
      clef: "bass",
      brace-end: true,
      music: "d,2 a, | d,2 a, | d,1 | a,1",
    ),
  ),
)
```

## Notes

- The library requires Typst `0.14.0+`.
- Alternate fonts may need metadata or spacing adjustments depending on the font.

## License

MIT - see [LICENSE](LICENSE).
