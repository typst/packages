# Proposal planning tools

The [complete example](../examples/proposal-planning.typ) combines numbered work
packages, a Gantt chart with resource columns, milestones and an exact budget.
Import `proposal-gantt` and `work-package` from Satz's development entrypoint.
They work with general, DFG and NWO proposal layouts.

## Gantt chart

```typst
#figure(
  proposal-gantt((
    (label: [WP 1: Calibration], kind: "group", spans: ((1, 9),)),
    (label: [Protocol], spans: ((1, 3),)),
    (label: [Measurements], spans: ((3, 6), (8, 9))),
    (label: [M1: Calibration passed], kind: "milestone", at: 9),
    (label: [WP 2: Validation], kind: "group", spans: ((10, 24),)),
  ), periods: 24),
  caption: [Work programme; diamonds indicate milestones.],
) <fig:schedule>
```

Intervals are **inclusive, one-based** period numbers. Split phases belong in
one row's `spans` array; overlapping intervals in the same row are rejected.
Different tasks may overlap. Groups have thinner, darker bars. Milestones use
native vector diamonds centered in the specified period. Labels can contain
ordinary references, including references to work packages.

`unit: "month"` groups twelve cells per year; `unit: "quarter"` groups four,
with Q1–Q4 headings. Without `start-year`, headings say Year 1, Year 2, etc.
Set `start-year: 2027` for calendar years; the first cell is January/Q1 of that
year. Partial final years are supported. `language: "german"` localizes labels.

Optional `resources: ([PM A], [PM B])` adds fixed-width resource columns. Set a
row's `resources: ([3], [6])` in the same order, or omit them for blank cells.
These are displayed values, not inferred effort or budget totals.

The chart uses the available text width and defaults to 11pt labels,
`label-width: 40mm`, `resource-width: 10mm` and a Slate color. Set `size`,
`color` and widths explicitly when needed. If period labels cannot fit, the
helper rejects the layout instead of silently overlapping them: use quarters,
a wider page, fewer resource columns or a permitted smaller type size. Follow
the funder's minimum type size. The general example explicitly uses 9pt to fit
24 monthly periods and two resource columns; the DFG check uses 11pt.

The chart stays on one page. For a long schedule, split it into multiple charts
at meaningful work-package boundaries. Dependency arrows, arbitrary date axes,
auto-scheduling and automatic effort allocation are not implemented.

## Work packages

```typst
#work-package(
  title: [Reference protocol], lead: [Example University], period: [Months 1–9],
  objective: [Establish reproducible calibration.],
  tasks: ([Agree criteria.], [Run calibration.]),
  deliverables: ([D1: Versioned protocol.],),
  milestones: ([M1: Independent check passed.],),
  risk: [Repeat the calibration with instrument-specific corrections.],
) <wp:calibration>

See @wp:calibration.
```

Work packages use their own native figure counter, independent of section and
ordinary figure numbers. Captions and references automatically say WP 1, WP 2,
… (German: AP). They do not add prescribed DFG/NWO section numbers or entries
to the List of Figures. Long summaries can continue across pages in the shared
Satz class. Outside that class, add
`#show figure.where(kind: "work-package"): set block(breakable: true)` yourself.
`body:` accepts additional prose; optional fields are omitted when empty.

## Reference inventory and verification

The reviewed LaTeX repositories provide complementary features:

| Reference feature | Satz equivalent |
| --- | --- |
| emtpb KOMA form layout, section skips, headers and counter reset | DFG 53.01 wrapper and independently compiled layout comparison |
| `funds`, `position`, `positionmul` | `proposal-budget`, integer cents and exact totals |
| Important-publication categories | BibTeX-key selection through `proposal-citations` |
| klb2 monthly groups/tasks and hoelzer quarterly/resource charts | `proposal-gantt`: monthly/quarterly periods, groups, split phases and resources |
| Work-package numbering and aim/method/outcome summaries | `work-package`: automatic WP references, objective, tasks and deliverables |
| Full LaTeX/TikZ/pgfgantt programming | No general translation; use the native helper's documented features |

Sources: [emtpb](https://github.com/emtpb/proposal_dfg),
[klb2's Gantt example](https://github.com/klb2/dfg-proposal-template/blob/beee1e49c8218557b9bbf6668fe72860727ab509/ganttchart.tex),
[hoelzer's quarterly chart](https://github.com/hoelzer/dfg/blob/6420df9ea8fbf84f773cf75ff6a2a81cfc5e508d/gantt/gantt.tex)
and [work-package summary](https://github.com/hoelzer/dfg/blob/6420df9ea8fbf84f773cf75ff6a2a81cfc5e508d/wp/wp1.tex).
The planning helpers are independently written Typst code; no GPL LaTeX
implementation is copied into Satz.

Run `python3 examples/latex-parity/check_proposal_planning.py` with Typst,
`pdfplumber` and `pypdf`. It checks vector bar endpoints/widths, group ranges,
diamond centers, split phases, references and independent counters, calendar
quarters, partial years, German labels, 11pt DFG labels, long-summary page
bounds and invalid-input rejection. The example's rendered pages are also
reviewed visually.
