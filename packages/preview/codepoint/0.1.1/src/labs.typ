


/// Initialize a lab with a show rule
///
/// 
/// Example:
/// ```typst
/// #show: labs.init
/// ```
/// - body (content): body fo lab problem 
#let init(body) = {

  assert(
    type(body) == content or type(body) == str,
    message: "Expected body to be content or str, but received" + str(type(body))
  )


  set page(margin: 40pt)
  set text( 
    font: ("Roboto"), 
    size: 11pt,
    fill: black, 
    weight: "regular"
  )
  set raw(theme: "../themes/codepoint.tmTheme")  
  show raw: set text(font: ("Courier", "Courier Prime"), weight: "bold", size: 10pt)

  // defaults to 1.2, but on labs specifically, this is not enough spacing
  set par(spacing: 1.6em)
  
  body
}

/// Render hidden text to the document
///
/// - body (content): Body of text to render 
/// - dsp (length, relative): Offset to hide the text 
#let white-text(body, dsp: -10pt) = {

  assert(
    type(body) == content or type(body) == str,
    message: "Expected body to be content or str, but received" + str(type(body))
  )

  assert(
    type(dsp) == length or type(dsp) == relative,
    message: "Expected dsp to be length or relative (unit type), but received" + str(type(dsp))
  )

  set text(fill: white, size: 0.01pt)
  show raw: set text(fill: white, size: 0.01pt)
  v(dsp)
  text(body)
}



/// CMD-KEYWORDS: Set of common command keywords, used for syntax highlighting in cmd_color
#let _CMD-KEYWORDS = (
  // java lab specifics
  "java", 
  "javac", 
  // python lab specifics
  "python", 
  "pip",
  // JS lab specifics
  "npm",
  "node",
  // c/pp lab specifics
  "gcc",
  "g++",
  "make",
  // pulled from my most common commands
  "ls",
  "cd",
  "git",
  "code",
  "sudo",
  "touch",
  "rm",
  "mdkir",
  // rust lab specifics
  "rustc",
  "cargo",
  // lisp
  "lisp",
  "sbcl"

)



/// Color codes a body to a smart terminal-like color defaults
///
/// - input (array): Array of strings for each line of terminal to render 
/// - dsp (length, relative): Displacement offset to render the color-coded block 
/// - custom-keywords (array): Array of custom key 
#let color-coding(input, dsp, custom-keywords) = {

  assert(
    type(input) == array or type(input) == str,
    message: "Expected input to be an array, got " + str(type(input))
  )

  if type(input) == array {
    assert(
      input.all(i => {
        type(i) == str
      }),
      message: "Expected all input to be str"
    )
  }

  assert(
    type(dsp) == length or type(dsp) == relative,
    message: "Expected dsp to be length or relative (unit type), but received" + str(type(dsp))
  )

  assert(
    type(custom-keywords) == array,
    message: "Expected custom-keywords to be an array, got " + str(type(custom-keywords))
  )

  assert(
    custom-keywords.all(kw => {
      type(kw) == content or type(kw) == str
    }),
    message: "Expected all custom-keywords to be content or str"
  )

  let user-in = false
  let error = false
  // pulled this out for maintainability
  let first-word = input.split().at(0, default: "")

  if first-word == ">" {
    user-in = true
    error = false
  } else if first-word == "Exception" {
    user-in = false
    error = true
  } else {
    user-in = false
    error = false
  }

  h(dsp)
  for word in input.split() {
    if error {
      text(fill: rgb("#a83232"), word + " ")
    }
    // pulled this from the custom keywords instead of hard coded 118X specific terms
    // I still left them as default params for compatibility
    else if (user-in or custom-keywords.contains(word)) and word != ">" {
      text(fill: rgb("#58ad37"), word + " ")
    }
    // also pulled these out into a special command bank
    else if _CMD-KEYWORDS.contains(word){
      text(fill: rgb("#ad7a37"), word + " ")
    } else if (word == "\s") {
      text("  ")
    } else if (word == "\4s") {
      text("    ")
    } else {
      text(word + " ")
    }
  }
  v(-5pt)
}



