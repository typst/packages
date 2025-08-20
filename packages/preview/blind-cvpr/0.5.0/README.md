# Conference on Computer Vision and Pattern Recognition (CVPR)

## Usage

You can use this template in the Typst web app by clicking _Start from
template_ on the dashboard and searching for `blind-cvpr`.

Alternatively, you can use the CLI to kick this project off using the command

```shell
typst init @preview/blind-cvpr
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `cvpr2022` and `cvpr2025` styling rule with the
following named arguments.

- `title`: The paper's title as content.
- `authors`: An array of author dictionaries. Each of the author dictionaries
  must have a name key and can have the keys department, organization,
  location, and email.
- `keywords`: Publication keywords (used in PDF metadata).
- `date`: Creation date (used in PDF metadata).
- `abstract`: The content of a brief summary of the paper or none. Appears at
  the top under the title.
- `bibliography`: The result of a call to the bibliography function or none.
  The function also accepts a single, positional argument for the body of the
  paper.
- `appendix`: Content to append after bibliography section.
- `accepted`: If this is set to `false` then anonymized ready for submission
  document is produced; `accepted: true` produces camera-redy version. If
  the argument is set to `none` then preprint version is produced (can be
  uploaded to arXiv).
- `id`: Identifier of a submission.

The template will initialize your package with a sample call to the `cvpr2025`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule at the top of your file.

```typst
#import "@preview/blind-cvpr:0.5.0": cvpr2025

#show: cvpr2025.with(
  title: [LaTeX Author Guidelines for CVPR Proceedings],
  authors: (authors, affls),
  keywords: (),
  abstract: [
    The ABSTRACT is to be in fully justified italicized text, at the top of the
    left-hand column, below the author and affiliation information. Use the
    word "Abstract" as the title, in 12-point Times, boldface type, centered
    relative to the column, initially capitalized. The abstract is to be in
    10-point, single-spaced type. Leave two blank lines after the Abstract,
    then begin the main text. Look at previous CVPR abstracts to get a feel for
    style and length.
  ],
  bibliography: bibliography("main.bib"),
  accepted: false,
  id: none,
)
```

## Issues

- In case of US Letter, column sizes + gap does not equals to text width (2 *
  3.25 + 5/16 != 6 + 7/8). It seems that correct gap should be 3/8.

- At the moment of Typst v0.11.0, it is impossible to indent the first paragraph
  in a section (see [typst/typst#311][3]). The workaround is to add indentation
  manually as follows.

  ```typst
  == H2

  #h(12pt)  Manually as space for the first paragraph.
  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do.

  // The second one is just fine.
  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do.
  ```

  Also, we add `indent` constant as a shortcut for `h(12pt)`.

  This issue is relevant to CVPR 2022. In the 2025 template there is no
  indentaino of the first paragraph in section.

- At the moment Typst v0.11.0 does not allow flexible customization of citation
  styles. Specifically, CVPR 2022 citation lookes like `[42]` where number is
  colored hyperlink. In order to achive this, we shouuld provide custom
  CSL-style and then colorize number and put it into square parenthesis in
  typst markup.

- CVPR 2022 requires simple ruler which enumerates lines in regular intervals
  whilst CVPR2025 already requires a ruler which add line numers per line in
  paragraph or heading. Thus we need the next major Typst release v0.12.0 for
  ruler. With the next Typst release, we can do the following.

  ```typst
  set par.line(numbering: "1")
  show figure: set par.line(numbering: none)
  ```

  For implementation details see [typst/typst#4516][6].

- CVPR 2022 and 2025 requires IEEE-like bibliography style but does not follow
  its guidelines closely. Since writing CSL-style files is tedious task, we
  adopt close enough bibliography style from Zotero.

## References

+ CVPR 2022 conference [web site][4].
+ CVPR 2025 conference [web site][5].

[1]: example-paper.latex.pdf
[2]: example-paper.typst.pdf
[3]: https://github.com/typst/typst/issues/311
[4]: https://cvpr2022.thecvf.com/author-guidelines#dates
[5]: https://cvpr.thecvf.com/Conferences/2025
[6]: https://github.com/typst/typst/pull/4516
