# pubmatter

_Beautiful scientific documents with structured metadata for publishers_

[![Documentation](https://img.shields.io/badge/typst-docs-orange.svg)](https://github.com/curvenote/pubmatter/blob/main/docs.pdf)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/curvenote/pubmatter/blob/main/LICENSE)

Pubmatter is a typst library for parsing, normalizing and showing scientific publication frontmatter.

Utilities for loading, normalizing and working with authors, affiliations, abstracts, keywords and other frontmatter information common in scientific publications. Our goal is to introduce standardized ways of working with this content to expose metadata to scientific publishers who are interested in using typst in a standardized way. The specification for this `pubmatter` is based on [MyST Markdown](https://mystmd.org) and [Quarto](https://quarto.org), and can load their YAML files directly.

## Examples

Pubmatter was used to create these documents, for loading the authors in a standardized way and creting the common elements (authors, affiliations, ORCIDs, DOIs, Open Access Links, copyright statements, etc.)

![](https://github.com/curvenote/pubmatter/blob/main/images/lapreprint.png?raw=true)

![](https://github.com/curvenote/pubmatter/blob/main/images/scipy.png?raw=true)

![](https://github.com/curvenote/pubmatter/blob/main/images/agrogeo.png?raw=true)

## Documentation

The full documentation can be found in [docs.pdf](https://github.com/curvenote/pubmatter/blob/main/docs.pdf). To use `pubmatter` import it:

```typst
#import "@preview/pubmatter:0.1.0"
```

The docs also use `pubmatter`, in a simplified way, you can see the [docs.typ](https://github.com/curvenote/pubmatter/blob/main/docs.typ) to see a simple example of using various components to create a new document. Here is a preview of the docs:

[![](https://github.com/curvenote/pubmatter/blob/main/images/pubmatter.png?raw=true)](https://github.com/curvenote/pubmatter/blob/main/docs.pdf)

### Loading Frontmatter

The frontmatter can contain all information for an article, including title, authors, affiliations, abstracts and keywords. These are then normalized into a standardized format that can be used with a number of `show` functions like `show-authors`. For example, we might have a YAML file that looks like this:

```yaml
author: Rowan Cockett
date: 2024/01/26
```

You can load that file with `yaml`, and pass it to the `load` function:

```typst
#let fm = pubmatter.load(yaml("pubmatter.yml"))
```

This will give you a normalized data-structure that can be used with the `show` functions for showing various parts of a document.

You can also use a `dictionary` directly:

```typst
#let fm = pubmatter.load((
  author: (
    (
      name: "Rowan Cockett",
      email: "rowan@curvenote.com",
      orcid: "0000-0002-7859-8394",
      affiliations: "Curvenote Inc.",
    ),
  ),
  date: datetime(year: 2024, month: 01, day: 26),
  doi: "10.1190/tle35080703.1",
))
#pubmatter.show-author-block(fm)
```

![](https://github.com/curvenote/pubmatter/blob/main/images/author-block.png?raw=true)

### Theming

The theme including color and font choice can be set using the `THEME` state.
For example, this document has the following theme set:

```typst
#let theme = (color: red.darken(20%), font: "Noto Sans")
#set page(header: pubmatter.show-page-header(theme: theme, fm), footer: pubmatter.show-page-footer(fm))
#state("THEME").update(theme)
```

Note that for the `header` the theme must be passed in directly. This will hopefully become easier in the future, however, there is a current bug that removes the page header/footer if you set this above the `set page`. See [https://github.com/typst/typst/issues/2987](#2987).

The `font` option only corresponds to the frontmatter content (abstracts, title, header/footer etc.) allowing the body of your document to have a different font choice.

### Normalized Frontmatter Object

The frontmatter object has the following normalized structure:

```yaml
title: content
subtitle: content
short-title: string # alias: running-title, running-head
# Authors Array
# simple string provided for author is turned into ((name: string),)
authors: # alias: author
  - name: string
    url: string # alias: website, homepage
    email: string
    phone: string
    fax: string
    orcid: string # alias: ORCID
    note: string
    corresponding: boolean # default: `true` when email set
    equal-contributor: boolean # alias: equalContributor, equal_contributor
    deceased: boolean
    roles: string[] # must be a contributor role
    affiliations: # alias: affiliation
      - id: string
        index: number
# Affiliations Array
affiliations: # alias: affiliation
  - string # simple string is turned into (name: string)
  - id: string
    index: number
    name: string
    institution: string # use either name or institution
# Other publication metadata
open-access: boolean
license: # Can be set with a SPDX ID for creative commons
  id: string
  url: string
  name: string
doi: string # must be only the ID, not the full URL
date: datetime # validates from 'YYYY-MM-DD' if a string
citation: content
# Abstracts Array
# content is turned into ((title: "Abstract", content: string),)
abstracts: # alias: abstract
  - title: content
    content: content
```

Note that you will usually write the affiliations directly in line, in the following example, we can see that the output is a normalized affiliation object that is linked by the `id` of the affiliation (just the name if it is a string!).

```typst
#let fm = pubmatter.load((
  authors: (
    (
      name: "Rowan Cockett",
      affiliations: "Curvenote Inc.",
    ),
    (
      name: "Steve Purves",
      affiliations: ("Executable Books", "Curvenote Inc."),
    ),
  ),
))
#raw(lang:"yaml", yaml.encode(fm))
```

![](https://github.com/curvenote/pubmatter/blob/main/images/normalized.png?raw=true)

### Full List of Functions

- `load()` - Load a raw frontmatter object
- `doi-link()` - Create a DOI link
- `email-link()` - Create a mailto link with an email icon
- `github-link()` - Create a link to a GitHub profile with the GitHub icon
- `open-access-link()` - Create a link to Wikipedia with an OpenAccess icon
- `orcid-link()` - Create a ORCID link with an ORCID logo
- `show-abstract-block()` - Show abstract-block including all abstracts and keywords
- `show-abstracts()` - Show all abstracts (e.g. abstract, plain language summary)
- `show-affiliations()` - Show affiliations
- `show-author-block()` - Show author block, including author, icon links (e.g. ORCID, email, etc.) and affiliations
- `show-authors()` - Show authors
- `show-citation()` - Create a short citation in APA format, e.g. Cockett _et al._, 2023
- `show-copyright()` - Show copyright statement based on license
- `show-keywords()` - Show keywords as a list
- `show-license-badge()` - Show the license badges
- `show-page-footer()` - Show the venue, date and page numbers
- `show-page-header()` - Show an open-access badge and the DOI and then the running-title and citation
- `show-spaced-content()`
- `show-title()` - Show title and subtitle
- `show-title-block()` - Show title, authors and affiliations

## Contributing

To help with standardization of metadata or improve the show-functions please contribute to this package: \
https://github.com/curvenote/pubmatter
