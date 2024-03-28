#import "../settings/styles.typ": *
#import "utils.typ": *

#let createSectionTitle(
  title
) = {
  text(
    size: sectionStyle.title.size, 
    weight: sectionStyle.title.weight, 
    fill: sectionStyle.title.fontColor,
    title
  )
  h(sectionStyle.margins.RightToHLine)
  hLine()
}