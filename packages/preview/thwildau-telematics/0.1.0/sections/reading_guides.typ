#import "../utils/translation.typ": translation

#let make-reading-guides(
  reading-guides: none
) = {
  heading(translation("Notes for the reader"))
  reading-guides
}
