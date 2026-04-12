#import"./global.typ": *

/// Show a question.
/// 
/// *Example:*
/// ``` 
/// #question(points:2)[This is a question]
/// ```
///
/// - points (none, float): Points of the question.
/// - points-position (none, left, right): Position of points. If none,  use the position defined in G-Exam. 
/// - solution (none, content): Solution of the question.
/// - solution-color (none, color): Color of the text solution.
/// - body (string, content): Body of question.
/// -> content
#let question(
    points: none,
    points-position: none,
    solution: none,
    solution-color: none,
    body) = {
  __g-question-number.step(level: 1) 
  
  [#hide[]<end-g-question-localization>]
  __g-question-point.update(p => 
    {
      if points == none { 0 }
      else { points }
    })
  
  context {
    let __g-question-points-position = points-position
    if __g-question-points-position == none {
      __g-question-points-position = __g-question-points-position-state.final()  
    }

    let __g-question-text-parameters = __g-question-text-parameters-state.final()
    let __decimal-separator = __g-decimal-separator.final()

    let __show-solution = __g-show-solutions.final()

    if __g-question-points-position == left {
      v(0.1em)
      {
        __g-question-number.display(__g-question-numbering) 
        if(points != none) {
          __g-paint-tab(points:points, decimal-separator: __decimal-separator) 
          h(0.2em)
        }
      }
      set text(..__g-question-text-parameters)
      body 
      if __show-solution == true {
        text(fill:__g-solution-color(solution-color: solution-color))[#solution]
      }
    }
    else if __g-question-points-position == right {
      v(0.1em)
      if(points != none) {
        place(right, 
            dx: 13%,
            float: false,
            __g-paint-tab(points: points, decimal-separator: __decimal-separator))
      }
      __g-question-number.display(__g-question-numbering) 
      set text(..__g-question-text-parameters)
      body 
      if __show-solution == true {
        text(fill:__g-solution-color(solution-color: solution-color))[#solution]
      }

    }
    else {
      v(0.1em) 
      __g-question-number.display(__g-question-numbering)
      set text(..__g-question-text-parameters)
      body 
      if __show-solution == true {
        text(fill:__g-solution-color(solution-color: solution-color))[#solution]
      }
    }
  }
}

/// Show a sub-question.
/// 
/// *Example:*
/// ``` 
/// #subquestion(points:2)[This is a sub-question]
/// ```
///
/// - points (none, float): Points of the sub-question.
/// - points-position (none, left, right): Position of points. If none,  use the position defined in G-Exam. 
/// - solution (none, content): Solution of the sub-question.
/// - solution-color (none, color): Color of the text solution.
/// - body (string, content): Body of sub-question.
/// -> content
#let subquestion(
    points: none, 
    points-position: none, 
    solution: none,
    solution-color: none,
    body) = {

  assert(points-position in (none, left, right),
      message: "Invalid point position")

  __g-question-number.step(level: 2)

  let subg-question-points = 0
  if points != none { subg-question-points = points }
  __g-question-point.update(p => p + subg-question-points )

  context {
    let __g-question-points-position = points-position
    if __g-question-points-position == none {
      __g-question-points-position = __g-question-points-position-state.final()
    }
    
    let __g-question-text-parameters = __g-question-text-parameters-state.final()
    let __decimal-separator = __g-decimal-separator.final()

    let __show-solutions = __g-show-solutions.final()

    set par(hanging-indent: 0.7em) //if body.has("text")
    
    if __g-question-points-position == left {
      v(0.1em)
      {
        h(0.7em) 
        __g-question-number.display(__g-question-numbering) 
        if(points != none) {
          __g-paint-tab(points: points, decimal-separator: __decimal-separator)
          h(0.2em)
        }
      }
      set text(..__g-question-text-parameters)
      [#body]
      if __show-solutions == true {
        text(fill:__g-solution-color(solution-color: solution-color))[#solution]
      }
    }
    else if __g-question-points-position == right {
      v(0.1em)
      if(points != none) {
        place(right, 
            dx: 13%,
            float: false,
            __g-paint-tab(points: points, decimal-separator: __decimal-separator)) 
      }
      {
        h(0.7em) 
        __g-question-number.display(__g-question-numbering) 
      }
      set text(..__g-question-text-parameters)
      body
      if __show-solutions == true {
        text(fill:__g-solution-color(solution-color: solution-color))[#solution]
      }
    }
    else {
      v(0.1em)
      {
        h(0.7em) 
        __g-question-number.display(__g-question-numbering) 
      }
      set text(..__g-question-text-parameters)
      body
      if __show-solutions == true {
        text(fill:__g-solution-color(solution-color: solution-color))[#solution]
      }
    }
  }
}

#let g-question(
    points: none, 
    point: none,
    points-position: none, 
    body) = {
      panic("g-question is obsolete, please use question.")
    }

#let g-subquestion(
    points: none, 
    point: none,
    points-position: none, 
    body) = {
      panic("g-subquestion is obsolete, please use subquestion.")
    }
