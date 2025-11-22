# Neural Information Processing Systems (NeurIPS)

## Usage

You can use this template in the Typst web app by clicking _Start from
template_ on the dashboard and searching for `bloated-neurips`.

Alternatively, you can use the CLI to kick this project off using the command

```shell
typst init @preview/bloated-neurips
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `neurips2023` and `neurips2024` function with the
following named arguments.

- `title`: The paper's title as content.
- `authors`: An array of author dictionaries. Each of the author dictionaries
  must have a name key and can have the keys department, organization,
  location, and email.
- `abstract`: The content of a brief summary of the paper or none. Appears at
  the top under the title.
- `bibliography`: The result of a call to the bibliography function or none.
  The function also accepts a single, positional argument for the body of the
  paper.
- `appendix`: A content which is placed after bibliography.
- `accepted`: If this is set to `false` then anonymized ready for submission
  document is produced; `accepted: true` produces camera-redy version. If
  the argument is set to `none` then preprint version is produced (can be
  uploaded to arXiv).

The template will initialize your package with a sample call to the
`neurips2024` function in a show rule. If you want to change an existing
project to use this template, you can add a show rule at the top of your file
as follows.

```typst
#import "@preview/bloated-neurips:0.5.0": neurips2024

#show: neurips2024.with(
  title: [Formatting Instructions For NeurIPS 2024],
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
  appendix: [
    #include "appendix.typ"
    #include "checklist.typ"
  ],
  accepted: false,
)

#lorem(42)
```

With template of version v0.5.0 or newer, one can override some parts.
Specifically, `get-notice` entry of `aux` directory parameter of show rule
allows to adjust the NeurIPS 2024 template to Science4DL workshop as follows.

```typst
#import "@preview/bloated-neurips:0.5.0": neurips

#let get-notice(accepted) = if accepted == none {
  return [Preprint. Under review.]
} else if accepted {
  return [
    Workshop on Scientific Methods for Understanding Deep Learning, NeurIPS
    2024.
  ]
} else {
  return [
    Submitted to Workshop on Scientific Methods for Understanding Deep
    Learning, NeurIPS 2024.
  ]
}

#let science4dl2024(
  title: [], authors: (), keywords: (), date: auto, abstract: none,
  bibliography: none, appendix: none, accepted: false, body,
) = {
  show: neurips.with(
    title: title,
    authors: authors,
    keywords: keywords,
    date: date,
    abstract: abstract,
    accepted: false,
    aux: (get-notice: get-notice),
  )
  body
}
```

## Issues

- The biggest and the most important issues is related to line ruler. We are
  not aware of universal method for numbering lines in the main body of a
  paper. Fortunately, line numbering support has been implemented at
  [typst/typst#4516][4]. Let's wait for the next major release v0.12.0!

- There is an issue in Typst with spacing between figures and between figure
  with floating placement. The issue is that there is no way to specify gap
  between subsequent figures. In order to have behaviour similar to original
  LaTeX template, one should consider direct spacing adjacemnt with `v(-1em)`
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

- Another issue is related to Typst's inablity to produce colored annotation.
  In order to mitigte the issue, we add a script which modifies annotations and
  make them colored.

  ```shell
  ../colorize-annotations.py \
      example-paper.typst.pdf example-paper-colored.typst.pdf
  ```

  See [README.md][3] for details.

- NeurIPS 2023/2024 instructions discuss bibliography in vague terms. Namely,
  there is not specific requirements. Thus we stick to `ieee` bibliography
  style since we found it in several accepted papers and it is similar to that
  in the example paper.

- It is unclear how to render notice in the bottom of the title page in case of
  final (`accepted: true`) or preprint (`accepted: none`) submission.

[3]: https://github.com/daskol/typst-templates/#colored-annotations
[4]: https://github.com/typst/typst/pull/4516
