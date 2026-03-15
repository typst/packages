# The `bei-report` Package

<div align="center">Version 0.1.2</div>

This project is based on the [charged-ieee](https://github.com/typst/templates/tree/main/charged-ieee) Typst template.

This is a _Typst template_ for a two-column paper from the proceedings of the [Institute of Electrical and Electronics Engineers](https://www.ieee.org/).
The paper is tightly spaced, fits a lot of content and comes preconfigured for numeric citations from _BibLaTeX_ or _Hayagriva_ files.
The first page corresponds to the one required by [ENSIMAG](https://ensimag.grenoble-inp.fr/) for internship reports.

## Getting Started

```typ
#import "@preview/bei-report:0.1.2": ensimag

#show: ensimag.with(
  logos: (
    company: rect([MON ENTREPRISE]),
    ensimag: rect([ENSIMAG]),
  ),
  title: [A Typesetting System to Untangle the Scientific Writing Process],
  author: (
    name: "Martin Haug",
    year: [3#super[e] année],
    option: [ISI],
  ),
  period: (
    begin: datetime(year: 1970, month: 01, day: 01),
    end: datetime(year: 1970, month: 03, day: 01),
  ),
  company: (
    name: [mon entreprise],
    address: [
      1 cours Jean Jaurès \
      38000 Grenoble
    ]
  ),
  internship-tutor: [Charles Dupond],
  school-tutor: [Charles Dupont],
)
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-dark.svg"/>
  <img src="./thumbnail-light.svg"/>
</picture>

### Installation

```console
$ typst init "@preview/bei-report" [DIR]
```

## Usage

This template exports the `ensimag` function with the following named arguments:
- `logos` - A dictionary which must have the `company` and `ensimag` logos (_content_).
- `title` - The paper's title as _content_.
- `author` - A dictionary which must have the `name` (_str_ or an _array_), `year` (_content_) and `option` (_content_) keys.
- `period` - A dictionary which must have the `begin` and the `end` date (_datetime_).
- `date-fmt` - The date format string used (see the [format syntax](https://typst.app/docs/reference/foundations/datetime/#format)).
- `company` - A dictionary describing the information about the company with its `name` (_content_) and its `address` (_content_).
- `internship-tutor` - The internship tutor (_content_).
- `school-tutor` - The school tutor (_content_).
- `abstract` - The content of a brief summary of the paper or `none`.
  Appears at the top of the first column in boldface.
- `index-terms` - Array of index terms to display after the abstract.
  Shall be `content`.
- `paper-size` - Defaults to `a4`.
  Specify a [paper size string](https://typst.app/docs/reference/layout/page/#parameters-paper) to change the page format.
- `bibliography` - The result of a call to the `bibliography` function or `none`.
  Specifying this will configure numeric, IEEE-style citations.
- `figure-supplement` - How figures are referred to from within the text.
  Use `"Figure"` instead of `"Fig."` for computer-related publications.

The function also accepts a single, positional argument for the body of the paper.

The template will initialize your package with a sample call to the `ensimag` function in a show rule.
If you want to change an existing project to use this template, you can add a show rule like described [above](#getting-started).

## Licenses

As explained above, the code of this software is licensed under GPL-3 or any later version.
Details of the rights applying to the various third-party files are described in the [copyright](copyright) file in [the Debian `debian/copyright` file format](https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/).