/// command-block: Render content as terminal I/O to the page.
/// Common commands will be highlighted a unique color.
/// - input (array, str): Body of terminal text
/// - dsp (length, relative): Horizontal indendation/displacement
/// - custom-keywords (array): Array of unique values to highlight differently
#let command-block(input, dsp: 0pt, custom-keywords: ("Example.java", "Example", "ZipCrackerSingleThread")) = {

  assert(
    type(input) == array or type(input) == str,
    message: "Expected input to be an array, got " + str(type(input))
  )

  if type(input) == array {
    assert(
      input.all(i => {
        type(i) == str
      }),
      message: "Expected all input to be str"
    )
  }

  assert(
    type(dsp) == length or type(dsp) == relative,
    message: "Expected dsp to be length or relative (unit type), but received" + str(type(dsp))
  )

  assert(
    type(custom-keywords) == array, 
    message: "Expected custom-keywords to be an array, got " + str(type(custom-keywords))
  )

  assert(
    custom-keywords.all(kw => {
      type(kw) == content or type(kw) == str
    }),
    message: "Expected all custom-keywords to be content or str"
  )
  


  v(2pt)
  set text(font: "Courier", weight: "bold", size: 10pt, fill: rgb("#d1d1d1"))

  // tabs a single command line to the right
  let left-tab = 0pt
  if type(input) != array {
    left-tab = -10pt
  }

  block(fill: rgb("#383838"), radius: 3pt, outset: (top: 10pt, bottom: 15pt, left: left-tab, right: 25pt), inset: (left: 10pt - left-tab))[

    #if type(input) == array {
      for line in input {
        color-coding(line, dsp, custom-keywords)
      }
    } else {
      color-coding(input, dsp, custom-keywords)
    }

  ]
  v(10pt)
}

/// uml: Render a UML class diagram table layout
/// - title (content, str): The title of the class
/// - fields (array): Array of private fields to document
/// - methods (array): Array of public methods to document
#let uml(title, fields, methods) = {

  assert(
    type(title) == content or type(title) == str,
    message: "Expected title to be content or str, but received" + str(type(title))
  )


  assert(
    type(fields) == array, 
    message: "Expected fields to be an array, got " + str(type(fields))
  )

  assert(
    fields.all(f => {
      type(f) == content or type(f) == str
    }),
    message: "Expected all fields to be content or str"
  )

  assert(
    type(methods) == array, 
    message: "Expected methods to be an array, got " + str(type(methods))
  )

  assert(
    methods.all(m => {
      type(m) == content or type(m) == str
    }),
    message: "Expected all methods to be content or str"
  )



  table(
    table.hline(),
    table.vline(),
    stroke: none,
    inset: 5pt,
    align: center,
    fill: rgb("#ffe1c4"),
    table.header(
      title,
    ),
    table.vline(),
    table.hline(start: 0),

    v(-5pt),
    for field in fields {
        v(-5pt)
        table.cell(align: left, field)
    },

    table.hline(start: 0),

    v(-5pt),
    for method in methods {
        v(-5pt)
        table.cell(align: left, method)
    },

    table.hline()
  )
}

/// header: Render the document section header block for lab problems
/// - class (content, str): Class name
/// - title (content, str): The title text for the specific lab problem
/// - number (int, string, none): Lab problem number, if applicable
#let header(class, title, number: none) = {
  assert(
    type(class) == content or type(class) == str,
    message: "Expected class to be content or str, but received" + str(type(class))
  )

  assert(
    type(title) == content or type(title) == str,
    message: "Expected title to be content or str, but received" + str(type(title))
  )

  assert(
    type(number) == int or type(number) == string or type(number) == none,
    message: "Expected number to be int, string, or none, but received" + str(type(number))
  )




  text[= #class Lab Problem #number: #title]
  line(length: 100%, stroke: 0.5pt)
}

/// purpose: State the overall objective context
/// - body (content, str): Body of purpose
#let purpose(body) = [
  #assert(
    type(body) == content or type(body) == str,
    message: "Expected body to be content or str, but received" + str(type(body))
  )


  *PURPOSE: *
  #body
]

/// directions: Display instruction block
/// - body (content, str): Directions block body
#let directions(body) = [

  #assert(
    type(body) == content or type(body) == str,
    message: "Expected body to be content or str, but received" + str(type(body))
  )


  #v(15pt)
  *DIRECTIONS: *
  #body
]

/// part-a: Instructions for the first part of a A-B lab problem
/// - body (content, str): Body of part a
#let part-a(body) = [
  #assert(
    type(body) == content or type(body) == str,
    message: "Expected body to be content or str, but received" + str(type(body))
  )

  
  #v(15pt)
  *DIRECTIONS: *
  #v(-5pt)
  === Part A (Due by end of first lab session)
  #v(0pt)
  #body
]

