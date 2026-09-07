# sdust

SDU-branded document frontpages for Typst — ready-to-use title pages plus
sane base styling for coursework at the University of Southern Denmark:
`thesis`, `note`, `exercise`, `assignment`, `project`, `submission`, `exam`,
and `chi`.

Every cover page uses a custom SDU layout, SDU red accent, A4, and defaults to
"University of Southern Denmark".

```typst
#show: thesis.with(
  logo: image("sdu-logo.png", width: 12em),   // download from SDUs webpage
)
```

Pass `logo: none` (the default) for no logo at all.

## Usage

```typst
#import "@preview/sdust:0.1.0": *

#show: note.with(
  title:  "Lecture Notes",
  course: "DM000 — Course Name",
  author: "Firstname Lastname",
  date:   "2026-09-07",
)

= First Section
```

Just the base styling, no cover page:

```typst
#import "@preview/sdust:0.1.0": *
#show: pageSetup
```

See the comment block at the bottom of `lib.typ` for a copy-paste starter
for every template.

## Local development

```bash
git clone https://github.com/simo899t/sdust
ln -s "$PWD/sdust" "$(typst --version >/dev/null 2>&1; echo ~/.local/share/typst)/packages/local/sdust/0.1.0"
```

(macOS registry: `~/Library/Application Support/typst/packages/local`;
Windows: `%APPDATA%\typst\packages\local`. Then import `@local/sdust:0.1.0`.)

## Templates

| Function | Description |
|---|---|
| `pageSetup` | Base styling, no cover page |
| `thesis` | Bachelor's / Master's thesis title page |
| `note` | Lecture notes |
| `exercise` | Exercise sheets |
| `assignment` | Assignments |
| `project` | Group/solo project reports |
| `submission` | Lightweight hand-in (title card only, no TOC) |
| `exam` | Exam submissions |
| `chi` | ACM CHI paper format |

Also exported: `base-style`, `bib`,
`word-count` / `total-words`, the branding constants `sdu-red` and
`sdu-university`, and the Faculty of Science department names
`imada`, `bmb`, `biology`, `fkf` (pass one as `department:` on `thesis`).

## Theorem-style cards

`theorem`, `definition`, `example`, `proof`, `corollary`, `block` (the `QED`
tombstone too), plus the exercise cards `question` / `answer` — coloured
titled cards, e.g. `#theorem(title: "Theorem 1")[...]`.
