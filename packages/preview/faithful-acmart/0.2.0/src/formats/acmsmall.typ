// Layout and typography for the small ACM journal format.

#import "_base.typ": tp, size-ladder, make-format, bottom-margin

#let acmsmall(font-size: 10pt) = make-format(
  name: "acmsmall",
  ladder: size-ladder(font-size, format: "acmsmall"),
  paper: (width: 6.75in, height: 10in),
  margin: (
    inside: 46 * tp,
    outside: 46 * tp,
    top: 85 * tp,
    bottom: bottom-margin(font-size, 722.7, 85, ("8": 570, "9": 571, "10": 574, "11": 569, "12": 570)),
  ),
  foot-skip: 24 * tp,
  author-font: (family: "sans", weight: "regular", size: "large"),
  affil-font: (family: "serif", weight: "regular", size: "small"),
)
