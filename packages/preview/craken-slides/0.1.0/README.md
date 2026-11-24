# Captain Craken slides

A 16:9 slide template for maths and computer science talks, built on the Captain Craken design system: its ten colours in Paper and Lantern, Fraunces, Newsreader, DM Mono and STIX Two Math, and the sucker as the only ornament.

## Start a talk

```sh
typst init @preview/craken-slides:0.1.0 my-talk
cd my-talk
typst compile main.typ                                # Paper
typst compile --input theme=lantern main.typ          # Lantern (dark)
typst watch main.typ                                  # while writing
```

A talk starts with `#import "@preview/craken-slides:0.1.0": *`. [`examples/example.typ`](https://github.com/TheCaptainCraken/craken-slides/blob/v0.1.0/examples/example.typ) in the GitHub repository shows every slide type. In the Typst web app, choose *Start from template* and search for `craken-slides`.

To show a logo, put the image next to your talk and pass `logo: image("logo.png")`. In Lantern it sits on a light disc automatically.

## Fonts

Typst packages can't ship fonts, so download them once: [craken-slides-fonts.zip](https://github.com/TheCaptainCraken/craken-slides/releases/download/v0.1.0/craken-slides-fonts.zip).

- **On your computer:** install the `.ttf` files (double-click them, or copy them to `~/.local/share/fonts` on Linux). Or keep them in a folder and pass `--font-path path/to/fonts` to `typst compile` and `typst watch`.
- **In the web app:** upload the `.ttf` files anywhere in your project. The web app picks them up.

Without them the slides still compile, in Libertinus Serif, with a warning for each missing font.

The zip holds static instances made from the variable fonts, because Typst can't set variation axes. Fraunces is fixed at `SOFT 100` (as the system asks). It ships as **Craken Display** (opsz 72, for titles) and **Craken Label** (opsz 18, for labels). Newsreader ships as **Craken Text**. The fonts were renamed because the OFL doesn't allow modified fonts to keep their reserved names. DM Mono and STIX Two Math are unmodified. All are under the SIL Open Font License; the licences are in the zip.

## Slides

| Call | What it makes |
| --- | --- |
| `title-slide()` | Title, subtitle, author, date, event, and a curl of suckers |
| `outline-slide()` | Every section, numbered in coral |
| `section-slide(title, lede: ..)` | A big coral numeral; steps the section counter |
| `slide(title: .., aside: ..)[..]` | Content slide; `aside` adds the margin column |
| `idea-slide[..]` | One sentence, large |
| `reveal-slide(title: .., label: [Answer])[prompt][answer]` | Two pages: hidden (open ring), then shown (filled ring) |
| `closing-slide[..]` | Last slide |

The footer has one sucker per section (filled once you reach it) and the page number in rust.

## Inside a slide

- Callouts: `tip`, `question`, `try-this`
- Mathematics: `theorem`, `lemma`, `proposition`, `corollary`, `definition`, `example` (all take `name:`), `proof` (ends with a sucker), `dfn[term]`
- Practice: `exercise(difficulty: 1–3)`, and `exercises[..]` to group several
- Code: fenced raw blocks are styled automatically; `code(title: [file.py], numbers: true)[```…```]` adds a title and line numbers
- Figures: `canvas(width, height, node(..), edge(..), tag(..))` for diagrams, `plot(series: ((label: [$n^2$], f: x => x * x),), ..)` for charts
- Layout: `cols(..)`, `note[..]` for asides, `section-break()`
- Numbers include the section (Figure 2.1, Theorem 3.1, (2.1)). Display equations are numbered only when they have a label, and `@ref` always shows the target's own section.

## Files

- `craken.typ`: the slides.
- `template/`: what `typst init` copies into a new talk.

The [GitHub repository](https://github.com/TheCaptainCraken/craken-slides) also has the fonts, `examples/example.typ`, and `install.sh`, which installs the package and the fonts on Linux and macOS for working offline.

## License

The code and the starter files are under [MIT-0](LICENSE): use, change and share them however you like, no credit needed. The fonts are under the SIL Open Font License.
