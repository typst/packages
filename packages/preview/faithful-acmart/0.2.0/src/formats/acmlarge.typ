// Layout and typography for the large ACM journal format.

#import "_base.typ": tp, size-ladder, make-format, bottom-margin, generic-sec-fonts

#let acmlarge(font-size: 10pt) = make-format(
  name: "acmlarge",
  ladder: size-ladder(font-size, format: "acmlarge"),
  paper: (width: 8.5in, height: 11in),
  margin: (
    inside: 81 * tp,
    outside: 81 * tp,
    top: 105 * tp,
    bottom: bottom-margin(font-size, 794.97, 105, ("8": 550, "9": 549, "10": 550, "11": 556, "12": 556)),
  ),
  foot-skip: 24 * tp,
  sec-fonts: generic-sec-fonts + (
    section:    (family: "sans", weight: "regular", style: "normal", size: "large"),
    subsection: (family: "sans", weight: "regular", style: "normal", size: "large"),
  ),
)
