//
// Description: Creating nice looking item list with different icons
// Author     : Silvan Zahno
//
#import "constants.typ": *

/// Display a list item with a custom marker icon
///
/// - height (length): height of item markers
/// - icon (bytes): raw item marker image bytes (see `icons` dictionnary in constants)
/// - body (content): item content
/// -> content
#let item-list(
  height: normal,
  icon: icons.check-square,
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

#let item-circle = item-list.with(icon: icons.circle)
#let item-square = item-list.with(icon: icons.square)
#let item-checkbadge = item-list.with(icon: icons.check-badge)
#let item-checkcircle = item-list.with(icon: icons.check-circle)
#let item-checksquare = item-list.with(icon: icons.check-square)
#let item-check = item-list.with(icon: icons.check)
#let item-file = item-list.with(icon: icons.file)
#let item-folder = item-list.with(icon: icons.folder)
#let item-xcircle = item-list.with(icon: icons.x-circle)
#let item-xsquare = item-list.with(icon: icons.x-square)
#let item-x = item-list.with(icon: icons.x)
