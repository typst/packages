# Quiet Quill

Configurable dissertations and reports with neutral styling.

Quiet Quill provides a small, independently maintained academic document wrapper
and an editable synthetic MSc-style example. It is not an official University of
Southampton or ECS template. The development repository's historical `Ecs` name
implies no institutional endorsement. Always check your own institution's current
format and submission requirements.

## Start a document

Requires **Typst 0.15.1 or newer**; this candidate was tested with 0.15.1.
The proposed package version is **0.2.0**. Before it is accepted into the preview
registry, the commands below require a local installation of this candidate.

```sh
typst init @preview/quiet-quill:0.2.0 my-dissertation
cd my-dissertation
typst compile main.typ sample.pdf
typst compile --input anonymous=true main.typ sample-anonymous.pdf
```

For pre-submission local testing, place the package at
`local-packages/preview/quiet-quill/0.2.0`, then use the CLI's package-path option:

```sh
typst init --package-path local-packages @preview/quiet-quill:0.2.0 my-dissertation
typst compile --package-path local-packages my-dissertation/main.typ sample.pdf
```

The initialized project contains `main.typ`, `config.typ`, three short chapters,
an appendix, two bibliography records and its own MIT-0 `LICENSE`. It contains
no package implementation or parent-directory imports. Edit `config.typ` and
chapter files; add a chapter with an `#include` in `main.typ`. All identities,
collections, diagrams, scores and conclusions are fictional. The two cited
publications are genuine, but no publication text or research results are copied.

## Package API

The only public definition is `dissertation`. It receives the remaining document
as its last positional argument. Apply it through an everything show rule:

```typst
#import "@preview/quiet-quill:0.2.0": dissertation

#show: dissertation.with(
  config: (title: "An Illustrative Report", author: "Example Author"),
  abstract: [A short, fictional example.],
)

= Introduction
Write your own content here.
```

