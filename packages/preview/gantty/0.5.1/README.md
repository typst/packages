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

## Examples

![A Gantt chart](https://gitlab.com/john_t/typst-gantty/-/raw/master/example/gantt.svg)

index.typ:

```typst
#import "@preview/gantty:0.5.0": gantt

#gantt(yaml("gantt.yaml"))
```

Here, the orange is used to indicate a task completed late and the green is used
to indicate a task that has been completed.

gantt.yaml:

```yaml
# Whether or not to show today as a 'milestone' on the gantt chart.
show-today: true
# Headers at the top of the gantt chart. Can include `year`, `month`,
# `week`, or `day`
#
# Should you want to customize these, there are the functions
# `create-header`, `create-custom-year-header`, `create-custom-month-header`,
# `create-custom-day-header`, and `create-custom-week-header`; whose outputs can
# be used in the headers array.
headers:
  - month
  - week
# A start date. Not required.
start: 2024-11-01
# An end date. Not required.
end: 2025-03-24
# A list of tasks
tasks:
    # The name of the task.
  - name: Research
    # Tasks with subtasks _can_ specify a start, end, and done date.
    # If not, then the date will be calculated from its sub tasks.
    #
    # Thus it is rarely needed to specify this field, so it is unlikely
    # you will need to use this field alongside the `subtasks` field.
    intervals:
      - start: 2024-11-27
        end: 2024-12-04
        done: 2024-11-29

    # Optional: tasks, subtasks, milestones, intervals, and dependencies all
    # support an `x` dictionary which can be used to attatch custom properties
    # to them for custom drawers
    #
    # x:
    #   my-awesome-library:
    #     asignee: Simon

    # This task's subtasks.
    #
    # Each has the same format as an element of the `tasks` array.
    subtasks:
      - name: "Read Statements"
        start: 2024-11-27
        end: 2024-12-04
        # Optional: indicates a completion date of a task, so that the
        # task will be highlighted differently.
        done: 2024-11-29
  - name: Drafting
    subtasks:
      - name: α draft
        # Optional: give this task an `id` to be referenced
        # by a dependency
        id: alpha-draft
        start: 2024-12-12
        end: 2024-12-31
      - name: β draft
        id: beta-draft
        start: 2024-12-31
        end: 2025-01-31
        # Optional: dependencies for this task.
        # 
        # These are rendered as an arrow between the tasks.
        # 
        # dependencies:
        #   - id: alpha-draft
      - name: Final Draft
        # If a task has a hiatus in it, it can be specified like this:
        # Each interval can have its own `start`, `end`, and `date`.
        intervals:
          - start: 2025-03-07
            end: 2025-03-14
          - start: 2025-03-18
            end: 2025-03-24
  - name: Production Log
    subtasks:
      - name: Record initial ideas
        start: 2024-11-27
        end: 2024-12-04
        done: 2024-12-08
milestones:
  - name: 1st Draft Hand In
    date: 2025-02-14
    # Optional: whether or not the date should be shown in this milestone
    show-date: true 
  - name: Final Hand In
    date: 2025-03-24
```

## Styling

Gantty is very customizable. Here is the `test/serious-depepdencies` example:

![A Gantt chart with dependencies](https://gitlab.com/john_t/typst-gantty/-/raw/master/tests/serious-dependencies/ref/1.png)
