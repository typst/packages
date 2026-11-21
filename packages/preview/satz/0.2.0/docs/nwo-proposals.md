# NWO Talent Programme proposals

The unreleased `nwo-proposal` template covers Veni, Vidi and Vici with explicit
scheme, domain, application-stage and year profiles. It uses the published 2026
forms, rather than applying the historical six-section LaTeX example to every
current application. These APIs are included in the unpublished 0.2.0 candidate.

## Start writing

```typst
#import "@local/satz:0.2.0": nwo-proposal
#show: nwo-proposal.with(
  scheme: "veni", domain: "science", stage: "pre", year: 2026,
)

= NWO domain and field of research
== NWO domain
Science (ENW)

== Main field of research
Your field and code.

= Evidence-based curriculum vitae
// Continue with the sections in the starter.
```

The starters are [Veni](../nwo-proposal/veni.typ),
[Vidi](../nwo-proposal/vidi.typ), [Vici](../nwo-proposal/vici.typ) and
[Vici full](../nwo-proposal/vici-full.typ). The pre-proposal starters include
`pre-body.typ`; copy that supporting file too, or replace the include with its
contents. They contain brief examples and explicit placeholders, not completed
applications. In particular the example CV does not satisfy the final minimum
word counts. Use the official explanatory notes while filling out the fields.

Domain values are `science` (ENW), `ssh` (SGW), `aes` (TTW) and `zonmw`.
For a starter in another domain, compile with e.g.
`typst compile --root . --input domain=zonmw nwo-proposal/veni.typ output.pdf`.
In your own source, set `domain:` directly. The generated numbering is `1`,
`2a.`, `2a1.`, `2a1a.`; do not type the section numbers yourself.

Optional `applicant:` and `title:` content add identifying text below the form
title. Defaults omit both because current forms request some details in their
own fields. A `config:` dictionary accepts ordinary Satz overrides.

## Coverage checked against downloaded forms

| Scheme / stage, 2026 | Science | SSH | AES | ZonMw |
|---|---|---|---|---|
| Veni pre-proposal | Included | Included | Included | Included |
| Vidi pre-proposal | Included | Included | Included | Included |
| Vici pre-proposal | Included | Included | Included | Source unavailable |
| Vici full proposal | Included | Included | Included | Included |
| Veni / Vidi full proposal | Not represented | Not represented | Not represented | Not represented |

There are **15 represented combinations**. `nwo-profile(...)` returns their
source URL, body size and supported word limits. Unknown schemes, years or
unsupported stage/domain combinations fail explicitly. In particular, changing
`stage: "full"` on a Veni/Vidi profile does not silently produce a relabeled
old form. Their full-proposal 2026 forms were not linked on the consulted call
pages. The Vici ZonMw pre-proposal source could not be retrieved from the
current page/archive locations; it is not inferred from another domain.

The three NWO domains share a source file per scheme/stage, with domain-specific
rules. The ZonMw variants are separate files. The starters account for the
observed differences: Veni's ZonMw research idea is entered online; the full
Vici ZonMw PDF omits scientific/public summaries and the NWO-domain budget
section, retaining the overlapping-funding section instead. AES Vici includes
the stakeholder/user-committee prompt; SSH/Science omit it. Mandatory budgets,
embedding guarantees and other attachments remain separate official forms.

These are reconstructed authoring layouts and field scaffolds, **not certified
or pixel-identical reproductions** of the Word forms. The source structure,
selected constraints and generated PDFs were checked. Every static instruction,
text box, declaration, exclusion and portal field has not been reproduced or
automatically validated. Compare the final application with the downloaded
form for the exact call. Do not call the entire NWO application workflow fully
verified on the strength of these tests.

## Typography and page headers

NWO's 2026 forms specify Calibri or a close equivalent, 9.5pt for pre-proposals,
10pt for the full Vici form, single spacing and 25mm margins. Satz uses Arial as
the available sans-serif alternative, A4, black body text, the source form's teal
heading color and 25mm margins. The form's single-spacing requirement is why
this wrapper specifies `typography.leading: 0.5em`: with Arial this measures
about 1.22 times the font size between baselines (about 11.55pt at 9.5pt).
Typst leading is added space between line boxes, not a Word/LaTeX multiplier.

All paragraph spacing and gaps around headings inherit the shared Satz defaults.
There is no compressed 0.1em heading gap. A `config` override such as
`(typography: (leading: 0.65em))` remains available for a more open working draft;
check formatting against the source before submission. The official pre-proposal
notes request 25mm margins even though the source XML has a smaller bottom
margin in places; this implementation follows the written notes.

