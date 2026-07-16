// manuscript format — single-column draft layout (acmart's default format).
//
// Letterpaper, generic geometry (acmart.dtx:3756 sets only head/marginpar, so the
// margins are geometry's letterpaper defaults), 9pt default (acmart.dtx:3066).
// Same single-column journal topmatter and generic section fonts as acmsmall.
// Geometry probed from the bundled class (`tools/test.py probe`); values in TeX points.
// acmart loads setspace and applies \onehalfspacing for every manuscript-format
// document, which is a 1.25 \baselinestretch over amsart's 9/11pt size table.
#import "_base.typ": tp, size-ladder, make-format

#let manuscript(font-size: 9pt) = make-format(
  name: "manuscript",
  ladder: size-ladder(font-size, format: "manuscript", baseline-stretch: 1.25),
  paper: (width: 8.5in, height: 11in),
  // Asymmetric (twoside): marginparwidth=6pc is reserved in the outer margin.
  margin: (
    inside: 73.71614 * tp,
    outside: 110.57424 * tp,
    top: 95.39738 * tp,    // 1in + topmargin(-3.87262) + 13 + 14 (head top 68.39738)
    bottom: 139.57261 * tp,
  ),
  foot-skip: 12 * tp,      // \footskip = 12pt (no foot=2pc override)
)
