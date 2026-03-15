//
// Description: Creating nice looking item list with different icons
// Author     : Silvan Zahno
//
#import "constants.typ": *

#let item-list(
  height: normal,
  icon: icon-check-square,
  body
) = {
  if body != none {
    v(-9pt)
    table(
      stroke: none,
      columns: 2,
      align: left+horizon,
      column-gutter: -2pt,
      image(icon, height:normal), body
    )
    v(-9pt)
  }
}

#let item-circle = item-list.with(icon: icon-circle)
#let item-square = item-list.with(icon: icon-square)
#let item-checkbadge = item-list.with(icon: icon-check-badge)
#let item-checkcircle = item-list.with(icon: icon-check-circle)
#let item-checksquare = item-list.with(icon: icon-check-square)
#let item-check = item-list.with(icon: icon-check)
#let item-file = item-list.with(icon: icon-file)
#let item-folder = item-list.with(icon: icon-folder)
#let item-xcircle = item-list.with(icon: icon-x-circle)
#let item-xsquare = item-list.with(icon: icon-x-square)
#let item-x = item-list.with(icon: icon-x)