Headers show scheme/year/stage and `Page N / total` from the first page, without
counter resets, cover or contents. All three pages of every profile fixture are
checked. Heading bookmarks are disabled because the full form asks for a PDF
without bookmarks. Arial must be installed; the regression rejects substitution
warnings. Changes to paper size, columns, page counters, or content placed
outside normal flow are outside the verified layout.

## Word counts and key outputs

```typst
#import "@local/satz:0.2.0": nwo-text, nwo-key-output
#nwo-text("research-idea", "Your complete plain-text response...")

#nwo-key-output(
  reference: [A. Example (2024). Research output title.],
  output-type: [Research article],
  contribution: [Explain your contribution and why this output is relevant.],
  indicators: ([Evidence for one quality indicator.],),
  urls: ("https://doi.org/10.1234/example",),
)
```

`nwo-text` checks whitespace-separated words for **plain strings** and prints the
count. It rejects rich content, because counting source text would miss rendered
citations, tables and figure labels. For rich sections, use ordinary markup and
verify the official count including all counted material. Hyphenation, formulas
and punctuation can produce differences from Word's count; this helper is not
an authoritative replacement for it.

Supported pre-proposal fields include `academic-profile`, `key-output`,
`research-culture`, `research-idea` and `special-circumstances`. Veni academic
profile and key-output narrative require 400–700 words; Vidi/Vici profiles allow
up to 1200 words and key-output narrative up to 700. Veni's Science research idea
allows 500 words, versus 100 for the other domains; Vidi/Vici allow 150.
Full Vici supports `scientific-summary` (300), `public-summary-nl` and
`public-summary-en` (50–100 each); ZonMw puts those summaries in its portal.

Key-output cards separate the reference, type, contribution, indicators and URLs.
The wrapper rejects more than ten cards, more than three indicators per card and
more than two URLs. It does **not** infer the excluded fields or validate the
aggregate narrative word count across cards; apply the form's counting rules.

## Full Vici section page allowances

`nwo-page-budget("research", max-pages: 14)[...]` checks the vertical span of a
section. The full starter wraps section 2a with 14 pages, the combined 2a3/2a4
with one page, and impact with 2.5 pages. Fractional allowances use the configured
text height and marker positions. Keys must be unique.

Keep the section's headings, figures and tables inside its scope. The check
measures normal flow between markers; it cannot account reliably for floats or
placed content that escape those markers. It is not an exact Word page-count
emulator. The official form also contains a budget workbook, duration, funding,
stakeholder and ethics requirements that this helper does not validate.

## References and highlighting

DFG allows selected own publications to be highlighted; **the full Vici form
prohibits this** in its literature section. The optional `proposal-citations` /
`proposal-publications` workflow therefore rejects printed highlighted entries
inside a full NWO proposal. Use its default empty selection. Native bibliography
remains available; choose a style using initials and use 9pt or larger for full
Vici references. Active hyperlinks belong only in the places allowed by the
specific form. See the [proposal citation guide](proposals.md).

`proposal-budget` can illustrate the narrative, but does not replace the official
NWO budget workbook or validate eligible costs.

## Sources and checks

Consulted 20 October 2026:

- [NWO Veni Science 2026](https://www.nwo.nl/calls/nwo-talentprogramma-veni-enw-2026),
  [Vidi Science 2026](https://www.nwo.nl/calls/nwo-talentprogramma-vidi-exacte-en-natuurwetenschappen-enw-2026),
  [Vici Science 2026](https://www.nwo.nl/calls/nwo-talentprogramma-vici-enw-2026),
  plus their SSH/AES call pages, which link the same corresponding forms.
- [ZonMw Veni 2026](https://www.zonmw.nl/nl/subsidie/nwo-talentprogramma-veni-2026),
  [Vidi 2026](https://www.zonmw.nl/en/subsidy/nwo-talent-programme-vidi-2026-0),
  [Vici 2026](https://www.zonmw.nl/nl/subsidie/nwo-talentprogramma-vici-2026).
- The seven downloaded Word sources and SHA-256 hashes are recorded in
  [sources.json](../nwo-proposal/sources.json), with direct official URLs. Source
  documents and generated PDFs are not committed.
- [The supplied LaTeX repository](https://github.com/MMMPeeters1981/NWO_LaTeX_Template)
  was reviewed as a historical reference. Its GPL class code and logo are not
  incorporated into Satz. The new code is an independent native implementation.

Run `python3 examples/latex-parity/check_nwo.py` with Typst, Arial, pdfplumber and
pypdf available. The suite covers every represented combination, current/total
headers on every page, four heading levels, font size, measured baseline and
heading gaps, margin position, absent bookmarks, domain-specific starters,
word/key-output/page-limit failures, user leading overrides and unavailable
profiles. The DFG, publication-highlighting and proposal-rhythm suites are run
alongside it. None of these tests proves universal submission compliance.
