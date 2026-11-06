// NAME: Internal utilities sub-module

// UTIL: Check if given required arguments are provided
#let required-args(..args) = {
  for arg in args.named().keys() {
    if args.named().at(arg) == none {
      panic("Missing required argument: " + arg)
    }
  }
}


// UTIL: Handles special numbering in #book and #appendices
#let numbering(
  patterns: (),
  scope: (:),
) = (
  ..nums
) => context {
  import "@preview/numbly:0.1.0": numbly

  // Set #patterns final value
  let patterns = if patterns.at(0) != auto {patterns.at(0)}
    else if scope.h1 != none {patterns.at(1, default: none)}
    else {patterns.at(2, default: none)}
  
  if patterns == none {return none}
  
  // Transform patterns into positional arguments
  patterns = arguments(..patterns).pos()
  
  let scope = scope
  
  // When using a default numbering string:
  if patterns.len() == 1 and not patterns.at(0).contains(regex("\{.*\}")) {
    return numbering(..patterns, ..nums)
  }
  
  // when numbering-style == none
  if patterns == () {
    if scope.h1 != none {
      patterns.push("\n")
      scope.h1 = scope.h1 + ":"
    }
    if scope.h2 != none {
      patterns.push("\n")
       scope.h2 = scope.h2 + ":"
    }
  }
  
  // Numbering showed after TOC.
  if query(selector(label("outline")).before(here())).len() != 0 {
    if scope.h1 != none and patterns.len() >= 1 {
      // Heading level 1 become part
      patterns.at(0) = scope.h1 + " " + patterns.at(0)
  
      // Heading level 2 become chapter
      if scope.h2 != none and patterns.len() >= 2 {
        patterns.at(1) = scope.h2 + " " + patterns.at(1)
      }
    } else {
      let n = scope.at("n", default: 0)
      
      // Heading level 1 become chapter, if no part
      if scope.h2 != none and patterns.len() >= 1 {
        patterns.at(n) = scope.h2 + " " + patterns.at(n)
      }
    }
  }
  // Numbering showed in TOC:
  else {
    let contents = ()
    
    for pattern in patterns {
      // Remove any "\n" at the end of numbering patterns:
      contents.push(
        pattern.trim(regex("\n+$"))
      )
    }
    patterns = contents
  }

  // HACK: #book(part: "") set clean parts, without name nor numbering.
  if scope.h1 == "" {
    patterns.at(0) = ""
  }
  
  // Get numbering using numbly
  numbly(default: "I.I.1.1.1.a", ..patterns)(..nums)
}


// UTIL: Create a date using named and positional arguments
#let date(..date) = {
  if type(date.pos().at(0)) == datetime {return date.pos().at(0)}
  
  // Convert array or dictionary to arguments
  if type(date.pos().at(0)) == array or type(date.pos().at(0)) == dictionary {
    date = arguments(..date.pos().at(0))
  }
  
  let year = if date.pos().len() >= 1 {date.pos().at(0)}
    else if date.named().at("year", default: none) != none {date.named().year}
    else {datetime.today().year()}
  
  let month = if date.pos().len() >= 2 {date.pos().at(1)}
    else if date.named().at("month", default: none) != none {date.named().month}
    else {1}

  let day = if date.pos().len() == 3 {date.pos().at(2)}
    else if date.named().at("day", default: none) != none {date.named().day}
    else {1}

  datetime(
    year: year,
    month: month,
    day: day
  )
}