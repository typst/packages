#import "@preview/metropole-report:0.1.0": *

#show: metropole.with(
  title: "The Swiss Grid",
  subtitle: "Order, Restraint, and the Beauty of Constraint",
  author: "Metropole Design System",
  date: datetime(year: 2026, month: 05, day: 1),
  language: "en",
  cover-page: false,
)

= A Philosophy of Precision

There is a particular kind of beauty that emerges not from decoration but from discipline. In the mid-twentieth century, a group of Swiss designers -- working in Zürich and Basel, armed with metal type and a fierce belief in objectivity -- developed a visual language that would go on to shape everything from airport signage to corporate identity to the interfaces we carry in our pockets.

They called it, somewhat drily, the International Typographic Style. Everyone else called it Swiss Design.

The core proposition was simple: a grid is not a cage. It is a foundation. When every element on a page -- every column of text, every caption, every rule -- answers to the same underlying structure, the result is not rigidity but coherence. The eye moves easily. The reader trusts the page.

== What the Grid Does

A grid resolves decisions before they need to be made. The designer who has established a baseline unit -- a line height, a column width, a margin -- no longer asks "how much space should go here?" They ask instead "how many units?" The answer is almost always obvious.

This is not laziness. It is economy. The freed attention goes toward the things that cannot be systematised: the choice of image, the rhythm of a sentence, the weight of an argument.

=== The Baseline

The most important unit is the one that governs everything else: the line height. Set it generously -- 1.6 to 1.75 times the type size -- and every other measurement follows. Margins become multiples of it. The space above a heading becomes two of it. The gap between a rule and the text below it becomes half of one. Nothing is arbitrary.

= Writing and Structure

Good document design does not call attention to itself. The reader should finish a well-set page with no memory of having navigated it -- only of having understood it. The following sections demonstrate the structural elements available in this template.

== Lists

Lists are best used sparingly. A paragraph that has been fragmented into bullets often loses more than it gains -- the connective tissue of prose, the because and therefore and however, carries meaning that a dash cannot. That said, some content is genuinely enumerable.

The qualities of a well-designed list:

- It contains items that are genuinely parallel, comparable in kind and length
- It has no more items than the reader can hold in working memory
  - Sub-items should be rarer still
  - When they appear, they should earn their indentation
- It ends before it outstays its welcome

Numbered lists suit sequences where order matters -- instructions, ranked criteria, steps in an argument:

+ Establish the baseline grid before making any other decisions
+ Derive margins, spacing, and rule weights from that unit
+ Apply consistently, then adjust only where the eye demands it

== Definitions

Term lists suit glossaries, taxonomies, and any content where a label and its elaboration belong together:

/ Grid: A system of intersecting horizontal and vertical lines that divides a page into fields, establishing a consistent spatial logic for the placement of all elements.
/ Leading: The vertical distance from one baseline to the next, named after the strips of lead that compositors once inserted between lines of metal type.
/ Measure: The width of a column of text. For comfortable reading, the measure should accommodate between 45 and 75 characters per line.
/ Kern: The adjustment of space between specific pairs of characters -- AV, To, We -- to correct for optical irregularities that arise from their shapes.

= Quotation and Evidence

Writers argue with evidence. Evidence takes many forms -- a statistic, a precedent, an observation -- but the extended quotation deserves particular care. It is a guest in the text. It should be introduced, accommodated, and then departed from.

#quote(
  block: true,
  attribution: [Jan Tschichold, _The New Typography_, 1928],
)[
  The purpose of all typography is communication. This communication must be made in the shortest, most efficient manner possible. For this reason, the suitability of the chosen typeface for its purpose is of paramount importance.
]

Tschichold wrote this at twenty-six, in a pamphlet that caused a scandal in the German printing trade. He later repudiated much of it, finding his own early certainties too rigid. The grid, he came to believe, was a tool -- not a doctrine.

= Data and Evidence

Numbers deserve the same care as words. A table that is merely functional -- columns of unequal width, no visual hierarchy between header and body -- makes the reader work to extract meaning that the designer could have surfaced directly.

== Swiss Cities by Population

#table(
  columns: (1fr, 1fr, 1fr, 1fr),
  align: center,
  table.header([City], [Canton], [Population], [Elevation]),
  [Zürich], [Zürich], [434,335], [408 m],
  [Geneva], [Geneva], [203,856], [375 m],
  [Basel], [Basel-Stadt], [178,120], [260 m],
  [Lausanne], [Vaud], [139,111], [495 m],
  [Bern], [Bern], [134,794], [542 m],
  [Winterthur], [Zürich], [116,906], [439 m],
  [Lucerne], [Lucerne], [82,641], [435 m],
)

The header row carries the accent color, establishing immediate hierarchy. Alternating rows use a subtle background tint -- enough to aid scanning, not enough to distract from the content.

= Code and Technical Content

Inline code, such as a reference to the `line-height` variable or the `oklab` color space, sits cleanly within running text without disrupting the reading flow. Block code receives its own space, set in a monospaced face with generous inset:

```python
def scale(base: float, ratio: float = 1.25) -> list[float]:
    """Generate a modular type scale from a base size."""
    return [base * ratio ** n for n in range(-2, 5)]

sizes = scale(11)  # [7.04, 8.8, 11.0, 13.75, 17.19, 21.48, 26.84]
```

= The Accent Colors

The template ships with six preset accent colors. Each is chosen for legibility, cultural neutrality, and compatibility with both black body text and white backgrounds. Switch between them by passing `accent-color: metro-blue` -- or any other -- to the template.

/ #text(
    fill: transit-red,
  )[Transit Red]: Authoritative and direct. The default. Named for the graphic language of urban transit systems.
/ #text(
    fill: metro-blue,
  )[Metro Blue]: Institutional and measured. Appropriate for finance, law, and civic documents.
/ #text(
    fill: deep-teal,
  )[Deep Teal]: Contemporary and composed. Works well in scientific and environmental contexts.
/ #text(
    fill: burnt-orange,
  )[Burnt Orange]: Warm and editorial. Suited to cultural and humanities writing.
/ #text(
    fill: emerald,
  )[Emerald]: Precise and considered. A quieter alternative to the warmer accents.
/ #text(
    fill: deep-violet,
  )[Deep Violet]: Distinctive and unhurried. For documents that can afford to be unusual.

= Further Reading

The ideas behind this template draw on a long tradition of typographic thought. Those interested in pursuing it further might begin with:

- #link("https://typst.app")[Typst] -- the typesetting system in which this template is written
- #link("https://fonts.google.com/specimen/Source+Serif+4")[Source Serif 4] and #link("https://fonts.google.com/specimen/Source+Sans+3")[Source Sans 3] -- the type families used throughout
- Josef Müller-Brockmann's _Grid Systems in Graphic Design_ -- the canonical text on the Swiss grid
- Emil Ruder's _Typography_ -- a rigorous and beautiful account of the Basel approach
- Jan Tschichold's _The Form of the Book_ -- his later, more humane views on typographic order


