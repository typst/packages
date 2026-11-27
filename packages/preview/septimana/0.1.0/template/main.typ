#import "@preview/septimana:0.1.0": week-plan

#week-plan(
  // Your due date, for example datetime(year: 2027, month: 3, day: 31).
  due: datetime.today() + duration(weeks: 16),
  // The plan starts today; set a start date to begin on another day.
  // start: datetime(year: 2026, month: 12, day: 1),
  title: [Bachelorarbeit],
  lang: "de", // "de" or "en"
  // A milestone is a date or a number of weeks before the due date.
  milestones: (
    (6, [Erste Fassung]),
    (3, [Korrekturlesen]),
    (1, [Druck]),
  ),
  // The rows of the week page.
  habits: ("Schreiben", "Lesen", "Quellen sortieren", "Betreuung", "Pause"),
  week-pages: 1,
)
