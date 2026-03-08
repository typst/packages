# siefken-syllabus

Typst Syllabus template for my courses at the University of Toronto.

<p align="center">
    <img src="https://github.com/siefkenj/typst-siefken-syllabus/raw/main/docs/images/example.svg" alt="Example rendering of thesis template" />
</p>

## Usage

```typst
#import "@preview/siefken-syllabus:0.1.0" as s
#import "@preview/elembic:1.1.1" as e

// Initialize all settings for the course
#show: e.set_(
  s.settings,
  code: "Mat 244",
  name: "Differential Equations",
  term: "Fall 2025",
  term_start_date: datetime(year: 2025, month: 9, day: 2),
  term_end_date: datetime(year: 2025, month: 10, day: 15),
  // `basic_info` is populated in a table at the start of the syllabus
  basic_info: (
    (
      title: "Textbook",
      value: [Introduction to Differential Equations by John Doe],
    ),
    (
      title: "Course webpage",
      value: [https://example.com/course],
    ),
  ),
  // Holidays are automatically added to the timetable
  holidays: (
    (
      name: [Thanksgiving],
      date: datetime(year: 2025, month: 10, day: 13),
    ),
  ),
  // Events are automatically added to the timetable
  events: (
    (
      name: [Midterm],
      // hours/minutes/seconds are optional
      date: datetime(year: 2025, month: 9, day: 15, hour: 17, minute: 10, second: 0),
      // An optional duration will affect how the event is displayed
      duration: duration(hours: 2),
      type: "test",
      // Setting a `key` allows this date to be referenced later in the syllabus
      key: "midterm",
    ),
    (
      name: [Optional Homework],
      date: datetime(year: 2025, month: 9, day: 22),
      type: "homework",
    ),
  ),
)

// After we `show: s.template` we put the actual content of our syllabus.
#show: s.template

Differential Equations is a really great course! You'll love lit.

== Assessments

#s.annotated_item(
  title: "Midterm",
  subtitle: "50%"
)[
  A multiple-choice midterm on
  // We can access and print dates that we have previously set in the settings
  // by referencing them with their `key` field.
  #s.get_event_time("midterm")
]
#s.annotated_item(
  title: "Final Exam",
  subtitle: "50%"
)[
  A comprehensive final exam on the last day of the term
  // We can also access the term start and end dates as well as the tutorial start date.
  #s.get_event_time("term_end_date")
]

== Schedule

#s.timetable(
  week_start_day: "monday",
  weekly_data: (
    [Week 1: Introduction to Differential Equations],
    [Week 2: First-Order Differential Equations],
    [Week 3: Second-Order Differential Equations],
    [Week 4: Laplace Transforms],
    [Week 5: Systems of Differential Equations],
  ),
)
```

### Elements

#### `syllabus_settings(...)`

```typst
/// Settings for the syllabus template.
syllabus_settings(
    /// [optional] Course code (e.g., "MAT244")
    code: string,
    /// [optional] Course name (e.g., "Mathematics for Computer Science")
    name: string,
    /// [optional] Term (e.g., "Fall 2025")
    term: none or string,
    /// [optional] The date the term starts
    term_start_date: datetime,
    /// [optional] The date the term ends
    term_end_date: datetime,
    /// [optional] The date tutorials start
    tutorial_start_date: none or datetime,
    /// [optional] Basic information to be displayed at the start
    /// of the syllabus. For example, the textbook, or course webpage.
    basic_info: array of basic_info_item,
    /// [optional] Events in the syllabus timetable, such as homeworks
    /// or midterms
    events: array of event,
    /// [optional] Holidays that occur during the term; it is assumed
    /// that no classes occurs during a holiday
    holidays: array of event,
    /// [optional] Colors used in the syllabus
    colors: colors,
    /// [optional] Monospace font for links
    font_mono: font_declaration,
    /// [optional] Sans-serif font for headings
    font_sans: font_declaration,
    /// [optional] Serif font for body text
    font: font_declaration,
    /// [optional] Width of the gutter for the syllabus; this is where
    /// the section headings will be displayed
    gutter_width: length
)
```

#### `template(...)`

```typst
/// The syllabus template. Use with `#show: template`.
template(
    /// (required) The content of the syllabus
    doc,
    /// [optional] If `minipage` is true, `set page(...)`
    /// will be avoided so that the syllabus content can
    /// be typeset in a box/block
    minipage: boolean
)
```

#### `annotated_item(...)`

```typst
/// An item with an annotation that hangs in the left margin
annotated_item(
    /// (required) The descriptive test that will be shown
    /// inline in the document
    body,
    /// [optional] The title of the item
    title: none or content,
    /// [optional] Additional description appearing below
    /// the title
    subtitle: none or content
)
```

## Development

To compile the documentation to html, use

```
typst compile --features html --format html docs/index.typ --root ./ --input html=true
```
