// # Information footer. Rodapé de informação.

#import "./source.typ": source_for_content_created_by_authors

#let figure_footer(
  note: none,
  source: none,
) = [
  // Figures must have a source.
  Fonte:
  #if source == none {
    [#source_for_content_created_by_authors().]
  } else {
    source
  }
  #parbreak()
  #if note != none {
    if type(note) == array {
      for (index, item) in note.enumerate() {
        [Nota #(index + 1): #item]
        parbreak()
      }
    } else {
      [Nota: #note]
    }
  }
]
