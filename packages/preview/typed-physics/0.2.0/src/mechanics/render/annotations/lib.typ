// Internal annotation-rendering façade.
//
// A view hands over the annotations it was given and this is where each kind
// finds its renderer, so adding an annotation does not change any view.

#import "../../annotations/lib.typ" as annotation-vocabulary
#import "dimensions.typ"
#import "measures.typ"
#import "notes.typ"

#let render-annotations(scene, annotations, diagram-style) = {
  for annotation in annotation-vocabulary.validate-annotation-list(annotations) {
    if annotation.kind == "dimension" {
      dimensions.render-dimension(scene, annotation, diagram-style)
    } else if annotation.kind == "angle-mark" {
      measures.render-angle-mark(scene, annotation, diagram-style)
    } else if annotation.kind == "axis" {
      measures.render-axis(scene, annotation, diagram-style)
    } else if annotation.kind == "callout" {
      notes.render-callout(scene, annotation, diagram-style)
    } else if annotation.kind == "brace" {
      notes.render-brace(scene, annotation, diagram-style)
    } else {
      notes.render-arrow(scene, annotation, diagram-style)
    }
  }
}
