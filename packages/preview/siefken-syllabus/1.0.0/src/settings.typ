#import "types.typ": *


/// Settings for the syllabus template.
#let settings = e.element.declare(
  "syllabus_settings",
  prefix: PREFIX,
  doc: "Settings for the syllabus template.",

  // The settings should not be displayed.
  display: it => panic("Settings should not be displayed directly."),

  fields: (
    e.field("code", str, doc: "Course code (e.g., \"MAT244\")"),
    e.field("name", str, doc: "Course name (e.g., \"Mathematics for Computer Science\")"),
    e.field("term", e.types.option(str), doc: "Term (e.g., \"Fall 2025\")"),
    e.field("term_start_date", datetime, doc: "The date the term starts", default: datetime(
      year: 2000,
      month: 9,
      day: 3,
    )),
    e.field("term_end_date", datetime, doc: "The date the term ends", default: datetime(
      year: 2000,
      month: 12,
      day: 31,
    )),
    e.field("tutorial_start_date", e.types.option(datetime), doc: "The date tutorials start"),
    e.field(
      "basic_info",
      e.types.array(basic_info_type),
      doc: "Basic information to be displayed at the start of the syllabus. For example, the textbook, or course webpage.",
      default: (),
    ),
    e.field(
      "events",
      e.types.array(event),
      doc: "Events in the syllabus timetable, such as homeworks or midterms",
    ),
    e.field(
      "holidays",
      e.types.array(event),
      doc: "Holidays that occur during the term; it is assumed that no classes occurs during a holiday",
    ),
    // Formatting options
    e.field("colors", colors_type, doc: "Colors used in the syllabus", default: colors_type()),
    e.field(
      "font_mono",
      fond_declaration,
      doc: "Monospace font for links",
      default: "DejaVu Sans Mono",
    ),
    e.field(
      "font_sans",
      fond_declaration,
      doc: "Sans-serif font for headings",
      default: "Arial",
    ),
    e.field("font", fond_declaration, doc: "Serif font for body text", default: "DejaVu Serif"),
    e.field(
      "gutter_width",
      length,
      doc: "Width of the gutter for the syllabus; this is where the section headings will be displayed",
      default: 1.1in,
    ),
  ),
)
