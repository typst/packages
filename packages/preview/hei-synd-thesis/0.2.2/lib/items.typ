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

#let item-circle(
  height: normal,
  body
) = {
  item-list(
    height: height,
    icon: icon-circle,
  )[#body]
}
#let item-square(
  height: normal,
  body
) = {
  item-list(
    height: height,
    icon: icon-square,
  )[#body]
}
#let item-checkbadge(
  height: normal,
  body
) = {
  item-list(
    height: height,
    icon: icon-check-badge,
  )[#body]
}
#let item-checkcircle(
  height: normal,
  body,
) = {
  item-list(
    height: height,
    icon: icon-check-circle,
  )[#body]
}
#let item-checksquare(
  height: normal,
  body
) = {
  item-list(
    height: height,
    icon: icon-check-square,
  )[#body]
}
#let item-check(
  height: normal,
  body
) = {
  item-list(
    height: height,
    icon: icon-check,
  )[#body]
}
#let item-circle(
  height: normal,
  body
) = {
  item-list(
    height: height,
    icon: icon-circle,
  )[#body]
}
#let item-square(
  height: normal,
  body
) = {
  item-list(
    height: height,
    icon: icon-square,
  )[#body]
}
#let item-file(
  height: normal,
  body
) = {
  item-list(
    height: height,
    icon: icon-file,
  )[#body]
}
#let item-folder(
  height: normal,
  body
) = {
  item-list(
    height: height,
    icon: icon-folder,
  )[#body]
}
#let item-xcircle(
  height: normal,
  body
) = {
  item-list(
    height: height,
    icon: icon-x-circle,
  )[#body]
}
#let item-xsquare(
  height: normal,
  body
) = {
  item-list(
    height: height,
    icon: icon-x-square,
  )[#body]
}
#let item-x(
  height: normal,
  body
) = {
  item-list(
    height: height,
    icon: icon-x,
  )[#body]
}
