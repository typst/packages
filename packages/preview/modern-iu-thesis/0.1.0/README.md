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
)
```

and

```typst
#iuquote(content)
```

Everything else follows along with basic Typst syntax such as headings, figures, tables, etc. See
the provided template as an example.
