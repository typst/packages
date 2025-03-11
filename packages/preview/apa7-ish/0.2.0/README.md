# APA7 (-ish) Template for Typst

[Typst](https://typst.app/) Template that (mostly) complies with APA7 Style (Work in Progress).

The template does not follow all recommendations by the APA Manual, especially when the suggestions break with typographic conventions (such as double line spacing :vomiting_face:). Instead, the goal of this template is that it generates you a high-quality manuscript that has all the important components of the APA7 format, but is aesthetically pleasing.

# Work in Progress

The following works already quite well:

- consistent and simple typesetting
- correct display of author information / author note
- citations anfalsed references
- Page headers and footers (show short title in header)
- Option to anonymize the paper
- Tables: consisting of 3 parts (caption, content, and table notes)

This is still not finished:

- figures
- complete pandoc integration (template for pandoc to replace Latex-based workflows)
- automatic calculation of page margins (like memoir-class for Latex)

# Basic Usage

The easiest way to get started is to edit the example file, which has sensible default values. Most fields in the configuration are optional and will safely be ignored (not rendered) when you set them to `none`.

## Authors

The `authors` setting expects an array of dictionaries with the following fields:

```typst
(
  name: "First Name Last Name", // Name of author as it should appear on the paper title page
  affiliation: "University, Department", // affiliation(s) of author as it should appear on the title page
  orcid: "0000-0000-0000-0000", // optional for author note
  corresponding: true, // optional to mark an author as corresponding author
  email: "email@upenn.edu", // optional email address, required if author is corresponding
  postal: "Longer string", // optional postal address for corresponding author
)
```

Note that the `affiliation` field also accepts an array, in case an author has several affiliations:


```typst
(
  name: "First Name Last Name",
  affiliation: ("University A", "University B")
  ...
)
```

## Anonymization

Sometimes you need to submit a paper without any author information. In such cases you can set `anonymous` to `true`.

## Tables

The template has basic support for tables with a handful of utilities. Analogous to the [Latex booktabs package](https://ctan.org/pkg/booktabs), there are pre-defined horizontal lines ("rules"):

- `#toprule`: used at the top of the table, before the first row
- `#midrule`: used to separate the header row, or to separate a totals row at the bottom
- `#bottomrule`: used after the last row (technically the same as toprule, but may be useful later to define custom behaviour)

Addtionally, there is a `#tablenote` function to be used to place a table note below the table.

A minimal usage example (taken from the typst documentation):

```typst
// wrap everything in a #figure
#figure(
  [
    #table(
      columns: 2,
      align: left,
      toprule, // separate table from other content
      table.header([Amount], [Ingredient]),
      midrule, // separation between table header and body
      [360g], [Baking flour],
      [250g], [Butter (room temp.)],
      [150g], [Brown sugar],
      [100g], [Cane sugar],
      [100g], [70% cocoa chocolate],
      [100g], [35-40% cocoa chocolate],
      [2], [Eggs],
      [Pinch], [Salt],
      [Drizzle], [Vanilla extract],
      bottomrule // separation after the last row
    )
    // tablenote goes after the #table
    #tablenote([Here are some additional notes.])
  ],
  // caption is part of the #figure
  caption: [Here is the table caption]
)
```