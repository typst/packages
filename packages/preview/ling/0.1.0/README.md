# Ling

[한국어](README.ko.md)

Ling is a Korean-first [Touying](https://github.com/touying-typ/touying) theme for technical presentations. It provides switchable sans-serif and serif typography and print-safe callouts. The required fonts are downloaded separately after initialization; the Typst Universe package and template do not contain font binaries.

The primary output is PDF. Generated presentations do not contain editable PowerPoint objects and are not intended to be edited as PPTX files.

## Start a presentation

The recommended path initializes the template, downloads the six pinned fonts from their official sources, and compiles with that local font directory:

```sh
typst init @preview/ling:0.1.0 my-talk
cd my-talk
sh download-fonts.sh
typst compile main.typ --font-path fonts
```

Use `--input mode=serif` for serif typography or `--input handout=true` for a handout:

```sh
typst compile main.typ talk.pdf --font-path fonts --input mode=serif
typst compile main.typ handout.pdf --font-path fonts --input handout=true
```

`download-fonts.sh` verifies every file against `fonts/SHA256SUMS` and skips files that already match. It downloads Pretendard GOV 1.3.9 Regular, SemiBold, and Bold; RIDI Batang OpenType 1.000; and D2Coding 1.3.3 Regular and Bold. Keep `--font-path fonts` on CLI builds because packages cannot register fonts themselves.

For the Typst web app, initialize and run the downloader locally, then upload `main.typ` together with the six files in `fonts/` to the web project. The web app detects fonts stored in the user's project. Font binaries must not be added to a Typst Universe package submission.

## Direct import

Direct imports are supported when the three font families listed below are available to Typst:

```typ
#import "@preview/ling:0.1.0": *

#show: ling-theme.with(
  mode: "sans",
  title: [문서가 코드가 되는 순간],
  author: [타치바나 셰리],
)

#title-slide()

= 설계 원칙

== 가장 작은 인터페이스

내용은 구조에 집중합니다.
```

The theme function has this signature:

```text
#let ling-theme(
  mode: "sans",
  accent: rgb("#087A5C"),
  aspect-ratio: "16-9",
  title: none,
  author: none,
  institution: none,
  date: none,
  logo: none,
  ..args,
  body,
)
```

Additional named arguments are forwarded to Touying. The package does not replace Touying's slide, overlay, handout, column, or speaker-note APIs.

## Typography

- `mode: "sans"` uses Pretendard GOV Regular, SemiBold, and Bold with compact screen-oriented leading.
- `mode: "serif"` uses RIDI Batang Regular for all proportional text. Semi-bold and bold hierarchy is synthesized with 0.12 pt and 0.20 pt strokes.
- Code uses D2Coding Regular and Bold with programming ligatures disabled in both modes.

The theme requires Pretendard GOV 1.3.9, RIDI Batang OpenType 1.000, and D2Coding 1.3.3. The active family lists are deliberately limited to `Pretendard GOV`, `RIDIBatang`, and `D2Coding`; there are no system-font fallback families. This keeps missing-font diagnostics visible instead of silently changing the design. `typst init` is recommended because direct imports must acquire the fonts separately and provide them through `--font-path` or a web-project upload.

## Touying features

Import Touying when using its public helpers:

```typ
#import "@preview/touying:0.7.4": *
#import "@preview/ling:0.1.0": *

#show: ling-theme.with(
  config-common(handout: true),
)

== 단계별 설명

항상 보이는 내용입니다.
#pause
두 번째 단계에서 보이는 내용입니다.

#speaker-note[발표자에게만 필요한 메모입니다.]

#slide(composer: (1fr, 1fr))[
  왼쪽 열
][
  오른쪽 열
]
```

`pause` creates overlay steps, `slide(composer:)` uses Touying's native slide composition, `config-common(handout: true)` produces handout output, and `speaker-note` records presenter notes.

## Callouts

Information and warning callouts remain distinguishable without color through their labels and different left rules:

```typ
#info(title: [정보])[배경 지식을 설명합니다.]
#warning(title: [주의])[확인해야 할 위험을 설명합니다.]
```

## License

The theme and template are distributed under the [MIT No Attribution License](LICENSE), so initialized presentations can be modified and redistributed without carrying an attribution notice. Required fonts are downloaded separately and remain under their SIL Open Font License 1.1 terms. The package retains the corresponding license and attribution files:

- [Pretendard GOV license](template/licenses/Pretendard-OFL.txt)
- [RIDI Batang license](template/licenses/RIDIBatang-OFL.txt)
- [D2Coding license](template/licenses/D2Coding-OFL.txt)
