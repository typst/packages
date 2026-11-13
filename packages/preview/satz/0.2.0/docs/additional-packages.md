# Additional Typst package review

Reviewed 2026-10-18 against the current satz roadmap. This covers candidates beyond Hydra, Glossarium, Meander, Tidy, and Tschich. Versions and licenses are those listed by Typst Universe at review time; this is a research review, not an integration or compatibility test.

## Recommendation

Keep standard tables, figures, captions, and basic diagrams native to Typst. Add small package trials where they fill a concrete gap: **Zero** for decimal and uncertainty alignment, **Subpar** for labeled subfigures, **Unify** for SI quantities, and **Marginalia** for margin notes. Treat **Fletcher** as an optional user-facing diagram toolkit, not a core dependency. Do not adopt Tablex: its own page recommends native tables because most features were upstreamed.

| Priority | Package | Current version / license | Fit for satz |
|---|---|---|---|
| Trial first | [Zero](https://typst.app/universe/package/zero/) | 0.7.1 · MIT | Decimal, uncertainty, and exponent alignment for scientific tables; also number, unit, and quantity formatting. Works through `show table` or its `ztable` wrapper, with documented interoperability. This directly addresses the table roadmap. Test whether Zero can be applied behind a satz table helper without constraining users to its API. The latest version contains breaking changes, so pin it and check its changelog before upgrades. |
| Trial first | [Subpar](https://typst.app/universe/package/subpar/) | 0.2.2 · MIT | Adds grids of separately captioned and referenceable subfigures inside an overall figure. Native `figure` already handles figure/table captions, counters, labels, and caption styling; Subpar fills the subfigure gap. Universe lists Typst ≥0.12.0. The package is larger than the other candidates (494 kB), so test PDF size and interaction with satz’s figure/list-of-figures rules. |
| Trial first for technical docs | [Unify](https://typst.app/universe/package/unify/) | 0.8.1 · MIT | Typesets numbers, uncertainties, ranges, and physical/monetary/binary units; a useful siunitx-like option for scientific and engineering documents. Supports English and Russian per its package page, and its author describes it as less mature than siunitx. Avoid making it mandatory for letters and general reports. Compare with Zero’s `zi` units API before choosing one public recommendation; they overlap. |
| Optional feature trial | [Marginalia](https://typst.app/universe/package/marginalia/) | 0.3.1 · Unlicense | Provides outside/inside margin notes, note references, and wide blocks, with book-aware inner/outer margins and note collision avoidance. This maps to satz’s “Margin notes” roadmap item. Try it on two-sided pages with binding correction and satz headers; placement depends on page geometry and may conflict with custom layouts. |
| Optional / user imported | [Fletcher](https://typst.app/universe/package/fletcher/) | 0.5.8 · MIT | Higher-level arrow and node diagrams, including flowcharts and commutative diagrams; built on CeTZ. Useful in reports, proposals, and technical writing, but ordinary shapes and lines are already native. Keep as an optional example or import rather than wrapping it into satz’s core API. Universe lists Typst ≥0.13.0. |
| Consider only if table syntax remains a pain | [Pillar](https://typst.app/universe/package/pillar/) | 0.3.3 · MIT | Compact column specifications and optional Zero decimal alignment, while emitting native `table` arguments so normal table features remain available. Could make common table layouts easier, but overlaps the planned satz table helpers and adds another syntax. Prototype against the same examples before deciding between this and a satz-native helper. |

## Native Typst already covers

- **Tables:** Native `table` supports per-column alignment and sizing, cell styling, strokes, fills, and show rules. Prefer this over Tablex; its Universe page explicitly says to use built-in tables because most of its functionality was incorporated upstream.
- **Captions:** Native `figure` captions support styling and placement. It detects tables versus figures and maintains separate counters; labels and references are built in. This means a package is unnecessary for basic captions or a list of tables/figures.
- **Diagrams:** Native drawing primitives cover simple lines, shapes, and layout. CeTZ is a general drawing dependency and Fletcher builds on it; add a higher-level tool only when real examples demonstrate repeated diagram work.
- **Units:** Typst math can typeset units manually, but it does not provide a full siunitx-like parser and formatter. Zero and Unify both address this; choose based on real satz examples rather than adding both by default.

## Suggested trial order

1. Make representative satz table examples (plain, decimal-aligned, and uncertainty-aligned). Compare native tables plus Zero with Pillar plus Zero. Choose one ergonomic path, if any.
2. Build a satz report with a two-panel Subpar figure and verify references, caption numbering, and list-of-figures behavior.
3. For a technical report, compare Zero’s and Unify’s quantity APIs for number/range formatting, language behavior, and units used in the project.
4. Test Marginalia on two-sided and one-sided satz pages, including binding correction and crowded adjacent notes.
5. Include Fletcher only in an optional diagram example if diagrams recur in the LaTeX reference documents.

## Sources

- Typst table reference: <https://typst.app/docs/reference/model/table/>
- Typst figure reference: <https://typst.app/docs/reference/model/figure/>
- Typst Universe: [Zero](https://typst.app/universe/package/zero/), [Subpar](https://typst.app/universe/package/subpar/), [Unify](https://typst.app/universe/package/unify/), [Marginalia](https://typst.app/universe/package/marginalia/), [Fletcher](https://typst.app/universe/package/fletcher/), [Pillar](https://typst.app/universe/package/pillar/), [Tablex](https://typst.app/universe/package/tablex/)
- Upstream source and docs: [Zero](https://github.com/typst/packages/tree/main/packages/preview/zero), [Subpar](https://github.com/tingerrr/typst-subpar), [Unify](https://github.com/typst/packages/tree/main/packages/preview/unify), [Marginalia](https://github.com/nleanba/typst-marginalia), [Fletcher](https://github.com/Jollywatt/typst-fletcher), [Pillar](https://github.com/Mc-Zen/typst-pillar)
