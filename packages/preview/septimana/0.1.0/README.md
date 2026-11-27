A printable week plan until your thesis is due. Set the due date: the first page prints one row of seven boxes for
every week until then, with the calendar week and the dates. Days before the start and after the due date are grey,
the due day is marked, and milestones appear in their week. The next page is a week page with your own rows. Print
it and tick the boxes by hand. German and English.

An empty box is an empty day, not a failure.

## Usage

Start a new project from this template, or:

```typ
#import "@preview/septimana:0.1.0": week-plan

#week-plan(
  due: datetime(year: 2027, month: 3, day: 31),
  start: datetime(year: 2026, month: 12, day: 1),
  title: [Bachelor thesis],
  lang: "en",
  milestones: (
    (6, [First draft]),
    (datetime(year: 2027, month: 2, day: 10), [Talk to supervisor]),
  ),
)
```

| Parameter | Default | |
|---|---|---|
| `due` | required | the due date |
| `start` | today | first day of the plan |
| `title` | none | shown under the heading |
| `lang` | `"de"` | `"de"` or `"en"` |
| `milestones` | none | pairs of a date (or a number of weeks before the due date) and a label |
| `habits` | writing, reading, sorting sources, supervisor, break | the rows of the week page |
| `week-pages` | `1` | how many week pages to print |
| `credit` | `true` | the small line at the foot of each page; `false` hides it |

The week grid is modelled on the habit app [SevenGrid](https://sevengrid.app).

## Licence

MIT No Attribution (MIT-0), see `LICENSE`.