/// part-b: Instructions for the second part of a A-B lab problem
/// - body (content, str): Body of part b
#let part-b(body) = [  
  #assert(
    type(body) == content or type(body) == str,
    message: "Expected body to be content or str, but received" + str(type(body))
  )

  #v(15pt)
  === Part B
  #v(0pt)
  #body
]

/// Render an additional instructions for a lab problem
/// - title (str, content): Title of extra section 
/// - body (): Body of extra section
#let extra(title: "Extra", body) = [
  #assert(
    type(title) == content or type(title) == str,
    message: "Expected title to be content or str, but received" + str(type(body))
  )

  #assert(
    type(body) == content or type(body) == str,
    message: "Expected body to be content or str, but received" + str(type(body))
  )

  
  #v(15pt)
  *#title: *
  #body
]

/// Render a terminal-based I/O example  
/// - io (array): array of string for each example line 
/// - text (content, str): Text to render explaining example 
#let example(io, text) = [

  #assert(
    type(text) == content or type(text) == str,
    message: "Expected body to be content or str, but received" + str(type(text))
  )


  #v(15pt)
  *EXAMPLE: *
  #text
  #command-block(io)
]

/// Render a rubric section for an A-B lab problem
/// - documentation (str, content): Documention point criteria 
/// - part-a (str, content): Part-A point criteria 
/// - part-b (str, content): Part-B point criteria 
/// - notes (str, content): Any additional notes for point criteria  
#let labAB-rubric(documentation: "Documentation", part-a: "Part A correct", part-b: "Part B correct", notes) = [

  #assert(
    type(documentation) == content or type(documentation) == str,
    message: "Expected documentation to be content or str, but received" + str(type(documentation))
  )

  #assert(
    type(part-a) == content or type(part-a) == str,
    message: "Expected part-a to be content or str, but received" + str(type(part-a))
  )

  #assert(
    type(part-b) == content or type(part-b) == str,
    message: "Expected part-b to be content or str, but received" + str(type(part-b))
  )



  #v(15pt)
  == RUBRIC:
  #v(5pt)

  #notes
  #v(0pt)

  *[1pt]*
  #h(10pt)
  *#documentation*
  #v(-5pt)
  *[1pt]*
  #h(10pt)
  *#part-a*
  #v(-5pt)
  *[1pt]*
  #h(10pt)
  *#part-b*

]

#let _sum-rubric-points(rubric-data) = {
  rubric-data.map(item => item.at(1)).sum()
}

