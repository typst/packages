# rasko-europass

Published on Typst Universe as `rasko-europass`; the template function you
call is `europass-cv`.  The development repository keeps the descriptive name
`europass-cv`.

[![Continuous integration status](https://github.com/Raskolny/europass-cv/actions/workflows/ci.yml/badge.svg)](https://github.com/Raskolny/europass-cv/actions/workflows/ci.yml)

![Europass CV rendered with this template](https://raw.githubusercontent.com/Raskolny/europass-cv/v1.0.0/thumbnail.png)

A faithful, **accessible** reproduction of the official European Union
**Europass CV** format, built for [Typst](https://typst.app) ≥ 0.15.

- Asymmetric two-column grid (~25 % dates / ~75 % content) with the iconic
  thin vertical blue rule running unbroken top-to-bottom.
- Official EU palette: blue `#164194`, body grey `#575756`, highlight `#F2F2F2`.
- **CEFR language self-assessment table** (A1–C2) with contrast-safe shading.
- **GDPR / DPR 445 self-declaration** clause, localised.
- **Full i18n for all 24 official EU languages.**
- **PDF/UA-1 (ISO 14289-1) output** — enforced at compile time in the
  repository build (`--pdf-standard 1.7,ua-1`) and covered by the automated
  accessibility checks in `verify.sh`.
- **Overridable typeface stack** via the `font:` parameter, because Typst
  Universe packages cannot bundle font binaries — see the note below.

> ### Fonts — read this first
>
> Typst Universe packages are **not allowed to ship font binaries**, so this
> package does **not** include Open Sans.  Before compiling, either
>
> 1. **install Open Sans yourself** — download it from
>    [fonts.google.com/specimen/Open+Sans](https://fonts.google.com/specimen/Open+Sans),
>    or install your distribution's Open Sans package (the name varies:
>    `fonts-open-sans`, `open-sans-fonts`, `ttf-open-sans`, …);
> 2. **or pass any family you already have** via the `font:` parameter — the
>    only option in environments where you cannot install fonts, such as the
>    Typst web app.
>
> If you do neither, Typst silently substitutes whatever it finds and the
> output will not match the official Europass typography.  The development
> repository vendors the complete family in `fonts/` so that *its* builds are
> hermetic and reproducible; see
> [Fonts & reproducibility](#fonts--reproducibility).

---

## Quick start

### From Typst Universe

Start a new CV from the template:

```bash
typst init @preview/rasko-europass:1.0.0 my-cv
cd my-cv
typst compile main.typ          # -> main.pdf
```

or import the package into a document you already have:

```typst
#import "@preview/rasko-europass:1.0.0": europass-cv, cv-entry

#show: europass-cv.with(lang: "en", name: "Your Name")
```

### From the repository

The repository vendors the Open Sans family and ships the build and
verification scripts, so its builds are hermetic and PDF/UA-1-validated.
Clone it:

```bash
git clone https://github.com/Raskolny/europass-cv.git
cd europass-cv
./build.sh                 # hermetic, PDF/UA-1 build -> output.pdf
./build.sh my-cv.pdf       # custom output name
```

or fetch the released version as an archive instead of cloning:

```bash
curl -L -o europass-cv.tar.gz \
  https://github.com/Raskolny/europass-cv/archive/refs/tags/v1.0.0.tar.gz
tar xzf europass-cv.tar.gz
cd europass-cv-1.0.0 && ./build.sh
```

> **Repository-only files.**  `build.sh`, `build-examples.sh`, `verify.sh`, the
> vendored `fonts/`, `examples/`, `social-preview.*` and the `CONTRIBUTING` /
> `ROADMAP` / `PUBLISHING` docs live in the
> [GitHub repository](https://github.com/Raskolny/europass-cv) but are **not**
> part of the published Universe package.  If you installed the package from
> Universe, disregard every reference to them further down this page and
> compile with plain `typst compile` as usual.

`build.sh` is the canonical entry point.  It compiles with:

```bash
typst compile --pdf-standard 1.7,ua-1 --ignore-system-fonts --font-path fonts main.typ output.pdf
```

and then runs `verify.sh`, which asserts accessibility and font embedding
(see *Verification* below).  `build.sh` also materialises a local package
cache (`.pkgcache/`) so that `main.typ`'s `@preview/rasko-europass:1.0.0`
import resolves inside the clone; only `build.sh` guarantees the hermetic,
UA-1-validated result.

---

## Writing your CV

Everything an end user touches lives in **`main.typ`**.  You never edit the
layout.  Fill in fields and go:

```typst
#import "@preview/rasko-europass:1.0.0": cv-entry, europass-cv

#show: europass-cv.with(
  lang: "it",
  name: "Mario Rossi",
  email: "mario.rossi@email.it",

  work-experience: (
    cv-entry(
      date-start: "Gen 2021", date-end: "Presente",
      title: "Senior Software Engineer",
      organization: "Tech Solutions S.p.A.",
      location: "Milano, Italia",
      description: [
        - Led a team of six engineers
        - Migrated a monolith to event-driven microservices
      ],
    ),
  ),

  other-languages: (
    (lang: "English", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
)
```

Anything you write *below* the `#show:` line is appended as an extra section.

### `europass-cv(..)` parameters

| Group | Parameters |
| --- | --- |
| Language / metadata | `lang`, `title`, `author` |
| Personal info | `name`, `photo`, `photo-alt`, `address`, `postal-code`, `city`, `country`, `phone`, `email`, `website`, `nationality`, `date-of-birth`, `gender` |
| Sections | `work-experience`, `education` (arrays of `cv-entry`) |
| Skills | `mother-tongue`, `other-languages`, `digital-skills`, `comm-skills`, `org-skills`, `job-skills`, `other-skills`, `driving-licence` |
| Declaration | `declaration`, `signature-place`, `signature-date`, `signature-image` *(1.1.0, unreleased)*, `signature-alt` *(1.1.0, unreleased)* |

Every parameter has a default; supply only what you need.

### `cv-entry(..)`

One row of Work Experience / Education.  Fields: `date-start`, `date-end`,
`title`, `organization`, `location`, `description`.  `title` is emitted as a
real **H3 heading**, so assistive technology can jump straight to a job.

### `language-grid(mother-tongue:, others:, lang:)`

Renders the CEFR table.  `others` is an array of dictionaries with keys
`lang`, `listening`, `reading`, `interaction`, `production`, `writing`, each a
CEFR code (`A1`–`C2`, case-insensitive).  Levels are emitted as **text** with
a contrast-safe background shade — never colour-only, so the PDF stays
accessible.

### Signature

> **Availability.**  `signature-image:` / `signature-alt:` are part of the
> upcoming **1.1.0** release; they are *not* available from the published
> `@preview/rasko-europass:1.0.0`.

By default the declaration block ends with a thin rule, leaving space to sign
**on paper after printing**.  To render an uploaded handwritten signature
instead, point `signature-image:` at it:

```typst
#show: europass-cv.with(
  lang: "it",
  signature-place: "Roma",
  signature-date: "15 settembre 2025",
  // Load your own file as BYTES — see the path-resolution note below.
  signature-image: read("signature.png", encoding: none),
  signature-alt: l("it").at("signature-alt"), // "Firma autografa"
)
```

Notes:

- **Image paths resolve inside the package, not your project.**  Typst
  resolves a relative path string where it is *consumed* (`lib.typ`, inside
  the package), so a bare `signature-image: "signature.png"` would search the
  package directory and fail.  Pass bytes instead —
  `read("signature.png", encoding: none)` resolves relative to *your*
  document.  The same applies to `photo:`.  (Paths to files shipped *with* the
  package, e.g. `"assets/signature-sample.svg"`, work as plain strings.)
- The image is fitted to a **40 mm × 16 mm** box with `fit: "contain"`, so the
  aspect ratio is preserved and a tall scan can never overflow the 55 mm block
  or push the layout around.
- `signature-alt:` is **required for PDF/UA-1** whenever `signature-image:` is
  set — an untagged image fails the `--pdf-standard 1.7,ua-1` build.  Use the
  localised string (`l(lang).at("signature-alt")`), which is translated for all
  24 languages, exactly as for `photo-alt:`.
- The signature block only renders when `signature-place:` or `signature-date:`
  is non-empty.
- All 24 examples use the shared anonymous placeholder
  `assets/signature-sample.svg`, so no real person's signature is depicted.

---

## Internationalisation

Set `lang:` to any ISO 639-1 code; unknown codes fall back to English.
All 24 official EU languages are bundled:

`bg cs da de el en es et fi fr ga hr hu it lt lv mt nl pl pt ro sk sl sv`

Each provides the section headers, the personal-info labels, the CEFR grid
labels, the A1–C2 proficiency descriptors, the gender values, the image
alt-text, and the localised GDPR declaration.

### Localisation data lives in `lang.toml`, not in code

Following the prevailing Typst Universe convention for multilingual packages
(cf. `modern-cv`), all translations are kept in a single external data file,
**`lang.toml`**, loaded by `lib.typ` with the built-in `toml()` function:

```typst
#let i18n = toml("lang.toml")
```

Why this rather than one file per language (or an inline dictionary)?

- **Translator-friendly.**  Contributors edit plain TOML key/value pairs with
  zero risk of breaking Typst syntax.
- **One reviewable diff.**  A new language or a wording fix touches one file.
- **Keeps `lib.typ` pure logic.**  The entrypoint stays small and readable.
- **No import overhead.**  Per-language modules would each need an `#import`
  and would all be compiled anyway; a single data file is simpler and is the
  established community pattern.

## Gender (inclusive, localisable, omittable)

The `gender` parameter is deliberately flexible, localisable, and omittable:

| Value | Effect |
| --- | --- |
| `none` / `""` | the row is omitted entirely (recommended default) |
| `"male"`, `"female"` | localised label for the active language |
| `"other"` / `"non-binary"` | the EU third option (the "X" / German *divers*) |
| `"undeclared"` / `"prefer-not-to-say"` | an explicit "I prefer not to declare" |
| any other string | passed through verbatim, in the person's own words |

All four semantic values are translated in `lang.toml` for every language.

## Examples

**Browse all 24 examples in the repository →
[`examples/`](https://github.com/Raskolny/europass-cv/tree/v1.0.0/examples)**
(only this README is displayed on Typst Universe, so the links point at
GitHub, pinned to this release's tag).

Each [`examples/<code>.typ`](https://github.com/Raskolny/europass-cv/tree/v1.0.0/examples)
is one complete CV in an EU language, with a persona of the matching
nationality — e.g.
[`examples/bg.typ`](https://github.com/Raskolny/europass-cv/blob/v1.0.0/examples/bg.typ)
→ Георги Иванов, Българин.  They double as the i18n regression suite:

```bash
./build-examples.sh          # compiles all 24 to examples/pdf/ (PDF/UA-1)
```

Where a country's convention includes a photo, the example uses the same
anonymous, gender-neutral placeholder portrait (`assets/photo-placeholder.svg`)
so no real person is depicted.  Lean-CV countries (see the per-example comments
and discussion #3) omit it, keeping the parameter as a commented-out
instruction you can reinstate.

The flagship `main.typ` is written in **English** (the lingua franca of EU
mobility) but keeps an **Italian** persona — a common Europass combination for
EU/international applications.

---

## Accessibility (PDF/UA-1)

The template is engineered for accessibility, not bolted on:

- **Real semantic headings.**  The name is `H1`, sections are `H2`, job/degree
  titles are `H3`.  This produces a genuine PDF outline (bookmarks) —
  PDF/UA-1 rejects documents without one.
- **Layout vs. data.**  The presentational date/content grid uses Typst
  `grid`, which is tagged as layout `Div`s — screen readers never announce a
  bogus data table.  Only the genuinely tabular CEFR grid uses `table` with
  `table.header()`, yielding proper `Table/THead/TH/TD` tags.
- **Text, not colour.**  CEFR levels are always real text.
- **Links.**  Email/website become real `Link` annotations.
- **Lists.**  Bullet skills are tagged `L/LI/Lbl/LBody`.
- **Document metadata.**  `title`, `author`, and the document `lang` are set,
  and `/DisplayDocTitle` is enabled.
- **Alt text.**  `photo-alt` is mandatory for the portrait image.

Typst enforces PDF/UA-1 at compile time via `--pdf-standard 1.7,ua-1`: the
build *fails* if the document would not be accessible.

## Fonts & reproducibility

`fonts/` vendors the complete Open Sans family (Apache-2.0).  The build uses
`--ignore-system-fonts --font-path fonts`, so no glyph is ever resolved from
the host machine, and the PDF embeds **subsetted** Open Sans with a Unicode
CMap (`emb=yes sub=yes uni=yes`) — there is no fallback to local/Base-14 PDF
fonts.  See `fonts/README.md`.

**Typst Universe note.**  Universe policy forbids shipping font binaries
inside a package, so the published bundle does **not** include `fonts/`.
Universe users should install Open Sans (e.g. from
[fonts.google.com/specimen/Open+Sans](https://fonts.google.com/specimen/Open+Sans)
or their distribution's `open-sans` package); alternatively they may pass any
family available to them via the `font:` parameter, which is also the escape
hatch for environments where fonts cannot be installed (such as the Typst web
app).  The vendored copy remains in this repository so that repository builds
stay hermetic and reproducible.

## Verification

`verify.sh` asserts, on the rendered PDF:

1. every font embedded **and** subsetted;
2. no Base-14 / non-embedded font referenced;
3. `/MarkInfo Marked true`, `/StructTreeRoot`, document `/Lang`, XMP metadata;
4. a non-empty PDF outline (H1 root + H2 sections);
5. `H1/H2/Table/THead/TH/TD/L/LI` tags present;
6. the layout grid tagged `Div` (not a data table).

---

## Repository layout

The development repository
([github.com/Raskolny/europass-cv](https://github.com/Raskolny/europass-cv))
holds more than the published package: the vendored fonts, the build and
verification scripts, CI and the contributor docs are all repository-only.

```text
lib.typ               template library (layout + public API; loads lang.toml)
lang.toml             localisation data — all 24 official EU languages
main.typ              end-user entry point — fill this in
assets/               anonymous placeholder portrait + signature sample (SVG)
examples/             one CV per language/nationality (+ pdf/ build output)
fonts/                vendored Open Sans family + Apache-2.0 license
build.sh              canonical hermetic PDF/UA-1 build (main.typ)
build-examples.sh     compiles all 24 examples (PDF/UA-1)
verify.sh             accessibility + font-embedding assertions
typst.toml            Typst Universe package manifest
```

## License

- Template code, examples, docs and scripts: **MIT** (see `LICENSE`).
- Bundled Open Sans fonts: **Apache-2.0** (see `fonts/LICENSE-OpenSans-Apache2.txt`).
- Combined licensing statement: see `NOTICE.md`.

## Author

Massimiliano Milani (**rasko--**)

- GitHub: [@Raskolny](https://github.com/Raskolny)
- LinkedIn: [maxmilani](https://www.linkedin.com/in/maxmilani/)
- Email: <raskolny@gmail.com>
