# para-lipics: An Unofficial LIPIcs Template for Typst

A community-maintained Typst reproduction of the official LaTeX `lipics-v2021.cls` template.

<img src="template/thumbnail.png" alt="para-lipics thumbnail" width="50%">

GitHub issues and pull requests are welcome.

## Basic usage

Import the template in your project with:

```typ
#import "@preview/para-lipics:0.1.2": *

#show: para-lipics.with(...)

// body of the paper

#bibliography("bibliography.bib")
```

The parameters that can be passed to template are:
- `title` (`content`): the paper's title
- `title-running` (optional, `content`): the paper's short title displayed in headers (if not provided, `title` is used)
- `authors` (`array`): an array of authors, each author being a dictionary of the form:
    - `name` (`content`): the author's full name
    - `email` (optional, `string`): the author's email
    - `website` (optional, `string`): the author's website
    - `orcid` (optional, `string`): the author's ORCID
    - `affiliations` (`content`): the author's affiliations (if there are several affiliations, separate them with a new line)
- `author-running` (`content`): the list of abbreviated author names, displayed in headers
- `abstract` (`content`): the paper's abstract
- `keywords` (`content`): comma-separated list of keywords
- `category` (optional, `content`): category of the paper (_e.g._, invited paper)
- `related-version` (optional, `content`): link to full version hosted on open-access repos (arXiv, HAL...)
- `supplement` (optional, `content`): link to supplementary material (_e.g._, related research data, source code...)
- `funding` (optional, `content`): paper's funding statement
- `acknowledgements` (optional, `content`): other acknowledgments
- `copyright` (optional, `content`): author's full names
- `ccs-desc` (`content`): [ACM 2012 classification](https://dl.acm.org/ccs/ccs_flat.cfm) of the form `Category $->$ Sub-category`
- `line-numbers` (`bool`, default: `false`): flag for enabling line numbering
- `anonymous` (`bool`, default: `false`): flag for anonymizing the authors (_e.g._, for double-blind review)
- `hide-lipics` (`bool`, default: `false`): flag for hiding references to LIPIcs series (logo, DOI...), _e.g._, when preparing a arXiv/HAL version

The following parameter is **not yet** implemented:
- `author-columns` (`bool`, default: `false`): flag for enabling a two-column layout for the author/affilation part (only applicable for >6 authors)

In addition, the template also takes the following editor-only parameters (do not touch as author):
- `event-editors` (`content`): full name of editor(s)
- `event-no-eds` (`int`): number of editor(s)
- `event-long-title` (`content`): long title of the event
- `event-short-title` (`content`): short title of the event
- `event-acronym` (`string`): acronym of the event
- `event-year` (`int`): year of the event
- `event-date` (`content`): date of the event (`{month} {start day}--{end day}, {year}` format)
- `event-location` (`content`): location of the event (`{city}, {country}` format)
- `event-logo` (optional, `string`): path the the logo of the event
- `series-volume` (`int`): volume in the series
- `article-no` (`int`): number of the article in the volume

A full example of the usage of `para-lipics` is given in the `sample-article.typ` file.

## Requirements

This template is only guaranteed to work properly for **Typst ≥ 0.13.1**.

Due to current limitations in Typst's font handling, it is currently not possible to ship custom fonts directly within Typst Universe templates.
As a result, some fonts must be installed separately to ensure maximal visual compatibility with the official LIPIcs style.

If the required fonts are unavailable during compilation, the template will use fallback fonts embedded in the CLI.
- If you're using the **web app**, upload the `.ttf` or `.otf` files directly into your project.
- If you're using the **CLI**, either install the fonts on your system or specify them using the `--font-path` option.

**Required fonts:**

- **Computer Modern Sans**[^1] (fallback: New Computer Modern Sans)
- **New Computer Modern Mono** (fallback: DejaVu Sans Mono)

[^1]: Note that this is **not** _New_ Computer Modern, it's the original Knuth-designed version.

## Caveats

This template is **unofficial**, and **Dagstuhl Publishing does not currently accept Typst documents**.

Most conferences using the LIPIcs format accept **PDF submissions**, so _in theory_, you could submit a paper typeset with Typst.
However, we strongly discourage using this template for official submissions: doing so risks a **desk reject** if the publisher's formatting requirements are not strictly followed.

If your paper is accepted, you will still need to **convert your Typst source to LaTeX** to submit it to the publisher.
This may be feasible via tools like [**Pandoc**](https://pandoc.org/) or even LLMs.

Note that PDFs generated with Typst can be submitted to most open-access e-print repositories (arXiv, HAL...).

For now, this template is best suited for authors who:
- enjoy working in Typst
- want a LIPIcs-like preview during drafting
- are comfortable converting to LaTeX later if needed

Once Typst reaches version 1.0.0, this template may also serve as a lobbying tool to encourage Dagstuhl to officially support Typst.

**Note:** This template is a work in progress.
Perfect fidelity with the official LIPIcs format is not guaranteed (yet).