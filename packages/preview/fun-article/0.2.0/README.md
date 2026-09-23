# Fun Article

Fun Article is a compact two-column article template for Typst. It provides a bold justified drop-cap abstract, structured authors and affiliations, ORCID badges, running headers, page totals, and an optional significance note.

## Usage

Create a new project from the template:

```sh
typst init @preview/fun-article:0.2.0
```

Or import it in an existing document:

```typ
#import "@preview/fun-article:0.2.0": appendix, fun-article

#show: fun-article.with(
  title: "A Short Article",
  authors: (
    (name: "Ada Lovelace", affils: "1", is-corresponding: true),
  ),
  affiliations: (
    (id: "*", name: "Corresponding author: ada@example.com"),
    (id: "1", name: "Example University"),
  ),
  abstract: "A concise abstract goes here.",
  significance: [
    State why the article matters in one or two sentences.
  ],
)

= Introduction

Write the article here.
```

## Parameters

- `title`: Article title.
- `authors`: Array of dictionaries with `name`, optional `affils`, optional `orcid`, and optional `is-corresponding`.
- `affiliations`: Array of dictionaries with `id` and `name`.
- `abstract`: Abstract text or content. The abstract renders in bold with the drop cap kept inside the paragraph.
- `significance`: Optional content for the significance box.
- `paper-size`: Page size, defaulting to `"a4"`.
- `cols`: Number of body columns, defaulting to `2`.

## License

MIT
