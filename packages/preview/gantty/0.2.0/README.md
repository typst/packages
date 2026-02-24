# Gantty

Gantty is a typst library for creating Gantt charts using datetimes.

## Why not typst-timeliney

[Typst-timeliney](https://typst.app/universe/package/timeliney) is another
excellent typst Gantt chart creator. The main differences between this library
and typst-timeliney is that Gantty uses datetimes to work with real dates,
whereas typst-timeliney works with coordinates. Look at the typst-timeliney
documentation and decide which is more fitting for your use.

## Example

![A Gantt chart](https://gitlab.com/john_t/typst-gantty/-/raw/master/example/gantt.svg)

index.typ:

```typst
#import "@preview/gantty:0.2.0": gantt

#gantt(yaml("gantt.yaml"))
```

Here, the orange is used to indicate a task completed late and the green is used
to indicate a task that has been completed.

gantt.yaml:

```yaml
show-today: true
# Either month or day
viewport-snap: day
# Can include `year`, `month`, `week`, or `day`
headers:
  - month
  - week
# A start date. Not required.
start: 2024-11-01
# An end date. Not required.
end: 2025-03-31
taskgroups:
  - name: Research
    tasks:
      - name: Read Statements
        start: 2024-11-27
        end: 2024-12-04
        done: 2024-11-29
  - name: Drafting
    tasks:
      - name: α draft
        start: 2024-12-12
        end: 2024-12-31
      - name: β draft
        start: 2024-12-31
        end: 2025-01-31
      - name: First draft
        start: 2025-01-31
        end: 2025-02-14
      - name: γ draft
        start: 2025-02-14
        end: 2025-03-07
      - name: Final Draft
        start: 2025-03-07
        end: 2025-03-24
  - name: Production Log
    tasks:
        - name: Record initial ideas
          start: 2024-11-27
          end: 2024-12-04
          done: 2024-12-08
milestones:
  - name: 1st Draft Hand In
    date: 2025-02-14
  - name: Final Hand In
    date: 2025-03-24
```

## Styling

An additional `style` key can be added to the Gantt chart to
customize styling. The default style is:

```typst
#let default_style = (
  milestones: (
    normal: (stroke: (paint: black, thickness: 1pt)),
    today: (stroke: (paint: red, thickness: 1pt)),
  ),
  gridlines: (
    task_dividers: (stroke: (paint: luma(66%), thickness: 0.5pt)),
    years: (stroke: (paint: luma(66%), thickness: 1pt)),
    months: (stroke: (paint: luma(66%), thickness: 0.7pt)),
    weeks: (stroke: (paint: luma(66%), thickness: 0.2pt)),
    days: (stroke: (paint: luma(66%), thickness: 0.1pt)),
  ),
  groups: (
    uncompleted: (stroke: (paint: black, thickness: 3pt)),
    completed_early: (
      timeframe: (stroke: (paint: olive, thickness: 3pt)),
      body: (stroke: (paint: black, thickness: 3pt)),
    ),
    completed_late: (
      timeframe: (stroke: (paint: orange, thickness: 3pt)),
      body: (stroke: (paint: black, thickness: 3pt)),
    ),
  ),
  tasks: (
    uncompleted: (stroke: (paint: luma(33%), thickness: 2pt)),
    completed_early: (
      timeframe: (stroke: (paint: olive, thickness: 2pt)),
      body: (stroke: (paint: luma(33%), thickness: 2pt)),
    ),
    completed_late: (
      timeframe: (stroke: (paint: orange, thickness: 2pt)),
      body: (stroke: (paint: luma(33%), thickness: 2pt)),
    ),
  ),
)
```

Not all styles have to be changed. An example of styling is given below:

Note styles cannot be changed from within yaml/json/toml.

```typst
#{
  // Page setup...
  import "../lib.typ": gantt
  set page(height: auto)

  // Load a yaml file containing our gantt chart
  let gantt_yaml = yaml("gantt.yaml")

  // Change, for instance, the colour of the milestones
  let style = (
    milestones: (
      normal: (stroke: (paint: blue), thickness: 0.7pt),
    ),
  )
  gantt_yaml.style = style

  // And render
  gantt(gantt_yaml)
}
```
