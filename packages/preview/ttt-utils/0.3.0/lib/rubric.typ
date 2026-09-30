#import "@preview/valkyrie:0.2.2" as z
#import "assignments.typ": question, is-scenario, _question_counter, point-tag, _question-label

// ------------
// Schemas
// ------------
/// This schema defines the structure of the criteria for the rubric. It expects an array of strings, where the first string is the label for the criteria and the rest are the data points for that criteria. The schema transforms this array into a dictionary with a "label" key for the criteria label and a "data" key for an array of data points.
#let criteria-schema = z.dictionary(
  pre-transform: z.coerce.dictionary((criteria) => {
    assert.eq(type(criteria), array)
    return (
      label: criteria.first(),
      data: criteria.slice(1)
    )

  }),
  (
    label: z.string(),
    data: z.array(
      pre-transform: z.coerce.array,
      z.string()
    )
  )
)


/// This schema defines the structure of the levels for the rubric. It allows for three types of input:
/// 1. An array of strings, where each string is a label for a level. The value for each level will be its index in the array.
/// 2. An array of numbers, where each number is a value for a level. The label for each level will be the string representation of the number.
/// 3. An array of dictionaries, where each dictionary has a "value" key for the level's value and a "label" key for the level's label.
#let level-schema = z.array(
  pre-transform: (self, items) => {
    let first_item = items.first(default: none)
    if type(first_item) == str {
      items.enumerate().map(((idx, label)) => (
        value: idx,
        label: label
      ))
    } else if type(first_item) == int or type(first_item) == float {
      items.map(i => (
        label: str(i),
        value:i)
      )
    } else {
      items
    }
  },
  z.dictionary((
    value: z.number(),
    label: z.string(),
  ))
)

// ------------
// Rubric function
// ------------

/// Creates a rubric table based on the given criteria and levels.
#let rubric(
  /// the criteria for the rubric, given as an array of strings, where the first element is the label and the rest are the data points
  /// -> array
  criteria,
  /// the levels for the rubric, given as an array of strings or numbers or dictionary.
  /// If strings are given, they will be used as labels and the values will be their indices.
  /// If numbers are given, they will be used as values and their string representations will be used as labels.
  /// If dictionaries are given, they should have the form {value: number, label: string}.
  /// -> array
  levels: (),
  /// a function that takes a level value and returns the corresponding hint text, which will be displayed in the table cells.
  /// By default, it will return the level value as a string with a lightened color.
  /// -> function
  level-hints: it => text(luma(180), str(it)),
  /// sets whether points will be added to the metadata and rendered in the rubric. If false, points will not be calculated or rendered at all.
  /// Default: true
  /// -> bool
  calc-points: true,
  /// additional properties for the table, such as stroke, fill, etc.
  ..rest
) = {
    // Validate and transform the input data using the defined schemas
    criteria = z.parse(criteria, criteria-schema)
    levels = z.parse(levels, level-schema)
    level-hints = if level-hints == none { it => [] } else { level-hints }


    // save metadata
    let points = (calc.max(..levels.map(l => l.value)) * criteria.data.len())

    if calc-points {
      context {
        let level = if is-scenario() { 2 } else { 1 }
        // _question_counter.step(level: level)
        // note: metadata must be a new context to fetch the updated _question_counter value correct
        context [#metadata((type: "ttt-question", num: _question_counter.get() ,points: points)) #_question-label]
      }
    }

    // render table
    table(
      columns: (1fr, (2cm,) * levels.len()).flatten(),

      inset: (x, y) => if y == 0 { 0.5em } else { (x: 0.5em, y: 0.8em) },
      align: (start + horizon, (center + horizon,) * levels.len()).flatten(),
      stroke: (x,y) => (paint: black.lighten(30%), thickness: 0.4pt),
      fill: (x, y) => if y == 0 { blue.lighten(50%) } else {},
      ..rest,
      table.header([*#criteria.label*], ..levels.map(l => l.label)),
      ..criteria.data.map(c => {return (c,..levels.map(l => level-hints(l.value)))} ).flatten(),
    )

    // render points if it's an assignment and collect-points is not enabled
    context{
      if not is-scenario() {
        align(end,[\_\_ / #point-tag(points)])
      }
    }
}
