# PDF Decoration
> Make your pdf more attractive like a html lady.

## About
Bring fascinating Web visuals to your PDF pages.\
If you see some brand-new visuals, open issues please!

Philosophy:
- **concise:** no `}` line, no binary png or svg icon
- **flexible:** global or local, all or part of
- **universal:** different env, the same PDF

Features(_not yet_):
[CommonMark](https://commonmark.org):
- All links/anchors are underlined and blue
- Every block/inline code is inside a gray rectangle
- Every block quote is indented and a gray bar at the left

[GitHub Markup](https://docs.github.com/en/get-started/writing-on-github):
- All features of CommonMark
- Every heading is underlined with a 100% width gray line
- All headings have Auto Anchors
- Alert: Note, Tip, Important, Warning, Caution
- Color Dot
- Task List
- Table:
  - header is bold and mid
  - half table rows are gray
  - all strokes are gray

[_Jupyter Book MyST_](https://mystmd.org/guide/quickstart-myst-markdown):
- Callout & Admonition
- Executable Code Block with line highlight
- Cross-Ref Preview

[_Bootstrap_](https://getbootstrap.com/docs/5.3/components/accordion):
- Accordion, Button Group, Navs & Tabs, Pagination, Progress
- Alert
- Card
- Dialog, Toast
- Offcanvas
- Validation

## Usage
1. Download the [Typst](https://typst.app) PDF compiler
2. Copy the code block into a file with name `example.typ`
3. `typst compile example.typ`, `firefox example.pdf`

```typ
#import "@preview/pdf-decoration:0.1.0": *

#set page(paper:"a5", columns:2)
#set heading(numbering:"I.1")

= Set/Show Rules

== CommonMark<cm>

#show: cm-link.with()
globally part call
#link("https://commonmark.org")[CommonMark]

#cm-raw[`locally part call`]

#common-mark[locally all call @cm]

#show: common-mark.with()
#quote(attribution:[many call ways])[globally all call]

== GitHub Markup

#github-markup[
=== Heading with auto anchor

#table(columns:8, table.header(.."Table".split("")),
  ..range(0x3b1, 0x3c1).map(str.from-unicode))

- [ ] Task
  + [x] L
  + [] i [ ] s [x] t

@heading-with-auto-anchor[auto anchor]]

= Functions

#gm-color-dot(navy)
#gm-color-dot(aqua, m:"rgb")
#gm-color-dot(color.hsl(blue), m:"hsl")

#gm-alert(0)[Prefer Embedded Fonts of Typst CLI]
#gm-alert(1)[to be Fast and Universal]
#gm-alert(2)[and Font Fallback available]
#gm-alert(3)[Symbols by DejaVu Sans Mono]
#gm-alert(4)[so Different from GitHub's]

#gm-alert-diy(c:green, s:emoji.parrot, k:"Do-It-Yourself")[
/ c, s, k: color, symbol, kind
Symbols depend on fonts:\
`s:text(size:1em, font:"Noto Color Emoji", emoji.parrot)`]

= Road Map
#show: gm-task-list.with()
- [x] CommonMark
- [x] GitHub Markup
- [ ] Jupyter Book MyST
- [ ] Bootstrap
```

## LICENSE
[Apache-2.0](https://www.apache.org/licenses/LICENSE-2.0.txt)
