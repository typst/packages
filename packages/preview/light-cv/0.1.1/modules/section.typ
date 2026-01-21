#import "../template/settings/styles.typ": *
#import "utils.typ": *

#let create-section-title(
  title
) = {
  text(
    size: section-style.title.size, 
    weight: section-style.title.weight, 
    fill: section-style.title.font-color,
    title
  )
  h(section-style.margins.right-to-hline)
  hline()
}