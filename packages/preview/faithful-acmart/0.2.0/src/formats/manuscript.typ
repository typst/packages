// Layout and typography for manuscript submissions.

#import "_base.typ": tp, size-ladder, make-format, bottom-margin

#let manuscript(font-size: 9pt) = make-format(
  name: "manuscript",
  // setspace's \onehalfspacing selects its factor by \@ptsize.
  ladder: size-ladder(font-size, format: "manuscript",
    baseline-stretch: ("8": 1.25, "9": 1.25, "10": 1.25, "11": 1.213, "12": 1.241)
      .at(str(int(calc.round(font-size / 1pt))))),
  paper: (width: 8.5in, height: 11in),
  // The outer margin reserves space for margin notes.
  margin: (
    inside: 73.71614 * tp,
    outside: 110.57424 * tp,
    top: 95.39738 * tp,
    bottom: bottom-margin(font-size, 794.97, 95.39738, ("8": 560, "9": 560, "10": 550, "11": 561.91383, "12": 548.59283)),
  ),
  foot-skip: 12 * tp,
)
