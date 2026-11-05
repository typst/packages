# Dorost

**Dorost** (`درست`) is a use-case-neutral Typst package for English, Persian, and mixed-script documents. It provides shared page and typography defaults while leaving content, structure, and visual identity to each author.

> Pre-release: the package is not yet available in Typst Universe. Its package name is `@preview/dorost`; the API may change before 1.0.0.

## Quick start

After publication, create an editable starter with:

```sh
typst init @preview/dorost:0.1.1
```

Or use the package in an existing `.typ` file:

```typ
#import "@preview/dorost:0.1.1": document
#show: document.with(lang: "en", direction: "ltr")

= Your title

Write with native Typst headings, paragraphs, lists, tables, links, code, and math.
```

The package is not tied to a university, course, proposal, thesis, report, or other document type. Consumers compose their own content and identity around the small core API.

### Fonts

The package names the Lora, Vazirmatn, and JetBrains Mono families, but does not distribute font files. Typst packages cannot make bundled fonts available to the compiler. Install those families on your system, or put their `.ttf` files in a project-local `fonts/` directory and compile with:

```sh
typst compile --font-path fonts main.typ
```

Get the fonts from the upstream [Lora](https://github.com/cyrealtype/Lora-Cyrillic/releases/tag/v3.021), [Vazirmatn](https://github.com/rastikerdar/vazirmatn/releases/tag/v33.003), and [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono/releases/tag/v2.304) releases. The automated checks fetch checksum-pinned test fonts from those releases; see [tests/fonts/README.md](tests/fonts/README.md).

## Configuration

`document` sets page geometry, text language/direction/font/size/color, paragraph leading/spacing, list indentation/spacing, and LTR code styling. It does not add titles, headers, metadata, or sections.

```typ
#show: document.with(
  lang: "fa",
  direction: "rtl",
  page: (paper: "a4", margin: (x: 24mm, y: 22mm)),
  fonts: (body: ("Lora", "Vazirmatn"), code: "JetBrains Mono"),
  text: (size: 11pt, paragraph-spacing: 0.8em),
  colors: (accent: rgb("235789")),
)
```

Language, direction, font roles, and digit formatting are independent. `lang` is a non-empty language tag; `direction` accepts the string `"ltr"` or `"rtl"`. Partial option dictionaries override only supplied fields. Unknown keys and invalid language/direction values produce clear errors.

| Export | Default |
| --- | --- |
| `default-fonts` | Body: Lora with Vazirmatn fallback; code: JetBrains Mono |
| `default-page` | A4 with 2 cm horizontal and vertical margins |
| `default-text` | 11 pt; 0.65 em leading; 1 em paragraph spacing; 0.6 em list indent and spacing |
| `default-colors` | Body text; muted footnotes; accent headings and links; rule lines |

Override either font role with a string or a Typst font fallback array. Lora covers Latin; Vazirmatn supplies Persian glyphs. Vazirmatn includes regular and bold faces; Typst may synthesize other faces. Math uses Typst's embedded math font. If the named fonts are unavailable, Typst warns and substitutes available fonts; Persian glyph coverage and layout can differ.

## Mixed direction and Persian digits

`ltr[content]` and `rtl[content]` apply only local text direction. Use them around Latin identifiers, URLs, or RTL phrases when needed. They do not select language or font. Raw code is automatically LTR and uses the code font role.

`persian-digits(value)` explicitly maps ASCII digits `0`–`9` to Persian digits in strings and integers. It preserves punctuation and other string characters. It does not inspect or modify arbitrary Typst content, code, URLs, or math.

```typ
#import "@preview/dorost:0.1.1": document, ltr, persian-digits
#show: document.with(lang: "fa", direction: "rtl")

شناسه #ltr[API.get(2)] و تاریخ #ltr[#persian-digits("2026-10-11")]
```

See [`examples/`](examples/) for English, Persian, mixed-direction, and custom-theme sources.

## Development and verification

Requires Typst 0.15.0 or later, `pdftotext`, Python 3.11+, and internet access on the first test run to fetch checksum-pinned upstream test fonts. CI checks the minimum supported Typst version (0.15.0) and current stable version (0.15.1).

```sh
./scripts/check.sh
```

The check compiles all fixtures and examples with system fonts disabled, tests configuration failures, checks PDF text extraction, validates the template thumbnail path, checks manifest rejection, and initializes and compiles the starter in a temporary directory with project-local fonts. Test font binaries are downloaded from their upstream releases, checksum-verified, cached outside the repository, and removed from the build directory afterward. Poppler's `pdftotext` can reorder characters and punctuation inside right-to-left spans, including words with ZWNJ; exact authored Persian words are checked in the fixture source, while rendered Persian layout should be visually inspected. Generated PDFs are removed after the run. GitHub Actions runs the same command on both supported compiler versions.

## License

Package code is MIT licensed. The copied starter in `template/` is MIT-0. Tests fetch font fixtures from upstream releases under the SIL Open Font License 1.1; no font binaries are stored in this repository or included in the package. The package manifest's SPDX expression is `MIT AND MIT-0`. See [LICENSE](LICENSE), [LICENSE-MIT-0](LICENSE-MIT-0), and the upstream font releases linked in [tests/fonts/README.md](tests/fonts/README.md).

## Contributing and releases

See [CONTRIBUTING.md](CONTRIBUTING.md) for pull-request checks, scope, and the release process. Use [GitHub Issues](https://github.com/alirezaopmc/dorost/issues) for support and bug reports; see [SUPPORT.md](SUPPORT.md). Report security issues privately as described in [SECURITY.md](SECURITY.md).
