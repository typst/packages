#import "../template/settings/styles.typ": *
#import "utils.typ": *

#let create-section-title(
  styles: (),
  title: "",
) = {
  text(
    size: styles.section-style.title.size,
    weight: styles.section-style.title.weight,
    fill: styles.section-style.title.font-color,
    title,
  )
  h(styles.section-style.margins.right-to-hline)
  h-line()
}
