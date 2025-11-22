// standard page margins
#let margin-normal = 2.54cm
#let margin-narrow = 1.27cm
#let margin-moderate-x = 2.54cm
#let margin-moderate-y = 1.91cm
#let margin-wide-x = 5.08cm
#let margin-wide-y = 2.54cm

// other margins
#let margin-a5-x = 2cm
#let margin-a5-y = 2.5cm

#let title(content, size: 32pt) = {
  set text(size: size)
  align(center)[ #content ]
}
