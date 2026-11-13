# Research and grant proposals

The development version of Satz provides a DFG 53.01 project-description layout
and a separate general research/project proposal layout. Both use the shared
`document-class()` shared foundation and deep configuration merge. These changes are included in
the unpublished 0.2.0 candidate.

## DFG 53.01: start with the complete form

Copy [the English starter](../dfg-proposal/example.typ) or
[the German starter](../dfg-proposal/example-de.typ). Each contains all five
sections and the nested headings from the official **09/26** form, including
fourth-level safety and funding headings. Replace the relative import with your
installed development package import when using the file outside this repo:

```typst
#import "@local/satz:0.2.0": dfg-proposal, dfg-supplement, dfg-publications, proposal-budget
#show: dfg-proposal.with(
  applicant: [Example Applicant, Example University, Example City],
  project: [Project title],
  language: "english", // or "german"
)

= Starting Point
*State of the art and preliminary work*
Your text.

= Objectives and work programme
// Keep all subsections from the complete starter.

= Project- and subject-related list of publications
// #dfg-publications("references.bib", size: 9pt)

#dfg-supplement()
= Supplementary information on the research context
// Keep all subsections from the complete starter.

= Requested modules
// Keep all subsections from the complete starter.
```

Use ordinary headings without typing section numbers. The shared heading
counter supplies `1`, `2.1`, `4.1.4.1` and `5.1.3.2`. For additional text headings
inside a prescribed section, use bold text or
`#heading(numbering: none, outlined: false)[Your heading]` so the form's numbers
remain intact. In particular, “State of the art and preliminary work” is an
unnumbered prompt, not section 1.1.

Insert `dfg-supplement()` **exactly once, immediately before section 4**.
It starts a fresh page and resets the page counter to 1 while heading numbering
continues. Headers display `page N of max. 17` for the first part and
`page N of max. 8` for the second part, localized in German. The header uses
physical page locations relative to the part boundary: a page-start header
cannot accidentally read the counter before the body's reset. Do not add manual
page-counter resets. Ordinary `pagebreak()` calls are supported.

The first part is limited to 17 pages and the second to 8. Compilation fails
when a limit is exceeded. Pass `check-pages: false` for an overlength working
draft; the header still displays the applicable limit. The legacy `max-pages`
argument changes the first-part allowance only; keep its default for DFG 53.01.
A document containing only the research part can omit `dfg-supplement()`.

Defaults use A4, Arial 11pt, 25mm left/top, 20mm right and 15mm bottom margins,
black text on white, no cover, no contents and no footer. The DFG defaults now
translate emtpb/KOMA's vertical rhythm: an approximately 13.549pt body baseline,
5.5pt paragraph skip and distinct before/after skips for all four heading levels.
Typst's `leading` and block gaps are line-box distances, so copying LaTeX's
numeric values directly produces compressed headings. The wrapper also handles
stacked headings, hanging continuation lines and the page-top baseline.
All values remain configurable through the ordinary deep-merged config.
General Satz documents now also use a [shared KOMA heading policy](heading-spacing.md);
DFG retains the distinct skips prescribed by its reference class.
Arial must be installed: Typst can otherwise substitute a font and issue a
warning. The regression fixture rejects compiler warnings. Tables and captions
also default to 11pt. Shared `config` overrides remain available, but changing
these values does not imply that the resulting document retains DFG formatting.

`dfg-publications(path("references.bib"), size: 9pt, style: "apa")` renders the
bibliography without adding a second heading. Place it under section 3. Sizes
below 9pt are rejected. Native citation styles and bibliography arguments remain
available, including `full: true`. Cite works in sections 1–2 using ordinary
Typst citations. For automatic highlighting by BibTeX key, use the optional CSL workflow below.
The template cannot infer which papers are yours: select their keys explicitly.

## Automatic selected-publication highlighting

You do not need to edit the `.bib` file or format entries by hand. The optional
CSL workflow selects complete entries by their unique BibTeX keys:

