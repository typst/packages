# Contributing

Thanks for helping improve the europass-cv project (published on Typst Universe
as `rasko-europass`)!  This document covers the development
setup and the conventions that keep the package accessible and reproducible.

## Development setup

You need:

- [Typst](https://typst.app) **≥ 0.15** (`typst --version`)
- `poppler-utils` (provides `pdffonts`, used by `verify.sh`)
- Python 3 with `pymupdf` (used by `verify.sh` to inspect the PDF tag tree)

Then:

```bash
./build.sh                 # hermetic PDF/UA-1 build of main.typ + verification
./build-examples.sh        # compile all 24 language examples
```

Both scripts use `--ignore-system-fonts --font-path fonts`, so results are
identical on every machine.  Never commit `output.pdf` or `examples/pdf/`
(they are gitignored).

## Adding or fixing a language

All translations live in **`lang.toml`** — do not add strings to `lib.typ`.

1. Edit (or add) the `[<code>]` table in `lang.toml`.  Keep the full key set;
   the required keys are the ones already present for `en` (section headers,
   personal-info labels, CEFR labels, `levels`, gender values, `photo-alt`,
   `declaration`, …).
2. Add a matching example `examples/<code>.typ` with a persona of that
   nationality, using the anonymous placeholder photo.
3. Run `./build.sh` and `./build-examples.sh`; both must pass.  The build is
   PDF/UA-1-strict, so a missing translation or an untagged element fails CI.

## Accessibility rules (please preserve these)

- Section titles and entry titles must remain real `heading` elements
  (`H1`/`H2`/`H3`); PDF/UA-1 rejects documents without an outline.
- The two-column date/content layout must stay a Typst **`grid`** (tagged as
  layout `Div`).  Do not convert it to a `table` — that would announce a bogus
  data table to screen readers.  Only genuinely tabular data (the CEFR grid)
  uses `table` with `table.header()`.
- Never encode meaning in colour alone: CEFR levels are always real text.
- Any image needs `alt` text (see `photo-alt`).
- Run `./verify.sh` before opening a PR; it asserts all of the above on the
  rendered PDF.

## Fonts policy

The vendored family in `fonts/` is **Open Sans (Apache-2.0)** and covers all
24 EU languages plus Turkish and Vietnamese.  If you ever add a font it must
carry a redistribution-friendly licence (OFL / Apache-2.0), ship its licence
text in `fonts/`, and be documented in `fonts/README.md`.  Keep `body-font`
listing only vendored families so `--ignore-system-fonts` stays warning-free.

## Pull requests

- Keep changes focused; one concern per PR.
- Update `CHANGELOG.md` under an `Unreleased` heading.
- CI must be green (it runs the hermetic build, the verifier, and all 24
  examples).
