# International Conference on Machine Learning (ICML)

## Usage

You can use this template in the Typst web app by clicking _Start from
template_ on the dashboard and searching for `lucky-icml`.

Alternatively, you can use the CLI to kick this project off using the command

```shell
typst init @preview/lucky-icml
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `icml2024` and `icml2025` styling rules with the
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
- `accepted`: If this is set to `false` then anonymized ready for submission
  document is produced; `accepted: true` produces camera-redy version. If
  the argument is set to `none` then preprint version is produced (can be
  uploaded to arXiv).
- `aux`: Provide knobs for template adjusting. Specifically, it allows to
  customize public notice with `public-notice` attribute or to override default
  serif with `font-family`.

The template will initialize your package with a sample call to the `icml2025`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule at the top of your file.

## Issues

This template is developed at [daskol/typst-templates][1] repo. Please report
all issues there.

### Running Title

1. Runing title should be 10pt above the main text. With top margin 1in it
   gives that a solid line should be located at 62pt. Actual, position is 57pt
   in the original template.
2. Default value between header ruler and header text baseline is 4pt in
   `fancyhdr`. But actual value is 3pt due to thickness of a ruler in 1pt.

### Page Numbering

1. Basis line of page number should be located 25pt below of main text. There
   is a discrepancy in about ~1pt.

### Heading

1. Required space after level 3 headers is 0.1in or 7.2pt. Actual space size is
   large (e.g. distance between Section 2.3.1 header and text after it about
   12pt).

### Figures and Tables

1. At the moment Typst has limited support for multi-column documents. It
   allows define multi-column blocks and documents but there is no ability to
   typeset complex layout (e.g. page width figures or tables in two-column
   documents).

### Citations and References

1. There is a small bug in CSL processor which fails to recognize bibliography
   entries with `chapter` field. It is already report and will be fixed in the
   future.
2. There is no suitable bibliography style so we use default APA while ICML
   requires APA-like style but not exact APA. The difference is that ICML
   APA-like style places entry year at the end of reference entry. In order to
   fix the issue, we need to describe ICML bibliography style in CSL-format.
3. In the original template links are colored with dark blue. We can reproduce
   appearance with some additional effort. First of all, `icml2024.csl` shoule
   be updated as follows.

   ```
   diff --git a/icml/icml2024.csl b/icml/icml2024.csl
   index 3b9e9a2..3fe9f74 100644
   --- a/icml/icml2024.csl
   +++ b/icml/icml2024.csl
   @@ -1648,7 +1648,8 @@
          <key macro="date-bib" sort="ascending"/>
          <key variable="status"/>
        </sort>
   -    <layout prefix="(" suffix=")" delimiter="; ">
   +    <!-- NOTE: Prefix and suffix parentheses are removed. -->
   +    <layout delimiter="; ">
          <group delimiter=", ">
            <text macro="author-intext"/>
            <text macro="date-intext"/>
   ```

   Then instead of convenient citation shortcut `@cite-key1 @cite-key2`, one
   should use special procedure `refer` with variadic arguments.

   ```typst
   #refer(<cite-key1>, <cite-key2>)
   ```

[1]: https://github.com/daskol/typst-templates
