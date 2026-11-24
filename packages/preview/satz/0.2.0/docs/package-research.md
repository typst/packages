# Typst package candidates for satz

Checked 2026-10-18 against Typst Universe listings and each package's linked upstream documentation/repository. These are third-party packages; Universe explicitly disclaims guarantees of functionality and compiler compatibility. The satz package currently targets broad document classes (letters, invoices, reports, journals, proposals), so a dependency should solve a recurring class-level need or be exposed as an optional specialist tool—not added just because it is impressive.

## Decisions at a glance

| Package | Current Universe version | Scope and fit for satz | Recommendation |
|---|---:|---|---|
| [hydra](https://typst.app/universe/package/hydra) | 0.6.3; MIT; minimum Typst 0.12.0 | Dynamic heading-like reminders for running headers and other locations. High fit for report running heads. | **Integrated in `document-class()` running heads.** Paired KOMA-Script cases pass; journal-specific headers retain their existing implementation. |
| [glossarium](https://typst.app/universe/package/glossarium) | 0.5.10; MIT; minimum Typst 0.13.0 | Glossary entries, first-use long/short forms, plural/capitalized forms, links, backreferences, grouping, and custom printing. Useful especially for reports/theses, but not every satz document. | **Exported as an optional namespace.** `examples/glossary.typ` verifies report composition; the base class requires no glossary setup. |
| [meander](https://typst.app/universe/package/meander) | 0.4.4; MIT; no minimum compiler version shown in listing | Custom page segmentation, text flowing around placed images/obstacles, columns, and overflow. Powerful but specialized and introduces its own layout environment. | **Document-level specialist option.** Do not fold into the base class; test in a concrete report/cover use case first. |
| [tidy](https://typst.app/universe/package/tidy) | 0.4.3; MIT; minimum Typst 0.11.0 | Parses Typst doc-comments and produces module API docs, examples, cross-references, help output, and doc-tests. It documents satz's source; it is not a document-authoring feature. | **Adopt for satz development/docs generation**, not as a runtime dependency re-exported to document users. Note the 0.4.0 documentation syntax migration. |
| [tschich](https://typst.app/universe/package/tschich) | 0.2.0; MIT; no minimum compiler version shown in listing | Computes page margins/type area using classical proportional canons, plus related type-area and font-size helpers. | **Optional layout recipe, likely report/book only.** Keep satz's configured margins as defaults; expose a clear opt-in rather than silently replacing them. |

## Package notes and evidence

### hydra

Hydra's stated purpose is showing heading-like elements at chosen points in a document, particularly reminding readers where they are. Its Universe example places `hydra(1)` / `hydra(2)` inside a contextual page header and switches alignment by page parity, directly matching satz's running-header problem. Universe lists version 0.6.3, MIT, and compiler floor 0.12.0. [Universe listing and example](https://typst.app/universe/package/hydra) · [Upstream repository](https://github.com/tingerrr/hydra).

Integrated in the local development version after the paired KOMA-Script report reproduced five incorrect headers. `class.typ` now pins Hydra 0.6.3, which imports `oxifmt:1.0.0`. Custom selectors include outlined h1/h2 headings; satz explicitly suppresses pages containing an outlined h1 and keeps the existing counter-based alignment. Hydra supplies last-on-page selection and chapter fallback without custom heading state. Twelve-page checks cover unnumbered chapters, non-outlined local headings, counter resets, and overrides; rendered journal and one-page examples remain identical. See [the comparison](../examples/latex-parity/README.md). This is not yet a published release or a general compiler-version compatibility certification.

### glossarium

Glossarium models entries with short/long forms, descriptions, plurals, groups and custom data. It supports first-use forms, reference syntax, links, backreferences, and user-defined printers; the maintainer describes it as inspired by LaTeX's `glossaries`. Universe lists version 0.5.10, MIT, compiler floor 0.13.0. [Universe listing and full usage guide](https://typst.app/universe/package/glossarium) · [Upstream repository](https://github.com/typst-community/glossarium).

Its setup is document-global: `#show: make-glossary` must be installed before term references, and the official guide warns this show rule can conflict with global figure show rules. The local development version exports its upstream namespace through `lib.typ`; installing its show rule and registering a single shared term list remain explicit opt-in actions. The pinned package is loaded with satz, but it does not change ordinary documents unless invoked. No wrapper or implicit registry hides these requirements. The compiled five-page report example verifies first-use expansion, repeat references, unused-term filtering, term links, normal figures/tables, short/long captions, and clean LoF/LoT output. Run `python3 examples/latex-parity/check_glossary.py` to repeat these checks. This verifies the example on Typst 0.15.0, not every upstream printer or show-rule combination.

### meander

Meander's `reflow` function positions obstacles, defines containers, and flows content through them; the docs show image wrap-around, multi-container columns, overflow handling, and custom contour boundaries. Universe lists version 0.4.4 and MIT. [Universe listing and examples](https://typst.app/universe/package/meander) · [Upstream repository and manifest](https://github.com/Vanille-N/meander.typ) · [Upstream `typst.toml`](https://github.com/Vanille-N/meander.typ/blob/master/typst.toml).

This is a layout engine for deliberately composed regions, not a general replacement for normal document flow. The upstream guide specifically calls out `placement: box` where a Meander environment shares pages with surrounding content, and offers explicit overflow controls. That complexity suggests keeping it as an author-facing import for documents that need magazine-style wrapping or designed multi-column pages, rather than making satz's ordinary report body pass through it. The Universe listing does not state a minimum compiler version; check the package against satz's supported Typst versions before adoption.

### tidy

Tidy generates Typst documentation from Typst module doc-comments and supports rendered examples, argument/return types, cross-references, default values, help output, and doc-tests. Its sample API is `parse-module(read("my-module.typ"))` followed by `show-module(...)`. Universe lists version 0.4.3, MIT, compiler floor 0.11.0. [Universe listing and guide](https://typst.app/universe/package/tidy) · [Upstream repository](https://github.com/Mc-Zen/tidy).

This can help make satz's public API and examples easier to maintain, particularly since project conventions require public-function doc comments. It belongs in the documentation/build workflow, not in `lib.typ` as a user-facing dependency. There is a material migration caveat: tidy 0.4.0 changed its default doc-comment syntax; the old parser remains available with `old-syntax: true`. The package's guide also says comment examples are evaluated through `eval`, so examples that call satz functions or read assets need an explicit `scope`.

### tschich

Tschich computes margins from page dimensions. Its basic function implements a nine-part division attributed to van de Graaf's adaptation of Villard's canon; the guide describes further variants, type-area measurements/centering, and estimated font size. Universe lists version 0.2.0 and MIT. [Universe listing and usage](https://typst.app/universe/package/tschich) · [Upstream repository](https://github.com/switchlex/tschich).

It can add an opt-in classical book-layout preset, but it solves a narrower problem than satz's margin configuration. A canon-derived geometry should not silently override custom margins, binding correction, or existing two-sided inside/outside behavior. Before adding a public wrapper, compare its output with satz's current page setup for at least a single-sided and a bound/two-sided report. Universe does not show a minimum compiler version, so verify compatibility directly.

## Integration principles for satz

- Keep specialized features optional and discoverable. A package that only some users need should not force setup or new behavior on every letter/invoice/report.
- Prefer wrappers only where satz can supply a stable, coherent interface and sensible defaults. For example, a class-level Hydra integration may be worthwhile if it demonstrably fixes the existing running-head behavior; exposing every upstream parameter would add coupling without improving the common case.
- Treat Typst compiler floor as a compatibility constraint. Hydra, Glossarium, and Tidy declare floors; Universe does not currently list one for Meander or Tschich, which is unknown rather than evidence of compatibility.
- Pin exact package versions in imports and keep a small compilation fixture for each integration. Recheck upstream release notes when upgrading, especially where show rules, page state, or class-level layout interact.
- Tidy is a development/documentation tool; Glossarium, Meander, Hydra, and Tschich are document-time capabilities. Keep those dependency roles distinct in package structure and user docs.
