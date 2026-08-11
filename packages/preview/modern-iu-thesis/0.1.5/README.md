# modern-iu-thesis

IU thesis template in Typst

Simple template which meets thesis and dissertation [requirements](https://graduate.indiana.edu/academic-requirements/thesis-dissertation/index.html) of IU Bloomington's
Graduate School. This template provides a couple functions:

```typst
#show: thesis.with(
    title: [content],
    author: [content],
    dept: [content],
    year: [content],
    month: [content],
    day: [content],
    committee: (
        (
            name: "Person 1",
            title: "Ph.D.",
        ),
    ),
    dedication: [content],
    acknowledgement: [content],
    abstract: [content],
    body-font-size: 11pt,
    caption-font-size: 11pt,
)
```

and

```typst
#iuquote(content)
```

Everything else follows along with basic Typst syntax such as headings, figures, tables, etc. See
the provided template as an example.

## CV

The CV requirement at the end of the thesis/dissertation can be added in the body of your document
by adding something like the following (after the bibliography):

```typst
#set page(footer: none)
#set page(margin: 0.6in)
#heading(numbering: none)[Curriculum Vitae] <cv_heading>
#align(center)[#image("cv_full.pdf", page: 1, width: 115%)]
#align(center)[#image("cv_full.pdf", page: 2, width: 115%)]
#align(center)[#image("cv_full.pdf", page: 3, width: 115%)]
```
