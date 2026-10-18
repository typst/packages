# misq

A Typst template for MIS Quarterly manuscript submissions.

This template reproduces MISQ's formatting requirements in Typst, including Times New Roman body text, double-spaced paragraphs, three-level numbered headings, a title page with abstract and keywords, and APA 7th edition citations via a bundled CSL file. Authors can write and submit manuscripts without LaTeX.

## Usage

Import the template from Typst Universe:

```typst
#import "@preview/magnificent-misq:0.1.0": misq
```

Set up the document with your manuscript metadata:

```typst
#show: misq.with(
  title: [Your Manuscript Title],
  abstract: [
    Your abstract text here.
  ],
  keywords: ("keyword one", "keyword two", "keyword three"),
  paragraph-style: "indent",
)
```

See `template/main.typ` for a complete example document.

## Parameters

The `misq()` function accepts the following parameters:

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | content | Manuscript title |
| `abstract` | content | Abstract text |
| `keywords` | array of strings | Keyword list |
| `paragraph-style` | string | `"indent"` for first-line indented paragraphs (default) or `"block"` for block paragraphs with spacing between them |

## Features

- Three heading levels with automatic numbering (1, 1.1, 1.1.1)
- APA 7th edition citations via bundled CSL file
- Title page with abstract and keywords
- Double-spaced body text
- Correct margins per MISQ submission guidelines
- Single-spaced bibliography, figures, and tables

## Bibliography

Add your references with a standard Typst bibliography call placed after the body:

```typst
#bibliography("references.bib", title: "References")
```

The template automatically applies APA 7th edition formatting. Do not pass a `style:` argument — the template handles it.

## License

MIT — see [LICENSE](LICENSE)