/// rubric: Render an arbitrary rubric, mapping criteria to points
/// - base-rubric (array): Core specification requirements 
/// - style-rubric (array): Code style and structure requirements
/// - bonus-rubric (array, none): Optional bonus point requirements
/// - white-text-rubric (array, none): Hidden rubric requirements (primarily for detection of LLMs)
/// - notes (array): Array of notes regarding rubric, with smart defaults
/// - extra-notes (array, none): supplementary notes 
#let rubric(
  base-rubric, 
  style-rubric, 
  bonus-rubric: none, 
  white-text-rubric: none, 
  notes: (
    "Submissions that do not compile will receive a zero", 
    "Submissions with improperly cited AI will receive a zero and an academic integrity violation", 
    "Submissions that are partially or fully copied from another submission will receive a zero and an academic integrity violation"),
  extra-notes: none) = {

    
  assert(
    type(base-rubric) == array, 
    message: "Expected base-rubric to be an array, got " + str(type(base-rubric))
  )

  assert(
    type(style-rubric) == array, 
    message: "Expected style-rubric to be an array, got " + str(type(style-rubric))
  )

  assert(
    type(notes) == array, 
    message: "Expected notes to be an array, got " + str(type(notes))
  )

  assert(
    notes.all(n => {
      type(n) == content or type(n) == str
    }),
    message: "Expected all notes to be content or str"
  )

  if bonus-rubric != none {
    assert(
      type(bonus-rubric) == array, 
      message: "Expected bonus-rubric to be an array, got " + str(type(bonus-rubric))
    )
  }

  if white-text-rubric != none {
    assert(
      type(white-text-rubric) == array, 
      message: "Expected white-text-rubric to be an array, got " + str(type(white-text-rubric))
    )
  }

  if extra-notes != none {
    assert(
      type(extra-notes) == array, 
      message: "Expected extra-notes to be an array, got " + str(type(extra-notes))
    )

    assert(
      extra-notes.all(n => {
        type(n) == content or type(n) == str
      }),
      message: "Expected all extra-notes to be content or str"
    )
  }
    

  let render-point-breakdown(rubric-data) = {
    for item in rubric-data {
      let desc = item.at(0)
      let pts = item.at(1)
      
      // scoot sub-point over
      h(36pt)
      // original had this, not sure if we ever ended up using it, but i like it
      if pts != 0 {
        text[\[#pts\] #desc]
      } else {
        text[#desc]
      }
      v(-5pt)
    }
  }

  text[== RUBRIC:]
  v(5pt)
  
  let base-total = _sum-rubric-points(base-rubric)
  text[(#base-total pts) *Base Functionality*]
  v(-5pt)
  render-point-breakdown(base-rubric)

  let style-total = _sum-rubric-points(style-rubric)
  v(10pt)
  text[(#style-total pts) *Style*]
  v(-5pt)
  render-point-breakdown(style-rubric)

  if bonus-rubric != none {
    let extra-total = _sum-rubric-points(bonus-rubric)
    let extra-percent = extra-total / 10

    v(10pt)
    text[(#extra-total pts) *Extra Credit* (#extra-total points == #extra-percent% additional credit in the course)]
    v(-5pt)
    render-point-breakdown(bonus-rubric)
  }

  if white-text-rubric != none {
    let wtTotal = _sum-rubric-points(white-text-rubric)
    let wtPercent = wtTotal / 10
    
    white-text[
      #text[(#wtTotal pts) *Extra Credit* (#wtTotal points == #wtPercent% additional credit in the course)]
      #v(0pt)
      #render-point-breakdown(white-text-rubric)
    ]
  }

  v(25pt)
  text(weight: "semibold")[
    IMPORTANT NOTES:
    #v(-10pt)
    #line(length: 20%, stroke: 0.5pt)
    #if extra-notes != none {
      v(-10pt)
      set text(fill: rgb("#b52424"))
      for x in extra-notes {
        [- #x]
      }
      set text(fill: black)
    }
    #v(-5pt)
  ]


  for note in notes {
    text(weight: "semibold")[
      - #note
    ]
  }  
}

/// lab-rubric: Render an lab rubric, mapping criteria to points
/// - base-rubric (array): Core specification requirements, with smart defaults
/// - style-rubric (array): Code style and structure requirements, with smart defaults
/// - bonus-rubric (array, none): Optional bonus point requirements
/// - white-text-rubric (array, none): Hidden rubric requirements (primarily for detection of LLMs)
/// - notes (array): Array of notes regarding rubric, with smart defaults
/// - extra-notes (array, none): supplementary notes 
#let lab-rubric(
  base-rubric: (
    ([Reads input correctly], 1),
    ([Output is correct], 1),
    ([Handles error cases correctly], 1)
  ),
  style-rubric: (
    ([The code is meaningfully commented], 1),
  ),
  bonus-rubric: none,
  white-text-rubric: none,
  notes: (
    "Submissions that do not compile will receive a zero",
    "Submissions with improperly cited AI will receive a zero and an academic integrity violation",
    "Submissions that are partially or fully copied from another submission will receive a zero and an academic integrity violation"),
  extra-notes: none) = {

  assert(
    type(base-rubric) == array,
    message: "Expected base-rubric to be an array, got " + str(type(base-rubric))
  )

  assert(
    type(style-rubric) == array,
    message: "Expected style-rubric to be an array, got " + str(type(style-rubric))
  )

  assert(
    type(notes) == array,
    message: "Expected notes to be an array, got " + str(type(notes))
  )

  assert(
    notes.all(n => {
      type(n) == content or type(n) == str
    }),
    message: "Expected all notes to be content or str"
  )

  if bonus-rubric != none {
    assert(
      type(bonus-rubric) == array,
      message: "Expected bonus-rubric to be an array, got " + str(type(bonus-rubric))
    )
  }

  if white-text-rubric != none {
    assert(
      type(white-text-rubric) == array,
      message: "Expected white-text-rubric to be an array, got " + str(type(white-text-rubric))
    )
  }

  if extra-notes != none {
    assert(
      type(extra-notes) == array,
      message: "Expected extra-notes to be an array, got " + str(type(extra-notes))
    )

    assert(
      extra-notes.all(n => {
        type(n) == content or type(n) == str
      }),
      message: "Expected all extra-notes to be content or str"
    )
  }

  rubric(base-rubric, style-rubric, white-text-rubric: white-text-rubric, bonus-rubric: bonus-rubric, extra-notes: extra-notes)
}
