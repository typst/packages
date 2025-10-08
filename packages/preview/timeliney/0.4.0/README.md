# Timeliney

Create Gantt charts automatically with Typst!

Here's a fully-featured example:

```typst
#import "@preview/timeliney:0.4.0"

#timeliney.timeline(
  show-grid: true,
  {
    import timeliney: *
      
    headerline(group(([*2023*], 4)), group(([*2024*], 4)))
    headerline(
      group(..range(4).map(n => strong("Q" + str(n + 1)))),
      group(..range(4).map(n => strong("Q" + str(n + 1)))),
    )
  
    taskgroup(
      title: [*Research*],
      content: text(10pt, white)[*John + Julia*],
      style: (stroke: 14pt + black),
      {
        task(
          "Research the market",
          (from: 0, to: 2, content: text(9pt)[John (70% done)]),
          style: (stroke: 13pt + gray),
        )
        task(
          "Conduct user surveys",
          (from: 1, to: 3, content: text(9pt)[Julia (50% done)]),
          style: (stroke: 13pt + gray),
        )
      },
    )

    taskgroup(title: [*Development*], {
      task("Create mock-ups", (2, 3), style: (stroke: 2pt + gray))
      task("Develop application", (3, 5), style: (stroke: 2pt + gray))
      task("QA", (3.5, 6), style: (stroke: 2pt + gray))
    })

    taskgroup(title: [*Marketing*], {
      task("Press demos", (3.5, 7), style: (stroke: 2pt + gray))
      task("Social media advertising", (6, 7.5), style: (stroke: 2pt + gray))
    })

    milestone(
      at: 3.75,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *Conference demo*\
        Dec 2023
      ])
    )

    milestone(
      at: 6.5,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *App store launch*\
        Aug 2024
      ])
    )
  }
)
```

![Example Gantt chart](sample.png)

## Installation
Import with `#import "@preview/timeliney:0.4.0"`. Then, call the `timeliney.timeline` function.

## Documentation
See [the manual](manual.pdf)!

## Changelog

See [CHANGELOG.md](changelog.md).
