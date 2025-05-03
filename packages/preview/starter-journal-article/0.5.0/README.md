# A configurable starter template for journal articles

This package provides a template for writing journal articles
to organise authors, institutions, and information of corresponding authors.

## Usage

Run the following command to use this template

```typst
typst init @preview/starter-journal-article
```

## Documentation

### `article` 

The template for creating journal articles.
It needs the following arguments.

Arguments:

- `title`: The title of this article. Default: `"Article Title"`.
- `authors`: A dictionary of authors. 
  Dictionary keys are authors' names.
  Dictionary values are meta data of every author, 
  including label(s) of affiliation(s), email, contact address, 
  or a self-defined name (to avoid name conflicts).
  The label(s) of affiliation(s) must be those claimed in the argument `affiliations`.
  Once the email or address exists, the author(s) will be labelled as the corresponding author(s), and their address will show in footnotes.
  Function `author-meta()` is useful in creating information for each author.
  Default: `("Author Name": author-meta("affiliation-label"))`.
- `affiliations`: A dictionary of affiliation.
  Dictionary keys are affiliations' labels.
  These labels show be constent with those used in authors' meta data.
  Dictionary values are addresses of every affiliation.
  Default: `("affiliation-label": "Affiliation address")`.
- `abstract`: The paper's abstract. Default: `[]`.
- `keywords`: The paper's keywords. Default: `[]`.
- `bib`: The bibliography. Accept value from the built-in `bibliography` function. Default: `none`.
- `template`: Templates for the following parts. Please see below for more informations
  - `title: (title) => {}`: how to show the title of this article.
  - `author-info: (authors, affiliations) => {}`: how to show each author's information.
  - `abstract: (abstract, keywords) => {}`: how to show the abstract and keywords.
  - `bibliography: (bib) => {}`: how to show the bibliography.
  - `body: (body) => {}`: how to show main text.

### `author-meta`

A helper to create meta information for an author.

Arguments:

- `..affiliation`: Capture the positioned arguments as label(s) of affiliation(s). Mandatory.
- `email`: The email address of the author. Default: `none`.
- `alias`: The display name of the author. Default: `none`.
- `address`: The address of the author. Default: `none`.
- `cofirst`: Whether the author is the co-first author. Default: `false`.

### `appendix`

A helper to show contents as appendices.

- Heading numbers are shown in capital letters with a prefix "Appendix".
- Appendix numbers are prepended to figure (and table, etc.) numbers.

Usage:

```typst
#show: appendix
```

### `suffix`

A helper to show contents after the main text but before the appendix.
The only behavior of this function is to hide the heading numbers.

Usage:

```typst
#show: suffix
```

### `booktab`

A helper to create three-line tables.
This function is a wrapper of the built-in `table` function.
It adds a top line and a bottom line to the table,
and a middle line under the first row by default.

Arguments:

- `..args`: Capture the positioned arguments as the table contents. Mandatory.
- `top-bottom`: The stroke of the top and bottom lines. Default: `1pt`.
- `mid`: The stroke of the middle line. Default: `0.5pt`.

Usage:

```typst
#booktab(
  columns: 3,
  rows: 3,
  ..((lorem(2),) *9)
)
```

## Default templates

The following code shows how the default templates are defined.
You can override any of the by setting the `template` argument in the `article()` function to customise the template.