The wrapper follows the official
[template tutorial](https://typst.app/docs/tutorial/making-a-template/). Its
internal defaults and helpers are not exported through `lib.typ`.

Named content arguments are `abstract` (default `[]`), `acknowledgements`,
`declaration`, `abbreviations`, `symbols`, `glossary`, and `appendices` (each default `none`). Empty content or `none`
omits the section without inserting an empty page. No institutional declaration
is provided: use an accurate declaration required by your current programme,
when you have the right to use its wording.

The `config` dictionary accepts these keys; unknown keys are rejected:

| Keys | Defaults | Meaning |
| --- | --- | --- |
| `title`, `author` | `""`, `""` | Nonempty title and normal-mode author are required |
| `email` | `""` | Optional cover email and mailto link |
| `institution`, `programme`, `supervisor` | `""` | Optional cover fields |
| `submission-date` | `""` | Explicit cover date; no automatic current date |
| `keywords` | `()` | Array of strings for normal-mode PDF metadata |
| `anonymous` | `false` | Omit template-controlled identity output |
| `paper` | `"a4"` | Native Typst paper name |
| `margins` | `(x: 25mm, y: 25mm)` | Nonnegative absolute length or native margin dictionary of such lengths |
| `font`, `font-size` | `"Libertinus Serif"`, `11pt` | Body family and positive absolute size |
| `leading` | `0.7em` | Extra inter-line space, not a Word line-spacing multiplier |
| `paragraph-spacing` | `0.8em` | Space between paragraphs |
| `contents`, `contents-depth` | `true`, `3` | Contents toggle and depth from 1 to 6 |
| `list-of-figures`, `list-of-tables` | `true`, `true` | Nonempty figure/table lists |
| `bibliography-file` | `none` | Caller-created `path` to a bibliography; strings are package-relative legacy input |
| `frontmatter-order` | `("abstract", "acknowledgements", "declaration")` | Each of these three keys exactly once, in the desired order |
| `citation-style` | `"ieee"` | Typst built-in citation style |

## Bibliography and project resources

The initialized `config.typ` deliberately uses `path("references.bib")`. Construct
this path in your project before passing it to the package: a plain string read
inside a package resolves in that package, not in the user's project. See the
[official path documentation](https://typst.app/docs/reference/foundations/path/).
Here is a complete document using a project-local bibliography:

```typst
#import "@preview/quiet-quill:0.2.0": dissertation

#show: dissertation.with(config: (
  title: "A Synthetic Reading Note",
  author: "Example Author",
  bibliography-file: path("references.bib"),
  citation-style: "ieee",
))

= Background
A general textbook provides background: @manning2008.
```

Add your own records to the initialized bibliography and cite their keys. Do not
export attachment paths or private notes. The example records were checked with
[Cambridge University Press](https://www.cambridge.org/highereducation/books/introduction-to-information-retrieval/669D108D20F556C5C30957D63B5AB65C)
and [Microsoft Research](https://www.microsoft.com/en-us/research/publication/okapi-at-trec-3/).
The bibliography settings control actual output; there is no bundled private
research library or separate CSL file.

## Layout and figures

The cover is physically first but has no printed number or PDF page label. Front
matter starts at visible roman i; the body restarts at visible Arabic 1. References
and appendices continue the body page sequence. Appendix headings start at A/A.1.
Equations and each kind of figure/table use global numbering. Chapters and
nonempty front sections start on new pages; empty lists are omitted. There is
no running header, and page numbers are centered in the footer.

Use native `figure`, `table`, mathematics, labels and references. Tables have
captions above; other figure captions appear below. A native drawing intended
for the figure list should set `kind: image` and provide an `alt` description,
as the initialized diagram does. Tables can break across pages and should use
`table.header` for repeated semantic header cells. The example demonstrates
numbered figures, a table, an equation, citations and appendix cross-references.

Default typography is an author design choice, not an institutional requirement.
Libertinus Serif and New Computer Modern Math are available in the tested CLI's
embedded fonts. No font installation or Universe drawing package is required.
If you choose other fonts, install them appropriately and validate the output.

Optional abbreviations, symbols and glossary sections follow the figure/table
lists, retain Roman page numbers and appear in Contents. Supply native content,
for example `abbreviations: [ / IR: Information retrieval. ]`. Each defaults to
`none`, so existing documents keep their layout. These slots do not collect terms
automatically. `frontmatter-order` changes only the order of abstract,
acknowledgements and declaration; anonymous mode still suppresses the latter two.

## Anonymous mode

In an initialized project, `--input anonymous=true` sets the boolean in
`config.typ`; only the strings `true` and `false` are accepted. Package callers
can set `config.anonymous` directly. Anonymous output omits the author, email,
mailto link, institution, programme, supervisor, acknowledgements, declaration,
PDF author and PDF keywords. The cover shows an anonymous author.

This does not anonymize arbitrary content. The title, date, abstract, body,
references, figures, optional abbreviation/symbol/glossary content, appendix and filenames remain. Inspect self-citations,
embedded resources and identifying prose yourself. Source files still contain
configuration values and are not an anonymous submission. This is not a guarantee
of blind-review anonymity.

## Reproducibility and limits

For a fixed timestamp and compiler-bundled fonts:

```sh
typst compile --ignore-system-fonts --creation-timestamp 0 main.typ sample.pdf
typst compile --ignore-system-fonts --creation-timestamp 0 --input anonymous=true main.typ sample-anonymous.pdf
```

The sample date is explicit, and PDF document dates are disabled. Byte equality
is tested only on the recorded compiler/environment, not all platforms or future
versions. Long titles, multi-page contents, a 130-row table and invalid settings
are covered by the development repository's local tests.

The sample has selectable text, embedded fonts, a tagged structure, semantic table
headers, a figure description and linked references. It has not received PDF/A,
PDF/UA or screen-reader certification. Mathematics and your own content may need
additional accessibility work. Special binding layouts, landscape inserts and
other language/font combinations require their own validation.

## Licences

The repository's existing `LICENSE` remains **MIT**, copyright 2026 Cyberl-ty02.
It covers the package implementation and files outside `template/`, including
this README and the generated preview image. The entire editable `template/`
scaffold is separately offered under **MIT-0**, recorded in `template/LICENSE`
and its source headers. The manifest therefore declares `MIT AND MIT-0` for
these distinct parts, not two conflicting requirements on every file.

You may use, modify and distribute the scaffold and your documents without an
attribution or licence-text requirement from the scaffold. This does not change
the licences of publications you cite, fonts, or resources you add. Retain the MIT
notice if redistributing the package implementation. Tool/font provenance and
separate third-party terms are in [THIRD_PARTY.md](THIRD_PARTY.md). No third-party
template code, institutional assets, private declarations or font files are
shipped.