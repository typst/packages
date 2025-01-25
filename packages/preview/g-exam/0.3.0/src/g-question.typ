#import"./global.typ": *

/// Show a question.
/// 
/// *Example:*
/// ``` 
/// #g-question(point:2)[This is a question]
/// ```
///
/// - point (none, float): Points of the question.
/// - point-position (none, left, right): Position of points. If none,  use the position defined in G-Exam. 
/// - body (string, content): Body of question.
#let g-question(
    point: none, 
    point-position: none, 
    body) = {
  assert(point-position in (none, left, right),
      message: "Invalid point position")

  __g-question-number.step(level: 1) 
  
  [#hide[]<end-g-question-localization>]
  __g-question-point.update(p => 
    {
      if point == none { 0 }
      else { point }
    })
  
  locate(loc => {
    let __g-question-point-position = point-position
    if __g-question-point-position == none {
      __g-question-point-position = __g-question-point-position-state.final(loc)  
    }
    let __g-question-text-parameters = __g-question-text-parameters-state.final(loc)

    if __g-question-point-position == left {
      v(0.1em)
      {
        __g-question-number.display(__g-question-numbering) 
        if(point != none) {
          __g-paint-tab(point:point, loc: loc) 
          h(0.2em)
        }
      }
      set text(..__g-question-text-parameters)
      body 
    }
    else if __g-question-point-position == right {
      v(0.1em)
      if(point != none) {
        place(right, 
            dx: 15%,
            float: false,
            __g-paint-tab(point: point, loc: loc))
      }
      __g-question-number.display(__g-question-numbering) 
      set text(..__g-question-text-parameters)
      body 
    }
    else {
      v(0.1em) 
      __g-question-number.display(__g-question-numbering)
      set text(..__g-question-text-parameters)
      body 
    }
  })
}

/// Show a sub-question.
/// 
/// *Example:*
/// ``` 
/// #g-subquestion(point:2)[This is a sub-question]
/// ```
///
/// - point (none, float): Points of the sub-question.
/// - point-position (none, left, right): Position of points. If none,  use the position defined in G-Exam. 
/// - body (string, content): Body of sub-question.
#let g-subquestion(
    point: none, 
    point-position: none, 
    body) = {

  assert(point-position in (none, left, right),
      message: "Invalid point position")

  __g-question-number.step(level: 2)

  let subg-question-point = 0
  if point != none { subg-question-point = point }
  __g-question-point.update(p => p + subg-question-point )

  locate(loc => {
      let __g-question-point-position = point-position
      if __g-question-point-position == none {
        __g-question-point-position = __g-question-point-position-state.final(loc)
      }
      let __g-question-text-parameters = __g-question-text-parameters-state.final(loc)

      if __g-question-point-position == left {
        v(0.1em)
        {
          h(0.7em) 
          __g-question-number.display(__g-question-numbering) 
          if(point != none) {
            __g-paint-tab(point: point, loc:loc) 
            h(0.2em)
          }
        }
        set text(..__g-question-text-parameters)
        body
      }
      else if __g-question-point-position == right {
        v(0.1em)
        if(point != none) {
          place(right, 
              dx: 15%,
              float: false,
              __g-paint-tab(point: point, loc:loc)) 
        }
        {
          h(0.7em) 
          __g-question-number.display(__g-question-numbering) 
        }
        set text(..__g-question-text-parameters)
        body
      }
      else {
        v(0.1em)
        {
          h(0.7em) 
          __g-question-number.display(__g-question-numbering) 
        }
        set text(..__g-question-text-parameters)
        body
      }
    }
  )
}
