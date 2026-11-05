//! Declaration of use of generative AI in the project

#import "locale.typ" as locale
#import "utils.typ": newpage
#import "arguments.typ": validate-argument

// Keys that belong to the documentation & drafting group
#let _documentation-keys = (
  "documentation",
  "reflection",
  "review",
  "research",
  "references",
  "summary",
  "translation",
)

// Keys that belong to the specific content development group
#let _specific-content-keys = (
  "assistance-coding",
  "generating-content",
  "optimization",
  "data-processing",
  "idea-inspiration",
  "other",
)


/// UC3M template for declaration of use of AI in the project.
///
/// - language (str): The language of the project (e.g. "en", "es").
/// - usage (bool): Whether AI is used in the project.
/// - data-usage (dictionary): AI data usage declaration.
/// - technical-usage (dictionary): Technical usage of AI.
/// - usage-reflection (content): Reflection on the usage of AI.
#let genai-template(
  language,
  style,
  usage,
  data-usage,
  technical-usage,
  usage-reflection,
) = {
  /* SETUP */

  // Remove first number of heading
  set heading(
    numbering: (..n) => { numbering("1.", ..n.pos().slice(1)) },
  )

  let answer-box = body => box(
    body,
    stroke: 0.5pt + black,
    inset: 0.5em,
    outset: 0.2em,
    radius: if style == "fancy" { 0.1em } else { 0em },
  )

  /* USAGE */

  [*#locale.AI-USAGE.affirmation.at(language)*]

  table(
    fill: (x, y) => if x != int(usage) { gray },
    columns: 2,
    align: auto,
    [*#locale.AFFIRMATION.at(style).at(language)*],
    [*#locale.NEGATION.at(style).at(language)*],
  )

  if not usage {
    [#locale.AI-USAGE.negation.at(language)]
    return
  }

  /* DATA USAGE */

  [== #locale.AI-DATA-USAGE.title.at(language)]

  table(
    columns: (1fr, 1fr),
    align: left,
    inset: (x: 1.5em, y: 0.8em),
    table.cell(colspan: 2, inset: 0.6em)[*#locale.QUESTION.at(language)*],

    /* general question */
    ..for (index, (question-key, question-data)) in locale
      .AI-DATA-USAGE
      .questions
      .pairs()
      .enumerate() {
      // we use spreading, creating an array within the loop
      // see https://forum.typst.app/t/how-come-this-does-not-generate-a-grid-as-expected/1660/2
      (
        // prompt spanning all columns
        table.cell(colspan: 2)[
          #set enum(start: index + 1, indent: 0em) // correctly set enum number
          + #question-data.prompt.at(language)
        ],
        // Answer layout: Answer1 (2fr), Answer2 (1fr+1fr with colspan), Answer3 (2fr)
        ..for (i, (answer-key, answer-text)) in question-data
          .answers
          .pairs()
          .enumerate() {
          (
            table.cell(
              // answer-key is "yes"/"no"; data-usage values are booleans
              fill: if data-usage.at(question-key) == (answer-key == "yes") {
                gray
              },
            )[
              #set align(horizon)
              #set par(justify: false)
              #answer-text.at(language)
            ],
          )
        },
      )
    },
  )

  /* TECHNICAL USAGE */

  [== #locale.AI-TECHNICAL-USAGE.title.at(language)]

  // Tool declaration intro sentence
  let tool = technical-usage.at("tool", default: none)
  if tool != none {
    [
      #locale.AI-TECHNICAL-USAGE.tool-declaration.at(language)
      (#tool) #locale.AI-TECHNICAL-USAGE.tool-declaration-suffix.at(language):
    ]
  }

  show heading.where(level: 3): set heading(numbering: none) // remove numbering

  // Helper: render a list of items for a given set of keys
  let render-items(keys) = {
    for key in keys {
      if technical-usage.keys().contains(key) {
        let label = locale.AI-TECHNICAL-USAGE.questions.at(key).at(language)
        let body = technical-usage.at(key)
        list.item({
          emph(label)
          linebreak()
          answer-box(body)
        })
        parbreak()
      }
    }
  }

  // Documentation & drafting section
  let has-documentation = _documentation-keys.any(k => technical-usage
    .keys()
    .contains(k))
  if has-documentation {
    [=== #locale.AI-TECHNICAL-USAGE.documentation-section.at(language)]
    render-items(_documentation-keys)
  }

  // Develop specific content section
  let has-specific = _specific-content-keys.any(k => technical-usage
    .keys()
    .contains(k))
  if has-specific {
    [=== #locale.AI-TECHNICAL-USAGE.specific-content-section.at(language)]
    render-items(_specific-content-keys)
  }

  /* REFLECTION */

  [== #locale.AI-USAGE-REFLECTION.title.at(language)]

  answer-box(usage-reflection)
}
