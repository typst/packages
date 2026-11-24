# Shared heading spacing

Satz now defaults to `headings.spacing: "koma"` in the shared class. Reports,
articles and general proposals inherit this policy. Existing template-specific
lengths and document overrides take precedence. The book keeps its custom
chapter opener, while subsection levels use the shared measured policy; the DFG
form retains its form-specific rendering.

KOMA's before/after skips are measured between baselines. Typst's block gaps
sit between line boxes. `heading-layout.typ` measures cap height, x-height,
leading and paragraph distance in the chosen font, then translates the skips.
Changing fonts or heading sizes therefore does not require hand tuning gaps.

The standard section skips are 3.5ex before / 2.3ex after level one, and
3.25ex / 1.5ex for levels two and three. Level four uses the 3.25ex before-skip
but stays a block heading with zero extra after-skip; KOMA normally runs its
paragraph heading into the following text. Consecutive headings suppress the
second before-skip while retaining the preceding after-skip. Wrapped headings
have hanging continuation indents and stay attached to the following block.

Explicit `h1-above`, `h1-below`, … `h4-below` lengths remain Typst block gaps.
`auto` now selects the measured KOMA value. Set
`config: (headings: (spacing: "native"))` to use the native renderer; add explicit
per-level lengths if recreating an older layout. Body leading, paragraph spacing,
font sizes and colors are unchanged by this policy. Existing documents can reflow.

Run `python3 examples/latex-parity/check_typography.py` for the original native
opt-out and paragraph/page-boundary checks, plus the shared KOMA comparison.
The independent `check_shared_headings.py` needs LuaLaTeX, Typst, Arial,
`pdfplumber` and `pypdf`. Its reference uses standard `scrartcl` section skips,
normalizes physical font sizes and baseline distances to match the specimen,
and compares relative positions to exclude page-top conventions. It covers
mixed heading sizes and consecutive headings within 0.05pt, page attachment,
explicit gaps, equations, cross-references and bookmarks. It also measures the
rendered book subsection gaps and requires each heading to sit closer to its
following text than to the preceding paragraph. This is a heading rhythm
comparison, not a claim of identical full-document pagination.

## Journal opening

Journal entries group their title, date and keywords in one unbreakable, sticky
header block. `config: (journal: (header-below: 1.5em))` controls one non-collapsing
gap before the notes, whether the body starts with a heading, prose or a list.
Later headings retain their ordinary spacing. The body stays in the page flow,
so explicit page breaks remain supported.

Continuation-page headers reserve an unbroken date column and wrap the entry
title in the remaining width. `journal.running-gutter` defaults to 1em and
`journal.running-leading` to 0.35em, both resolved at the running-header size.
The date stays right-aligned, level with the first title line, and separate
from every wrapped continuation line.
