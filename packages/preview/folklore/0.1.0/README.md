# folklore

`folklore` is a template for typesetting fiction novels, with facilities for author commentary.

## Components

`folklore` provides some components useful for typesetting books.

```typ

#author-notes[Notes can go here.]
#summary[Summaries can go here.]
#titled-box[Custom Title][You can also make custom boxes.]

#major-break

Back from a break!
```

## Configuration

All `folklore` parameters and their defaults are listed below.

```typ
#show: setup.with(
  doc,
  work-title: [],
  custom-work-half-title: [],
  work-author: [],
  copyright-page: [],
  preface: [],
  recto-toc: true,
  blank-pages-after-toc: 0,
  blank-pages-before-start: 0,
  recto-chapter-start: true,
  title-text-settings: none,
  text-settings: none,
  par-settings: none,
  page-settings: none,
)
```

To set parameters for [text](https://typst.app/docs/reference/text/text/#parameters), [paragraphs](https://typst.app/docs/reference/model/par/#parameters), and the [page](https://typst.app/docs/reference/layout/page/#parameters), add parameters as dictionaries into the corresponding settings. For example:

```typ
#show: setup.with(
  work-title: [Some Title],
  work-author: [Me],
  text-settings: (font: "STIX Two Text"),
  page-settings: (width: 4.25in, height: 5.5in),
)

= chapter one

And so on...
```