```typst
#let default-title(title) = {
  show: block.with(width: 100%)
  set align(center)
  set text(size: 1.75em, weight: "bold")
  title
}

#let default-author(authors) = context {
  show: block.with(width: 100%)
  let (gettext, locale) = i18n(text.lang)
  set text(cjk-latin-spacing: none)
  authors.map(author => {
    [#author.name#super(author.insts.map(it => numbering("a", it + 1)).join(","))]
    if author.corresponding {
      footnote[
        #gettext("corresponding.note")
        #strfmt(gettext("corresponding.address"), address: author.address)
        #if author.email != none {
          [#strfmt(gettext("corresponding.email"), email: author.email)]
        }
      ]
    }
    if author.cofirst == "thefirst" [
      #footnote(gettext("cofirst")) <fnt:cofirst-author>
    ] else if author.cofirst == "cofirst" [
      #footnote(<fnt:cofirst-author>)
    ]
  }).join(gettext("comma"))
}

#let default-affiliation(affiliations) = {
  show: block.with(width: 100%)
  set text(size: 0.8em)
  set par(leading: 0.4em)
  affiliations.enumerate().map(((ik, address)) => {
    super(numbering("a", ik + 1))
    h(1pt)
    address
  }).join(linebreak())
}

#let default-author-info(authors, affiliations, styles: (:)) = {
  let styles = (
    author: default-author,
    affiliation: default-affiliation,
    ..styles
  )
  (styles.author)(authors)
  let used_affiliations = authors.map(it => it.insts).flatten().dedup().map(it => affiliations.keys().at(it))
  (styles.affiliation)(used_affiliations.map(it => affiliations.at(it)))
}

#let default-abstract(abstract, keywords) = context {
  let (gettext, locale) = i18n(text.lang)
  // Abstract and keyword block
  if abstract != [] {
    heading(gettext("abstract"), numbering: none, outlined: false)
    par(first-line-indent: 1em, abstract)
    if keywords.len() > 0 {
      strong(gettext("keywords.title"))
      strfmt(gettext("keywords.text"), keywords: keywords.join(gettext("keywords.sep")))
    }
  }
  v(1em)
}

#let default-body(body) = context {
  let (gettext, locale) = i18n(text.lang)
  show heading.where(level: 1): set block(above: 1em, below: 1em)
  set par(first-line-indent: 1em)
  set figure(placement: top)
  set figure.caption(separator: ". ")
  show figure.where(kind: table): set figure.caption(position: top)
  set footnote(numbering: "1")
  body
}
```

## Example

See [the template](./template/main.typ) for full example.

```typst
#show: article.with(
  title: "Artile Title",
  authors: (
    "Author One": author-meta(
      "UCL", "TSU",
      email: "author.one@inst.ac.uk",
    ),
    "Author Two": author-meta(
      "TSU",
      cofirst: true
    ),
    "Author Three": author-meta(
      "TSU"
    )
  ),
  affiliations: (
    "UCL": "UCL Centre for Advanced Spatial Analysis, First Floor, 90 Tottenham Court Road, London W1T 4TJ, United Kingdom",
    "TSU": "Haidian  District, Beijing, 100084, P. R. China"
  ),
  abstract: [#lorem(100)],
  keywords: ("Typst", "Template", "Journal Article"),
  bib: bibliography("./ref.bib")
)
```

![](./assets/basic.png)

### Custom title

```typst
#show: article.with(
  title: "Artile Title",
  authors: (
    "Author One": author-meta(
      "UCL", "TSU",
      email: "author.one@inst.ac.uk",
    ),
    "Author Two": author-meta(
      "TSU",
      cofirst: true
    ),
    "Author Three": author-meta(
      "TSU"
    )
  ),
  affiliations: (
    "UCL": "UCL Centre for Advanced Spatial Analysis, First Floor, 90 Tottenham Court Road, London W1T 4TJ, United Kingdom",
    "TSU": "Haidian  District, Beijing, 100084, P. R. China"
  ),
  abstract: [#lorem(100)],
  keywords: ("Typst", "Template", "Journal Article"),
  bib: bibliography("./ref.bib"),
  template: (
    title: (title) => {
      set align(left)
      set text(size: 1.5em, weight: "bold", style: "italic")
      title
    }
  )
)
```

![](./assets/custom-title.png)

### Custom author infomation

