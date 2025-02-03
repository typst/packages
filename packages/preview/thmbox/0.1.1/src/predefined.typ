#import "thmbox.typ": thmbox

#import "translations.typ"
#import "colors.typ"

// Some predefined environments

/// Used for theorems, uses a dark red color by default.
/// All args that can be passed to `thmbox` can be passed
/// to this function, which can override the defaults
/// specified here as well.
///
/// - color (color): Overrides the color to dark red
/// - variant (content): Overrides the variant to "Theorem"
/// - thmbox (function): The `thmbox` function this function is based on. Can be used to plug-in a modified variant
/// - args (arguments): Any arguments that can be passed to `thmbox`
/// -> content
#let theorem(
  color: colors.dark-red, 
  variant: translations.variant("theorem"), 
  thmbox: thmbox, 
  ..args
) = thmbox(color: color, variant: variant, ..args)

/// Used for propositions, uses a light blue color by default.
/// All args that can be passed to `thmbox` can be passed
/// to this function, which can override the defaults
/// specified here as well.
///
/// - color (color): Overrides the color to light blue
/// - variant (content): Overrides the variant to "Proposition"
/// - thmbox (function): The `thmbox` function this function is based on. Can be used to plug-in a modified variant
/// - args (arguments): Any arguments that can be passed to `thmbox`
/// -> content
#let proposition(
  color: colors.light-blue, 
  variant: translations.variant("proposition"), 
  thmbox: thmbox, 
  ..args
) = thmbox(color: color, variant: variant, ..args)

/// Used for lemmas, uses a light turquoise color by default.
/// All args that can be passed to `thmbox` can be passed
/// to this function, which can override the defaults
/// specified here as well.
///
/// - color (color): Overrides the color to light turquoise
/// - variant (content): Overrides the variant to "Lemma"
/// - thmbox (function): The `thmbox` function this function is based on. Can be used to plug-in a modified variant
/// - args (arguments): Any arguments that can be passed to `thmbox`
/// -> content
#let lemma(
  color: colors.light-turquoise, 
  variant: translations.variant("lemma"), 
  thmbox: thmbox, 
  ..args
) = thmbox(color: color, variant: variant, ..args)

/// Used for corollaries, uses a pink color by default.
/// All args that can be passed to `thmbox` can be passed
/// to this function, which can override the defaults
/// specified here as well.
///
/// - color (color): Overrides the color to pink
/// - variant (content): Overrides the variant to "Corollary"
/// - thmbox (function): The `thmbox` function this function is based on. Can be used to plug-in a modified variant
/// - args (arguments): Any arguments that can be passed to `thmbox`
/// -> content
#let corollary(
  color: colors.pink, 
  variant: translations.variant("corollary"), 
  thmbox: thmbox, 
  ..args
) = thmbox(color: color, variant: variant, ..args)

/// Used for definitions, uses an orange color by default.
/// All args that can be passed to `thmbox` can be passed
/// to this function, which can override the defaults
/// specified here as well.
///
/// - color (color): Overrides the color to orange
/// - variant (content): Overrides the variant to "Definition"
/// - thmbox (function): The `thmbox` function this function is based on. Can be used to plug-in a modified variant
/// - args (arguments): Any arguments that can be passed to `thmbox`
/// -> content
#let definition(
  color: colors.orange, 
  variant: translations.variant("definition"), 
  thmbox: thmbox, 
  ..args
) = thmbox(color: color, variant: variant, ..args)

/// Used for examples, uses a lime color and is not numbered by default.
/// All args that can be passed to `thmbox` can be passed
/// to this function, which can override the defaults
/// specified here as well.
///
/// - color (color): Overrides the color to lime
/// - variant (content): Overrides the variant to "Example"
/// - numbering (none | string | function): Disables numbering
/// - sans (boolean): Disables using a sans font in the body
/// - thmbox (function): The `thmbox` function this function is based on. Can be used to plug-in a modified variant
/// - args (arguments): Any arguments that can be passed to `thmbox`
/// -> content
#let example(
  color: colors.lime, 
  variant: translations.variant("example"), 
  numbering: none,
  sans: false,
  thmbox: thmbox,
  ..args
) = thmbox(
  color: color, 
  variant: variant, 
  numbering: numbering, 
  sans: sans, 
  ..args
)

