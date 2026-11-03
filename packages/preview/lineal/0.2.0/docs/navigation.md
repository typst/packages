# Navigation and contents

Lineal provides a contextual outline for section navigation and a complete table
of contents for agendas, handouts and longer documents. Both render ordinary,
selectable Typst content with links to the original headings.

```typst
#import "@preview/lineal:0.2.0": lineal-outline, lineal-toc

#lineal-toc(title: [Workshop programme], depth: 2)
```

Titles are plain content, not generated headings. They appear once and do not
change the slide header, heading hierarchy, section ownership or progress bars.

## Contextual outline

```typst
#lineal-outline(title: [This section], depth: 3)
```

With a current section, the left column lists visible level-one headings. The
right column includes the entire current section: its heading, topics, siblings
and descendants. It does not narrow the list to descendants of the current topic.
The current heading and its visible ancestors receive emphasis.

Before the first heading, or in a document without level-one sections, the outline
falls back to a complete hierarchy. If no section headings are selected, the
current section's visible content uses the full width.

```typst
lineal-outline(
  title: none, target: heading.where(outlined: true), depth: none,
  filter: entry => true, transform: (_, body) => body,
  columns: (1fr, 2fr), gutter: 2em,
  indent: 1.1em, gap: .45em, size: 1em,
  ink: auto, accent: auto,
  page-numbers: false, page-numbering: "1", fill: none,
)
```

`columns` contains two track widths. `gutter` separates the columns. Section names
align to the right in the left column; the current hierarchy aligns to the left.

## Complete table of contents

```typst
#lineal-toc(
  title: [Contents], depth: 3,
  page-numbers: true, fill: repeat[.],
)
```

`lineal-toc` always includes the complete selected hierarchy, regardless of where
it appears in the document. Deeper entries are indented. Root groups have a small
vertical separation, so unrelated sections remain distinct.

```typst
lineal-toc(
  title: [Contents], target: heading.where(outlined: true), depth: none,
  filter: entry => true, transform: (_, body) => body,
  indent: 1.1em, gap: .45em, size: 1em,
  ink: auto, accent: auto,
  page-numbers: false, page-numbering: "1", fill: none,
)
```

Set `title: none` to omit the title, or `title: auto` for plain `[Contents]`. An empty selection renders no entries; an
explicit title still appears.

## Selection preserves structure

`target`, `depth` and `filter` change which headings are visible. They do not
change the underlying parent relationships or move a topic into another section.

```typst
#lineal-outline(
  target: heading.where(level: 2),
  filter: entry => entry.heading.outlined,
)
```

`depth` limits the **raw heading level**, matching Typst's outline convention:
`depth: 2` includes `=` and `==` headings. It does not count how many visible
ancestors remain after filtering. Skipped heading levels keep their actual raw
level while indentation follows the structural hierarchy.

A heading with `outlined: false` can still own a subtree. Its selected children
stay in that section, and its hidden text is never rendered. In a complete table
of contents, such a group starts at its first visible depth and is separated from
the preceding root group. It does not appear to belong to the preceding visible
section.

`filter(entry)` must return a boolean. `transform(entry, body)` returns the
content used for the label. For example:

```typst
#lineal-toc(
  transform: (entry, body) => {
    if entry.is-current { strong(body) } else { body }
  },
)
```

Useful entry fields include:

| Field | Meaning |
| --- | --- |
| `heading`, `loc` | Original heading content and link destination. |
| `level` | Raw Typst heading level, preserved for existing filters. |
| `depth`, `path` | Structural depth and ancestry path, independent of visibility. |
| `root-id`, `parent-id` | Structural ownership, including hidden ancestors. |
| `is-current` | This is the heading immediately before the navigation. |
| `is-active` | This is the nearest selected ancestor of the current heading, including itself. |
| `relation` | `same`, `parent`, `child`, `sibling` and `unrelated` booleans, or `none` before the first heading. |
| `here-path`, `here-level` | Current structural path and raw level, or `none` before the first heading. |

`is-active` is computed after filtering for transforms and model output. Filters
can use `is-current` and `relation`.

Keep transforms to display content rather than returning new `heading` elements.

## Page numbers and styling

Page numbers use `counter(page)` **at the target heading**, including deliberate
counter resets. They do not use the PDF's physical page index. Choose the display
format explicitly with `page-numbering`, which accepts a Typst numbering string
or function:

```typst
#set page(numbering: "i")
#lineal-toc(page-numbers: true, page-numbering: "i", fill: repeat[.])
```

The default format is `"1"`. Navigation does not infer different numbering formats
for separate parts of a document. `fill` supplies optional leader content between
a label and its page number; it has no effect when `page-numbers` is false.

The surrounding font and colour are inherited. `size` controls the base text
size; `ink` sets ordinary labels and `accent` sets the active heading and its
ancestors. Both colours default to `auto`. `indent` and `gap` control hierarchy
and row spacing. All links preserve the heading's original location.

## Flow and slide limits

Navigation has natural height. In ordinary documents, long lists continue across
pages without dropping entries. Long labels wrap within the available width.

Automatic section slides have a fixed available height. If their outline does
not fit, compilation reports:

> section outline exceeds the available height; reduce its depth or use separate contents pages

Reduce the displayed depth, select fewer entries, or put a complete table of
contents on dedicated pages. Lineal does not silently crop the outline or shrink
its text. The slide footer remains responsible for deck progress; the contextual
outline does not add a second progress bar with a different meaning.

For automatic section slides, set the limit on the theme:

```typst
#show: lineal-theme.with(section-depth: 1)
```

The default is `section-depth: 2`, showing section headings and their slide titles.
