# Transactions on Machine Learning Research (TMLR)

## Usage

You can use this template in the Typst web app by clicking _Start from
template_ on the dashboard and searching for `smooth-tmlr`.

Alternatively, you can use the CLI to kick this project off using the command

```shell
typst init @preview/smooth-tmlr
```

Typst will create a new directory with all the files needed to get you started.

## Example Papers

Here are an example paper in [LaTeX][1] and in [Typst][2].

## Configuration

This template exports the `tmlr` function with the following named arguments.

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
- `review`: Hypertext link to review on OpenReview.
- `pubdate`: Date of publication (used only month and date).

The template will initialize your package with a sample call to the `tmlr`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule at the top of your file.

## Issues

This template is developed at [daskol/typst-templates][1] repo. Please report
all issues there.

- While author instruction says the all text should be in sans serif font
  Computer Modern Bright, only headers and titles are in sans font Computer
  Modern Sans and the rest of text is causal Computer Modern Serif (or Roman).
  To be precice, the original template uses Latin Modern, a descendant of
  Computer Modern. In this tempalte we stick to CMU (Computer Modern Unicode)
  font family.

- In the original template paper, the word **Abstract** is of large font size
  (12pt) and bold. This affects slightly line spacing. We don't know how to
  adjust Typst to reproduce this feature of the reference template but this
  issue does not impact a lot on visual appearence and layouting.

- In the original template special level-3 sections like "Author Contributions"
  or "Acknowledgements" are not added to outline. We add them to outline as
  level-1 header but still render them as level-3 headers.

- ICML-like bibliography style. In this case, the bibliography slightly differs
  from the one in the original example paper. The main difference is that we
  prefer to use author's lastname at first place to search an entry faster.

- In the original template a lot of vertical space is inserted before and after
  graphics and table figures. It is unclear why so much space are inserted. We
  belive that the reason is how Typst justify content verticaly. Nevertheless,
  we append a page break after "Default Notation" section in order to show that
  spacing does not differ visually.

- Another issue is related to Typst's inablity to produce colored annotation.
  In order to mitigte the issue, we add a script which modifies annotations and
  make them colored.

  ```shell
  ../colorize-annotations.py \
      example-paper.typst.pdf example-paper-colored.typst.pdf
  ```

  See [README.md][2] for details.

[1]: https://github.com/daskol/typst-templates
[2]: https://github.com/daskol/typst-templates/#colored-annotations
