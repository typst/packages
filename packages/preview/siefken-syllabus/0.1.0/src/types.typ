#import "constants.typ": PREFIX
#import "@preview/elembic:1.1.1" as e

//
// TYPES
//

/// Colors used in the syllabus template.
#let colors_type = e.types.declare(
  "colors",
  prefix: PREFIX,
  doc: "Colors used in the syllabus template.",

  fields: (
    e.field("primary", e.types.smart(color), doc: "Primary syllabus color", default: blue),
    e.field("secondary", e.types.smart(color), doc: "Secondary syllabus color", default: green.darken(30%)),
    e.field("tertiary", e.types.smart(color), doc: "Tertiary syllabus color", default: yellow.darken(50%)),
  ),
  casts: ((from: dictionary),),
)

/// Type of a basic_info item
#let basic_info_type = e.types.declare(
  "basic_info_item",
  prefix: PREFIX,
  doc: "A basic information item for the syllabus, such as the textbook or course webpage.",

  fields: (
    e.field("title", content, doc: "Title of the basic info item", required: true, named: true),
    e.field("value", content, doc: "Value(s) of the basic info item", required: true, named: true),
  ),
  casts: ((from: dictionary),),
)

/// An event in the syllabus timetable, such as a homework or midterm.
#let event = e.types.declare(
  "event",
  prefix: PREFIX,
  doc: "An event in the syllabus timetable, such as a homework or midterm.",

  fields: (
    e.field("name", content, doc: "The event name (e.g., Midterm or Homework)", required: true, named: true),
    e.field("date", datetime, doc: "Date of the event", required: true, named: true),
    e.field("type", e.types.option(e.types.union("homework", "test", "project", "holiday"))),
    e.field(
      "key",
      e.types.option(str),
      doc: "A key to identify the event; this can be used to lookup the event for display later",
    ),
    e.field("duration", e.types.option(duration), doc: "The length of the event."),
  ),
  casts: ((from: dictionary),),
)

/// A type that declares a font function. This can be coerced
/// from a string, an array of strings, or a function that returns `content`.
#let fond_declaration = e.types.declare(
  "font_declaration",
  prefix: PREFIX,
  doc: "A type that declares a font function. This can be coerced from a string, an array of strings, or a function that returns `content`.",
  fields: (
    e.field(
      "font",
      function,
      doc: "The font declaration; this will be a function that returns content (i.e. appropriately formatted text)",
      required: true,
    ),
  ),
  casts: (
    (from: function, with: font_declaration => func => font_declaration(func)),
    (from: str, with: font_declaration => font_name => font_declaration(it => text(font: font_name, it))),
    (
      from: e.types.array(str),
      with: font_declaration => font_names => font_declaration(it => text(font: font_names, it)),
    ),
    // (from: e.types.array(str)),
  ),
)