```typst
#import "@local/satz:0.2.0": dfg-proposal, proposal-citations, dfg-publications
#show: dfg-proposal.with(applicant: [Example Author], project: [Project title])
#show: proposal-citations.with(
  read("references.bib"),
  highlight: ("author2024", "author2025"),
)

// Write the complete prescribed sections here, using ordinary @key citations.
// In section 3:
#dfg-publications()
```

Keep `proposal-citations` after the layout show rule. It accepts **BibTeX file
text**, so `read(...)` resolves relative to your document. `highlight` is an
array of keys; unknown and duplicate keys are rejected. Complete selected
bibliography entries become bold, including italic publication names. In-text
citations and unselected entries retain regular weight. References keep their
citation destinations; bibliography entries link to their DOI or URL when
available. DFG styling preserves clickable links.

With this workflow, call `dfg-publications()` without a source. It enforces a
maximum of ten **printed** highlighted entries and the 9pt minimum size.
For general proposals use `proposal-publications(size: 11pt)` instead.
Without this show rule, continue using the native
`dfg-publications(path("references.bib"))` API; a `path(...)` value resolves
relative to your caller, unlike a path string evaluated inside a helper.
Do not combine a native bibliography with the CSL workflow in one document.

The bundled style is Satz's own **author-date** format, not an APA compliance
claim. Pass `style: read("custom.csl")` to `proposal-citations` for a different
CSL style. The native helper's `style:` argument does not configure the optional
CSL backend. To include uncited entries or grouped citations, use Citrus's
`nocite` or `multicite` API explicitly.

This workflow lazily imports MIT-licensed `citrus:0.2.1` and
`citegeist:0.2.1`; ordinary Satz documents keep their native citation backend.
Typst downloads those packages on first use. Citrus/Citegeist is an independent
CSL/BibTeX implementation: complete BibLaTeX macro, crossref and arbitrary CSL
parity has not been established. Test your actual database and custom style.
See [the runnable example](../examples/proposal-publications.typ) and run
`python3 examples/latex-parity/check_publications.py` with `pdfplumber` and
`pypdf` installed. Tests inspect bold/italic versus regular PDF fonts, citation
and DOI destinations, unknown/duplicate keys, the ten-item limit and the original
native bibliography path.

## Work packages and Gantt charts

Use `work-package` for automatically numbered, referenceable summaries with
objectives, tasks, deliverables, milestones and contingency plans. Use
`proposal-gantt` for monthly/quarterly schedules with work-package groups,
split phases, milestone diamonds and optional resource columns. See the
[planning guide](proposal-planning.md) and
[complete example](../examples/proposal-planning.typ).

## Budgets

The shared `proposal-budget` helper replaces LaTeX's `funds`, `position` and
`positionmul` arithmetic with explicit rows and an exact total:

```typst
#proposal-budget((
  (description: [Research associate], unit-cost: 500000, quantity: 12),
  (description: [Travel], unit-cost: 125000, quantity: 2),
  (description: [Materials], unit-cost: 75000),
), language: "english")
```

Prices are **integer euro cents**: `500000` means €5,000.00. Quantity defaults
to 1 and must be a positive integer. Negative or fractional-cent prices are
rejected. Rows show quantity × price, the subtotal, and the grand total; `language:
"german"` switches labels and the decimal separator. `total-label:` supplies a
custom final label. Totals are local to each table, with no shared mutable state.

## General research/project proposal

Use `research-proposal` or its alias `project-proposal` for a proposal without a
prescribed funder form:

```typst
#import "@local/satz:0.2.0": research-proposal
#show: research-proposal.with(
  title: [A reproducible measurement platform],
  short-title: [Measurement platform],
  applicants: [Dr. Example Author],
  institution: [Example University],
  summary: [The research question, approach and expected contribution.],
)

= Motivation and research question
Your text.

= Objectives
Your text.
```

The title and optional summary appear inline. Pages start at 1 and the header
shows current/total pages throughout. Use `short-title` when the full title is
too long for the header. Optional `date:` accepts content. Shared `config:`
settings control typography, margins and headings; `language: "german"` localizes
the summary and page label. No mandatory section list or page allowance is
imposed. [The complete example](../proposal/example.typ) includes objectives,
work packages, milestones, feasibility, risks, ethics/data, a budget and outputs.

