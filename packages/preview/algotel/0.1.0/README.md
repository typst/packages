# AlgoTel/CoRes Typst Template

A Typst template for submissions to the [AlgoTel](https://algotel.eu.org/) and CoRes conferences, derived from the LaTeX class `algotel.cls`.

## Quick Start

### Using `typst init` (recommended)

```sh
typst init @preview/algotel
cd algotel
typst compile main.typ
```

### Manual import

```typst
#import "@preview/algotel:0.1.0": algotel, qed
#import "@preview/algotel:0.1.0": theorem, lemma, proposition, corollary, definition, remark, example, proof

#show: algotel.with(
  title: [My Title],
  authors: (
    (name: "Author Name", affiliations: (1,)),
  ),
  affiliations: (
    (id: 1, name: "Lab, University, City, Country"),
  ),
  abstract: [Abstract text.],
  keywords: ("keyword1", "keyword2"),
  lang: "fr",  // "fr" or "en"
)
```

## Parameters

The `algotel()` function accepts the following parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | content | *required* | Document title |
| `short-title` | content | `none` | Short title for running headers (uses `title` if omitted) |
| `authors` | array | *required* | List of author dictionaries (see below) |
| `affiliations` | array | `()` | List of affiliation dictionaries |
| `abstract` | content | `none` | Abstract text |
| `keywords` | array | `()` | List of keyword strings |
| `lang` | string | `"fr"` | Language: `"fr"` (French) or `"en"` (English) |
| `paper` | string | `"a4"` | Paper size: `"a4"` or `"us-letter"` |
| `front-matter-spacing` | dictionary | `auto` | Override front matter spacing (see below) |

### Author format

```typst
(name: "Full Name", affiliations: (1, 2), thanks: "Optional acknowledgement")
```

### Affiliation format

```typst
(id: 1, name: "Lab, University, City, Country")
```

### Front matter spacing

The `front-matter-spacing` parameter accepts a dictionary with any of these keys:

| Key | Default | Description |
|-----|---------|-------------|
| `after-title` | `16pt` | Space after the title |
| `after-authors` | `6pt` | Space after author names |
| `after-affiliations` | `10pt` | Space after affiliations |
| `after-rule-top` | `2pt` | Space after the top rule |
| `after-abstract` | `4pt` | Space after the abstract |
| `after-keywords` | `4pt` | Space after keywords |
| `after-rule-bottom` | `10pt` | Space after the bottom rule |

## Theorem Environments

The template provides theorem-like environments via [lemmify](https://typst.app/universe/package/lemmify). They share a single counter and automatically switch to French or English labels based on the `lang` parameter.

**Numbered (italic body):** `theorem`, `lemma`, `proposition`, `corollary`

**Numbered (normal body):** `definition`

**Unnumbered (normal body):** `remark`, `example`

**Proof:** `proof` -- ends with a QED symbol ($\square$). You can also use `#qed` manually.

```typst
#theorem(name: "Optional name")[
  Statement of the theorem.
]

#proof[
  Proof of the theorem.
]
```

## Fonts

The template uses a font fallback chain compatible with the LaTeX version:

| Usage | Primary | Fallback 1 | Fallback 2 |
|-------|---------|------------|------------|
| Body text | Libertinus Serif | TeX Gyre Termes | Liberation Serif |
| Headings | TeX Gyre Heros | Liberation Sans | -- |
| Code | TeX Gyre Cursor | Liberation Mono | -- |

**Installation (Debian/Ubuntu):**

```sh
apt install fonts-texgyre fonts-libertinus fonts-liberation
```

Fonts are also available from:
- [TeX Gyre](https://www.gust.org.pl/projects/e-foundry/tex-gyre) (GUST e-foundry)
- [Libertinus](https://github.com/alerque/libertinus/releases)
- [Liberation](https://github.com/liberationfonts/liberation-fonts/releases)

If preferred fonts are not installed, Typst falls back automatically. The [Typst web app](https://typst.app) includes TeX Gyre fonts by default.

## Examples

The repository includes two complete sample documents:

- [`sample-algotel-fr.typ`](sample-algotel-fr.typ) -- French example
- [`sample-algotel-en.typ`](sample-algotel-en.typ) -- English example

Compile them with:

```sh
typst compile sample-algotel-fr.typ
typst compile sample-algotel-en.typ
```

## External Packages

The template does **not** re-export external packages. Import them directly in your document:

```typst
#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3"
#import "@preview/fletcher:0.5.8"
#import "@preview/algo:0.3.6"
```

## Release Process

### Publishing a new version to Typst Universe

1. Update `algotel.typ` as needed
2. Bump `version` in `typst.toml` (e.g., `"0.1.0"` → `"0.2.0"`)
3. Update the version in the import of `template/main.typ`
4. Regenerate `thumbnail.png` if the appearance changed:
   ```sh
   typst compile sample-algotel-fr.typ thumbnail.png --pages 1 --ppi 300
   ```
5. Commit and push to `main`
6. Create a tag and push it:
   ```sh
   git tag v0.2.0 && git push origin v0.2.0
   ```
7. The GitHub Actions workflow pushes a branch to the `typst/packages` fork
8. Open a PR from the fork branch to `typst/packages:main`
9. Wait for review and merge by Typst maintainers

### Manual publishing (fallback)

1. Sync your fork of [`typst/packages`](https://github.com/typst/packages)
2. Create `packages/preview/algotel/0.2.0/`
3. Copy into it: `algotel.typ`, `typst.toml`, `template/`, `thumbnail.png`, `README.md`, `LICENSE`, `algotel-logo-bw-transparent.png`
4. Open a PR to `typst/packages:main`

### Initial setup (one-time)

1. Fork [`typst/packages`](https://github.com/typst/packages) on GitHub
2. Create a fine-grained PAT with **Contents** permission on the fork
3. Add the PAT as a secret named `REGISTRY_TOKEN` in this repository
4. Update `REGISTRY_FORK` in `.github/workflows/release.yml` to match your fork

## License

[MIT](LICENSE) -- Fabien Mathieu, Quentin Bramas, Jean-Romain Luttringer