```typst
#show: article.with(
  title: "Artile Title",
  authors: (
    "Author One": author-meta("UCL", email: "author.one@inst.ac.uk"),
    "Author Two": author-meta("TSU")
  ),
  affiliations: (
    "UCL": "UCL Centre for Advanced Spatial Analysis, First Floor, 90 Tottenham Court Road, London W1T 4TJ, United Kingdom",
    "TSU": "Haidian  District, Beijing, 100084, P. R. China"
  ),
  abstract: [#lorem(20)],
  keywords: ("Typst", "Template", "Journal Article"),
  template: (
    author-info: (authors, affiliations) => {
      set align(center)
      show: block.with(width: 100%, above: 2em, below: 2em)
      let first_insts = authors.map(it => it.insts.at(0)).dedup()
      stack(
        dir: ttb,
        spacing: 1em,
        ..first_insts.map(inst_id => {
          let inst_authors = authors.filter(it => it.insts.at(0) == inst_id)
          stack(
            dir: ttb,
            spacing: 1em,
            {
              inst_authors.map(it => it.name).join(", ")
            },
            {
              set text(0.8em, style: "italic")
              affiliations.values().at(inst_id)
            }
          )
        })
      )
    }
  )
)
```

![](./assets/custom-author-info.png)

### Custom abstract

```typst
#show: article.with(
  title: "Artile Title",
  authors: (
    "Author One": author-meta("UCL", email: "author.one@inst.ac.uk"),
    "Author Two": author-meta("TSU")
  ),
  affiliations: (
    "UCL": "UCL Centre for Advanced Spatial Analysis, First Floor, 90 Tottenham Court Road, London W1T 4TJ, United Kingdom",
    "TSU": "Haidian  District, Beijing, 100084, P. R. China"
  ),
  abstract: [#lorem(20)],
  keywords: ("Typst", "Template", "Journal Article"),
  template: (
    abstract: (abstract, keywords) => {
      show: block.with(
        width: 100%,
        stroke: (y: 0.5pt + black),
        inset: (y: 1em)
      )
      show heading: set text(size: 12pt)
      heading(numbering: none, outlined: false, bookmarked: false, [Abstract])
      par(abstract)
      stack(
        dir: ltr,
        spacing: 4pt,
        strong([Keywords]),
        keywords.join(", ")
      )
    }
  )
)
```

![](./assets/custom-abstract.png)

## Internationalisation and Localisation

> [!IMPORTANT]
> This feature is introduced since version `0.5.0`.
> The default language is still English.

For different language users, default templates vary when they set the document's language by:

```typst
#set text(lang: "xx")
```

Supported languages:

- [x] English (`en`)
- [x] Chinese (`zh`)

Users can still customise the templates.

Example:

![Default Chinese template](./assets/basic-zh.png)

## Changelog

### 0.5.0

Breaking changes:

- Template interface for `author-info`, `author` and `affiliation` is changed.
  - `author-info`: `(authors, affiliations, styles: (:)) => {}` This function use the styles provided in `styles` or default styles to show authors and affiliations.
  - `author`: `(authors) => {}` This function now accepts a list of authors.
  - `affiliation`: `(affiliations) => {}` This function now accepts a list of used affiliations.

New features:

- Add support for internationalisation and localisation for the following languages:
  - English (`en`)
  - Chinese (`zh`)

Improvements:

- Fix: show "Abstract" with no numbering and not outlined

### 0.4.0

Breaking changes:

- Affiliation labels are now shown with alphabetic characters instead of numbers.
- Parameter `bib` is removed. Users should use the built-in `bibliography` function to create a bibliography in the right place.

New features:

- A `appendix` function is added to show contents as appendices.
- A `suffix` function is added to show additional contents before the appendix. This is useful when heading numbers are shown but need to be hide for the "suffix" part.
- A `booktab` function is added to create three-line tables.

Improvements:

- A 1em space is added beneath the abstract and keywords.
- The `placement` argument of the `figure` function is set to `top` by default.
- The separator between figure labels and captions is changed to a period followed by a space.
