# Gantty

Gantty is a typst library for creating Gantt charts using datetimes.

View the manual [here](https://john_t.gitlab.io/typst-gantty/manual.pdf).

## Features

- Works with real dates.
- Customizable styling.
- Extensible to support multiple languages.

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
#import "@preview/gantty:0.3.0": gantt

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
