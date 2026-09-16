# Neural Information Processing Systems (NeurIPS)

*A template for main track, auxiliary tracks, and workshops.*

## Configuration

This template exports the `neurips2023`, `neurips2024`, `neurips2025`,
`neurips2026` functions with the following named arguments.

- `title`: The paper's title as content.
- `authors`: A tuple `(authors, affls)` where `authors` is an array of author
  dictionaries (keys: `name`, `affl`, `email`, and optional `equal`) and
  `affls` is a dictionary mapping affiliation keys to dictionaries (keys:
  `department`, `institution`, `location`, `country`). The `affl` key of an
  author entry can be a single string or an array of strings for multiple
  affiliations.
- `keywords`: An array of keyword strings for PDF document metadata.
- `date`: The publication date, or `auto` to use the current date.
- `abstract`: The content of a brief summary of the paper or none. Appears at
  the top under the title.
- `bibliography`: The result of a call to the `bibliography` function or none.
- `bibliography-opts`: A dictionary of named options forwarded to
  `set bibliography(...)`. Defaults to `(title: "References", style:
  "natbib.csl")`.
- `accepted`: If this is set to `false` then anonymized ready for submission
  document is produced; `accepted: true` produces camera-ready version. If
  the argument is set to `none` then preprint version is produced (can be
  uploaded to arXiv).
- `track` (`neurips2026` only): The submission track for camera-ready copies.
  Valid values are `"main"` (default), `"position"`, `"eandd"`,
  `"creative-ai"`, and `"workshop"`. Only used when `accepted` is `true`.
- `workshop-title` (introduced in `neurips2026`): Title of the workshop. Only
  used when `track` is `"workshop"`.

The template will initialize your package with a sample call to the
`neurips2026` function in a show rule. If you want to change an existing
project to use this template, you can add a show rule at the top of your file
as follows.

```typst
#import "@preview/bloated-neurips:0.8.0": appendix, neurips2026

#show: neurips2026.with(
  title: [Formatting Instructions For NeurIPS 2026],
  authors: (authors, affls),
  keywords: ("Machine Learning", "NeurIPS"),
  abstract: [
    The abstract paragraph should be indented ½ inch (3 picas) on both the
    left- and right-hand margins. Use 10 point type, with a vertical spacing
    (leading) of 11 points. The word *Abstract* must be centered, bold, and in
    point size 12. Two line spaces precede the abstract. The abstract must be
    limited to one paragraph.
  ],
  bibliography: bibliography("main.bib"),
  accepted: false,
)

#lorem(42)

#show: appendix

= Technical Details

#lorem(42)
```

The `appendix` show rule switches heading numbering to "A.1" style and resets
the heading counter. It can be used instead of (or in addition to) passing
content via the `appendix:` parameter.

With template of version v0.5.1 or newer, one can override some parts.
Specifically, `get-notice` entry of `aux` dictionary parameter of show rule
allows to adjust the NeurIPS 2026 template to a custom workshop as follows.

```typst
#import "@preview/bloated-neurips:0.8.0": neurips

#let get-notice(accepted) = if accepted == none {
  return [Preprint.]
} else if accepted {
  return [
    Workshop on Scientific Methods for Understanding Deep Learning, NeurIPS
    2026.
  ]
} else {
  return [
    Submitted to Workshop on Scientific Methods for Understanding Deep
    Learning, NeurIPS 2026.
  ]
}

#let science4dl2026(
  title: [], authors: (), keywords: (), date: auto, /* ... */ body,
) = {
  show: neurips.with(
    title: title,
    authors: authors,
    keywords: keywords,
    date: date,
    /* ... */
    aux: (get-notice: get-notice),
  )
  body
}
```

## Issues

- There is an issue in Typst with spacing between figures and between figure
  with floating placement. The issue is that there is no way to specify gap
  between subsequent figures. In order to have behaviour similar to original
  LaTeX template, one should consider direct spacing adjustment with `v(-1em)`
  as follows.

  ```typst
  #figure(
    rect(width: 4.25cm, height: 4.25cm, stroke: 0.4pt),
    caption: [Sample figure caption.#v(-1em)],
    placement: top,
  )
  #figure(
    rect(width: 4.25cm, height: 4.25cm, stroke: 0.4pt),
    caption: [Sample figure caption.],
    placement: top,
  )
  ```

- Another issue is related to Typst's inability to produce colored annotation.
  In order to mitigate the issue, we add a script which modifies annotations and
  make them colored.

  ```shell
  ../colorize-annotations.py \
      example-paper.typst.pdf example-paper-colored.typst.pdf
  ```

  See [README.md][1] for details.

- NeurIPS 2023/2024/2025/2026 instructions discuss bibliography in vague terms.
  Namely, there are no specific requirements. Thus we stick to `natbib`
  bibliography style since we found it in several accepted papers and it is
  similar to that in the example paper.

- It is unclear how to render notice in the bottom of the title page in case of
  final (`accepted: true`) or preprint (`accepted: none`) submission.

[1]: https://github.com/daskol/typst-templates/#colored-annotations
