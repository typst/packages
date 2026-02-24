# Reinforcement Learning Conference/Conference (RLC/RLJ)

## Usage

You can use this template in the Typst web app by clicking _Start from
template_ on the dashboard and searching for `pioneering-rlj`. Alternatively,
you can use the CLI to kick this project off using the command

```shell
typst init @preview/pioneering-rlj
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `rlj` main styling rule with the following named
arguments.

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
- `summary`: Extended abstract for the cover page.
- `contributions`: List of contributions for the cover page.
- `supplementary`: Auxiliary content which was not necessarily subject to peer
  review.

The template will initialize your package with a sample call to the `rlj`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule at the top of your file.

```typst
#import "@preview/pioneering-rlj:0.6.0": rlj

#show: rlj.with(
  title: [Formatting Instructions for RLJ/RLC Submissions],
  authors: (authors, affls),
  keywords: (),
  abstract: [...],
  bibliography: bibliography("main.bib"),
  accepted: false,
)
```

## Issues

1. Vertical space between "Abstract" and abstract is `10pt - 1.5ex` but some
   stretching and shrinking are possible.
2. Figures, specifically @fig:example, allows a lot of stretching and shrinking
   of space above and below figure. Typst can not do such transformations at
   the moment. Thus we manually shrink spaces around the first example figure
   in order to preset pixel perfect template.
3. Reference RLC/RLJ template mark comment with `\dagger` but this templates
   stick to built-in numberings which starts with asterisk.
4. Line numbering starts from abstract in the reference paper. In this template
   we enumerate all lines from the beginning of the paper including cover page.

## References

+ RLC/RLJ 2024 conference [web site][2025].
+ RLC/RLJ 2025 conference [web site][2025].

[2024]: https://rl-conference.cc/2024/index.html
[2025]: https://rl-conference.cc/index.html
