#import "parse-formula-intermediate-representation.typ": string-to-reaction
#import "parse-content-intermediate-representation.typ": content-to-reaction
#import "model/reaction-element.typ": reaction

#let reaction-localised={
  context{
    if text.lang == "fr"{
      [Réaction]
    } else if text.lang == "de"{
      [Reaktion]
    } else if text.lang == "it"{
      [Reazione]
    }else {
      [Reaction]
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
  /// The supplement to use to reference this chemical equation.
  /// defaults to "Reaction"
  supplement:auto,
  /// any other arguments that can be passed to the math.equation function.
  /// set block to true to reference it in your text
  /// use numbering to configure your numbering
  /// use number-align to configure how numbers align
  /// set alt to provide alt-text for accessibility
  ..args
  ) = {
  math.equation(
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
    },
    supplement: if supplement == auto {reaction-localised} else {supplement},
    ..args
  )
}