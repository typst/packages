#import "thmbox.typ": thmbox

#import "translations.typ"
#import "colors.typ"

// Some predefined environments

/// Used for theorems, uses a dark red color by default.
#let theorem = thmbox.with(color: colors.dark-red, variant: translations.variant("theorem"))

/// Used for propositions, uses a light blue color by default.
#let proposition = thmbox.with(color: colors.light-blue, variant: translations.variant("proposition"))

/// Used for lemmas, uses a light turquoise color by default.
#let lemma = thmbox.with(color: colors.light-turquoise, variant: translations.variant("lemma"))

/// Used for corollaries, uses a pink color by default.
#let corollary = thmbox.with(color: colors.pink, variant: translations.variant("corollary"))

/// Used for definitions, uses an orange color by default.
#let definition = thmbox.with(color: colors.orange, variant: translations.variant("definition"))

/// Used for examples, uses a lime color and is not numbered by default.
#let example = thmbox.with(
  color: colors.lime, 
  variant: translations.variant("example"), 
  numbering: none, 
  sans: false,
)

/// Used for remarks, uses a gray color and is not numbered by default.
#let remark = thmbox.with(
  color: colors.gray, 
  variant: translations.variant("remark"), 
  numbering: none, 
  sans: false,
)
  
/// Used for notes, uses a turquoise color and is not numbered by default.
#let note = thmbox.with(
  color: colors.turquoise, 
  variant: translations.variant("note"), 
  numbering: none, 
  sans: false,
)

/// Used for exercises, uses a blue color by default.
#let exercise = thmbox.with(
  color: colors.light-aqua, 
  variant: translations.variant("exercise"),
  sans: false,
)

/// Used for algorithms, uses a purple color by default.
#let algorithm = thmbox.with(
  color: colors.purple, 
  variant: translations.variant("algorithm"), 
  sans: false,
)

/// Used for claims, uses a green color and is not numbered by default.
#let claim = thmbox.with(
  color: colors.green, 
  variant: translations.variant("claim"), 
  numbering: none,
)

/// Used for axioms, uses an aqua color by default.
#let axiom = thmbox.with(color: colors.aqua, variant: translations.variant("axiom"))