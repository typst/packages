# KTHesis

An unofficial, slightly opinionated, extensible [Typst](https://typst.app/home/)
template for writing a Degree Project thesis for KTH Royal Institute of
Technology in Stockholm, Sweden.

Inspired by and partially adapted from Gerald Q. Maguire Jr.'s LaTeX template
and KTH's official degree project report covers as published on the
[institution's website](https://www.kth.se/en/omslag-till-ditt-exjobb-1.479838).

## Overview

This template is primarily targeted at Master's Degree theses, though it aims to
be sufficiently generic so to also be suitable for other kinds of reports. It
strives to simplify drafting and counts with the following features, among
others:

- Supports both English and Swedish as primary language, with built-in
  translations for template-managed headings and sections;
- Supports additional Abstracts in other languages;
- Supports arbitrary extra preamble sections, such as a Glossary / Table of
  Acronyms - i.e., integrates well with
  [glossarium](https://typst.app/universe/package/glossarium) or similar;
- Does not conflict with Typst's native
  [bibliography](https://typst.app/docs/reference/model/bibliography/) mechanism
  even without requiring any additional configuration - "plug and play";
- Uses [hydra](https://typst.app/universe/package/hydra) to show the current
  Chapter title in the page header;
- Uses [headcount](https://typst.app/universe/package/headcount) to make figure,
  table, and listing numbers dependent on Chapter number;
- Includes built-in selective inclusion of indices: an index for figures,
  tables, and listings is automatically added if needed and omitted if not;
- Can generate a "For DiVA" JSON-based trailing section for compatibility with
  existing, school-prevalent automation scripts; and
- Provides a simple interface and tuning options.

## Getting Started

Visit the template's [homepage](https://typst.app/universe/package/kthesis/) and
click "Create project in app" to try it out in the Typst web app.

Alternatively, you can also run `typst init @preview/kthesis` to bootstrap a new
project via the Typst CLI.

## Usage

The main entrypoint is the function `kth-thesis`, which should be invoked with
a `show` rule at the beginning of the document:

```typ
#show: kth-thesis.with(primary-lang: "en")
```

Additional configuration options are passed as needed. After this rule has been
declared, you can write your thesis's content as normal. Level 1 headings (`=`)
mark Chapters, Level 2 headings (`==`) delimitate Sections, Level 3 headings
(`===`) indicate Subsections, and so on.

The second and last point of contact with the template is the function
`setup-appendices`, which you may (if needed) opt to invoke in a `show` rule to
mark the subsequent sections as appendices and switch the numbering to letters:

```typ
#show: setup-appendices
```

## Configuration

There are a number of options that can be passed to the `kth-thesis` function to
customize how the final document looks. All of them are optional since they come
with default values, but in most cases you'll gradually end up having to set
all of them to get the behavior you want. Here's a description of what is
available:

- `primary-lang`: Primary document language; either `en` or `sv`
- `localized-info`: Language-specific information, including title, subtitle,
  abstract, and keywords
- `authors`: Information about who is conducting the degree project
- `supervisors`: Information about who is supervising the degree project
- `examiner`: Information about who is evaluating the degree project
- `course`: Degree project course of which this thesis is part
- `degree`: Degree within the scope of which this project is being conducted
- `national-subject-categories`: One or more mandatory classification codes,
  from [SCB's list](https://www.scb.se/contentassets/10054f2ef27c437884e8cde0d38b9cc4/standard-for-svensk-indelning--av-forskningsamnen-2011-uppdaterad-aug-2016.pdf)
- `school`: KTH institution hosting the project
- `trita-number`: TRITA number assigned by the school upon project completion
- `host-company`: Company hosting the degree project, if any
- `host-org`: Organization hosting the degree project, if any
- `opponents`: Names of assigned opponents, if known
- `presentation`: Final presentation details, if known
- `acknowledgements`: Body of acknowledgements section
- `extra-preambles`: Additional, arbitrary front-matter sections, if needed
- `doc-date`: Document authoring/submission date
- `doc-city`: Document city, for acknowledgments signature
- `doc-extra-keywords`: Additional keywords for document metadata (but not text)
- `with-for-diva`: Whether to include meta "For DiVA" section after back cover

Exact syntax and semantics for each option are shown in the starter `thesis.typ`
main file provided by this template.

**Note:** if `with-for-diva` is enabled, abstracts must use only very simple
Typst constructs since content must be converted to HTML (which is a very lossy
and naive process).

## Future Work

Feature requests (via issues) and patch submissions (via PRs) are very welcome.

Among others, in the future it might be nice to support:

- G5 size paper (traditional for theses in Sweden), instead of just A4;
- Alternative, shorter author names for acknowledgements signature;
- Multiple degrees, including the "Same"/"Both" mechanism for similar or
  distinct subject areas, respectively; and
- Copyleft option, instead of just copyright;

## Conformance

This template is unofficial and has not been verified to fully conform to KTH's
requirements, therefore you should use it at your own risk. However, available
information appears to imply that the covers are the only standardized part of
the degree project report, with students having freedom to decide on all other
formatting, styling, and layout aspects (if accepted by the Examiner).

Covers (June 2024 version) have been replicated as best as possible in Typst
from the provided DOTX templates, but future bids at refining fidelity may be
attempted in the future, especially if and when LaTeX versions are published.

The covers use Arial, which is a proprietary font and so has here been replaced
by an open, metric-compatible substitute: Liberation Sans.

## Licensing

This project and all materials in this repository are made available under the
MIT License, except for the contents of the `/template` directory (i.e., the
files given for the thesis authors to edit), which are instead licensed under
MIT No Attribution.

SPDX-License-Identifier: MIT AND MIT-0
