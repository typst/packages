#import"./global.typ": *

/// Show solution of question.
/// 
/// *Example:*
/// ``` #solution(
///    alternative-content: v(1fr)
///  )[
///  I know the demostration, but there's no room on the margin. For any clarification ask Andrew Whilst.
/// ]```
///
/// - alternative-content (string, content): Alternate content when the question solution is not displayed.
/// - show-solution: (true, false, "space", "spacex2", "spacex3"): Show the solutions.
/// - color (none, color): Color of the text solution.
/// - body (string, content): Body of question solution
#let solution(
    alternative-content: none,
    show-solution:none,
    color:none,
    body) = {

    context {
      let show-solution = __g-show-solutions.final()

      if show-solution == true {
        v(3pt)
        text(fill:__g-solution-color(solution-color: color))[#body]
        v(7pt)
      }
      else {
        if alternative-content != none {
          [#alternative-content]
        }
        else {
          if show-solution == "space" {
            hide[#body]
            [ \ ] 
          }
          else if show-solution == "spacex2" {
            hide[#body]
            [ \ ] 
            hide[#body]
            [ \ ] 
          }
          else if show-solution == "spacex3" {
            hide[#body]
            [ \ ] 
            hide[#body]
            [ \ ] 
            hide[#body]
            [ \ ]
          }
        }
      }
    }
}

#let g-solution(
    alternative-content: none,
    show-solution:none,
    body) = {
      panic("g-solution function is obsolete, use solution.")
    }