#import "parse-formula-intermediate-representation.typ": string-to-reaction
#import "parse-content-intermediate-representation.typ": content-to-reaction
#import "model/reaction-element.typ": reaction

#let reaction-localised={
  context{
    if text.lang == "fr"{
      [réaction]
    } else if text.lang == "de"{
      [Reaktion]
    } else if text.lang == "it"{
      [reazione]
    }else {
      [reaction]
    }
  }
}


///This is the main function of this package. Draws chemical equations and molecules. You can use both strings and content as input. We will try our best to parse it.
///
/// ```example
/// #ce("H2O") \
/// #ce[H2O]
/// ```
/// -> content
#let ce(
  /// The equation or molecule that should be drawn -> string|content
  formula,
  block: false,
  numbering:none,
  number-align: end + horizon,
  supplement:auto,
  alt: none
  ) = {
  math.equation(
    block: block,
    numbering:numbering,
    number-align: number-align,
    supplement: if supplement == auto {reaction-localised} else {supplement},
    alt:alt,
    if type(formula) == str{
      show "*": sym.dot
      let result = string-to-reaction(formula)
      if result.len() == 1{
        result.at(0)
      } else {
        reaction(result)
      }
    } else if type(formula) == content{
      show "*": sym.dot
      let result = content-to-reaction(formula)
      if result.len() == 1{
        result.at(0)
      } else {
        reaction(result)
      }
    }
  )
}