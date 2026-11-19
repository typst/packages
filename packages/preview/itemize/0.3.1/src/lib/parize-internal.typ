/// Taken from `parize`

#let ParType = (
  native: "native",
  default: "default", // paragraph
  parbreak-indented: "parbreak-indented", // paragraph break with indentation
  parbreak-non-indented: "parbreak-non-indented", // paragraph break without indentation
  block-all: "block-all", // block-indent + block-leading
  block-indent: "block-indent", // block-level elements that are included
  block-leading: "block-leading", // block-level elements that are in `block-text-leading`
  block-none: "block-none", // block-level elements that are not included
  non-tight-list-parbreak: "non-tight-list-parbreak", // non-tight list with paragraph break
)

#let prevent-parize-recursion-label = label("__cdl_parize_prevent-label__")

#let par-type-state = state("__cdl_parize_par_type__", (data: (par-type: ParType.native), backup: ()))

#let update-native = it => {
  it.data = (par-type: ParType.native)
  return it
}