/// Used for remarks, uses a gray color and is not numbered by default.
/// All args that can be passed to `thmbox` can be passed
/// to this function, which can override the defaults
/// specified here as well.
///
/// - color (color): Overrides the color to gray
/// - variant (content): Overrides the variant to "Remark"
/// - numbering (none | string | function): Disables numbering
/// - sans (boolean): Disables using a sans font in the body
/// - thmbox (function): The `thmbox` function this function is based on. Can be used to plug-in a modified variant
/// - args (arguments): Any arguments that can be passed to `thmbox`
/// -> content
#let remark(
  color: colors.gray, 
  variant: translations.variant("remark"), 
  numbering: none,
  sans: false,
  thmbox: thmbox,
  ..args
) = thmbox(
  color: color, 
  variant: variant, 
  numbering: numbering, 
  sans: sans, 
  ..args
)
  
/// Used for notes, uses a turquoise color and is not numbered by default.
/// All args that can be passed to `thmbox` can be passed
/// to this function, which can override the defaults
/// specified here as well.
///
/// - color (color): Overrides the color to turquoise
/// - variant (content): Overrides the variant to "Note"
/// - numbering (none | string | function): Disables numbering
/// - sans (boolean): Disables using a sans font in the body
/// - thmbox (function): The `thmbox` function this function is based on. Can be used to plug-in a modified variant
/// - args (arguments): Any arguments that can be passed to `thmbox`
/// -> content
#let note(
  color: colors.turquoise, 
  variant: translations.variant("note"), 
  numbering: none,
  sans: false,
  thmbox: thmbox,
  ..args
) = thmbox(
  color: color, 
  variant: variant, 
  numbering: numbering, 
  sans: sans, 
  ..args
)

/// Used for algorithms, uses a purple color by default.
/// All args that can be passed to `thmbox` can be passed
/// to this function, which can override the defaults
/// specified here as well.
///
/// - color (color): Overrides the color to purple
/// - variant (content): Overrides the variant to "Algorithm"
/// - sans (boolean): Disables using a sans font in the body
/// - thmbox (function): The `thmbox` function this function is based on. Can be used to plug-in a modified variant
/// - args (arguments): Any arguments that can be passed to `thmbox`
/// -> content
#let algorithm(
  color: colors.purple, 
  variant: translations.variant("algorithm"),
  sans: false,
  thmbox: thmbox,
  ..args
) = thmbox(color: color, variant: variant, sans: sans, ..args)

/// Used for claims, uses a green color and is not numbered by default.
/// All args that can be passed to `thmbox` can be passed
/// to this function, which can override the defaults
/// specified here as well.
///
/// - color (color): Overrides the color to green
/// - variant (content): Overrides the variant to "Claim"
/// - numbering (none | string | function): Disables numbering
/// - thmbox (function): The `thmbox` function this function is based on. Can be used to plug-in a modified variant
/// - args (arguments): Any arguments that can be passed to `thmbox`
/// -> content
#let claim(
  color: colors.green, 
  variant: translations.variant("claim"), 
  numbering: none,
  thmbox: thmbox,
  ..args
) = thmbox(
  color: color, 
  variant: variant, 
  numbering: numbering, 
  ..args
)

/// Used for axioms, uses a dark red color by default.
/// All args that can be passed to `thmbox` can be passed
/// to this function, which can override the defaults
/// specified here as well.
///
/// - color (color): Overrides the color to dark red
/// - variant (content): Overrides the variant to "Theorem"
/// - thmbox (function): The `thmbox` function this function is based on. Can be used to plug-in a modified variant
/// - args (arguments): Any arguments that can be passed to `thmbox`
/// -> content
#let axiom(
  color: colors.aqua, 
  variant: translations.variant("axiom"), 
  thmbox: thmbox, 
  ..args
) = thmbox(color: color, variant: variant, ..args)