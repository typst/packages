#import "src/exams.typ"
#import "src/labs.typ"
#import "src/calendars.typ"


/// code-block: Create a code block formatted for exams
/// Wraps in box to the edge of the code, can add white space if need it to be longer
/// - include-line-numbers (boolean): Boolean param for whether line numbers should be included in the output
/// - width (unit) width of code-block
/// - raw-code (content): raw code block
#let code-block(include-line-numbers: true, width: auto, raw-code) = {
  assert(
    type(raw-code) == content,
    message: "Expected raw-code to be content, but received " + str(type(raw-code))
  )

  let lines = raw-code.text.split("\n")  
  
  // fold to flat array of cells, 
  // (1, firstLine, 2, secondLine, etc
  // then spread to table values later 
  let table-values = ()
  // pythonic enumerate :)
  for (i, line) in lines.enumerate() {
    // push line number
    // table_values.push(text(fill: gray)[#(i + 1)]) // start at 1 instead of 0
    if include-line-numbers {
      table-values.push(raw([#(i + 1)].text))
      
    }

    // converting to raw like this loses the language context, so copy it to each line

    // you can't check if the property is none, because it just doesn't have the property
    let target-lang = if raw-code.has("lang") { raw-code.lang } else { "bash" }

    table-values.push(raw(line, lang: target-lang)) 
  }

  // wrap in a box to avoid having conditional stroke

  let desired-columns = (auto)
  if include-line-numbers {
    desired-columns = (auto, auto)
  } 

  block(
    stroke: rgb("#d9d9d9"),
    inset: 2pt, // need some extra internal padding
    width: width,
    table(
      columns: desired-columns,
      stroke: none,
      inset: (x: 5pt, y: 3pt),
      ..table-values
    )
  )
}

