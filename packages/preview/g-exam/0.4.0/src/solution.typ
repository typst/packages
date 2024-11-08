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
/// - body (string, content): Body of question solution
#let solution(
    alternative-content: none,
    show-solution:none,
    body) = {
      // [#type(alternative-content) \ ]

      // assert(alternative-content == none or type(alternative-content) == "content",
      //   message: "Invalid alternative-content value")

    context {
      let show-solution = __g-show-solution.final()

      if show-solution == true {
        body
      }
      else {
        hide[#body]
        [ \ ] 
        hide[#body]
        [ \ ] 
        hide[#body]
        [ \ ]
        // alternative-content
      }
    }
}

#let g-solution(
    alternative-content: none,
    show-solution:none,
    body) = {
      solution(alternative-content: alternative-content, show-solution: show-solution)[body]
    }