#import "src/utils.typ"
#import "src/structure.typ"
#import "src/miniframes.typ"
#import "src/progressive-outline.typ"
#import "src/transition.typ"

// Export API
#let progressive-outline = progressive-outline.progressive-outline
#let render-miniframes = miniframes.render-miniframes
#let get-structure = miniframes.get-structure
#let get-current-logical-slide-number = miniframes.get-current-logical-slide-number
#let render-transition = transition.render-transition
#let merge-dicts = utils.merge-dicts
#let slide-title = utils.slide-title
#let navigator-config = structure.navigator-config
#let get-active-headings = structure.get-active-headings
#let resolve-slide-title = structure.resolve-slide-title
#let format-heading = structure.format-heading
#let is-role = structure.is-role