## Sources, verification and scope

Authoritative sources checked on 20 October 2026:

- [DFG 53.01 form page, revision 09/26](https://www.dfg.de/de/formulare-53-01-elan-246768),
  with [English RTF](https://www.dfg.de/resource/blob/168206/53-01-en-elan.rtf)
  and [German RTF](https://www.dfg.de/resource/blob/168204/53-01-de-elan.rtf).
  Heading text and page geometry were checked against both downloaded forms.
- [DFG 54.01 preparation instructions, revision 09/26](https://www.dfg.de/resource/blob/168314/5344518bed1e420aebded6e5b1f3e857/54-01-en-data.pdf):
  17/8-page limits, minimum body/publication text sizes and line spacing.
- [emtpb/proposal_dfg](https://github.com/emtpb/proposal_dfg), the primary LaTeX
  reference: bilingual title/header, four-level numbering, separate page counts,
  bibliography sizing and itemized fund calculations.
- [klb2/dfg-proposal-template](https://github.com/klb2/dfg-proposal-template),
  a secondary feature/layout reference. Satz uses an independent native Typst
  implementation; it does not incorporate that repository's GPL class code.

This implements the **53.01 project-description workflow**, not every form
handled by emtpb's class. Forms 53.02, 53.20 and 53.200, clinical variants,
CVs, optional decorative title pages and LaTeX-specific macros are outside this
implementation. It is not a pixel-for-pixel reproduction of LaTeX or an official
DFG product. Proposal content, required attachments and current call-specific
requirements still need checking before submission.

Run `python3 examples/latex-parity/check_proposals.py` with `typst`, Arial and
`pdfplumber` installed. It checks both complete starters, every header in a
25-page boundary fixture, overflow rejection, draft mode, duplicate part breaks,
fonts/margins, four-level numbering, bibliography sizes, the existing DFG
consumer, the general template, and exact budget arithmetic. Rendered English,
German and general-proposal PDFs are also reviewed visually. Generated PDFs are
not committed. A real invoice consumer also compiled against the package, with
an existing optional-content warning from its PDF logo. A legacy journal's
cover call uses an incompatible older API, so its full-document check could
not complete; that consumer was left unchanged. The focused proposal suite also
passes against a clean staged snapshot without unrelated workspace edits.

## NWO Talent Programme

Veni, Vidi and Vici authoring layouts now have explicit 2026 profiles and
scheme/domain-specific starters. See the [NWO guide](nwo-proposals.md) for the
15 represented combinations, typography, form sources, tests and concrete
remaining gaps. The full Vici form prohibits own-publication highlighting;
the optional CSL workflow enforces this distinction from DFG.

## DFG typography comparison and known limits

The paired specimens now compare the **actual independently compiled** LaTeX
reference with Satz, rather than merely asserting positive heading gaps. Run:

```
python3 examples/latex-parity/check_proposal_rhythm.py --output /tmp/satz-dfg-comparison
```

Requirements: Typst, LuaLaTeX with the reference class's packages, Arial,
`pdfplumber` and `pypdf`. The unmodified upstream class and license are pinned
under `examples/latex-parity/reference`; no download is needed. See its README
for the explicit physical-font normalization and provenance.

Both specimens match page count and every text row's vertical bounds within
0.02pt. Coverage includes title/rule, headers, body/paragraph rhythm, all four
heading levels, consecutive headings, multiline hanging indents, page-start
headings, lists and table rows. Explicit leading overrides and PDF heading
bookmarks are also checked. The complete DFG suite separately checks bilingual
headers, resets and page limits. Text justification and optical margin behavior
still differ between TeX and Typst; arbitrary manuscripts are not guaranteed
pixel-identical. Math, footnotes, floats and custom citation styles require their
own comparisons. The template currently implements DFG **53.01**, not the other
forms exposed by the upstream LaTeX class.
