// Front-page font.
//
// kulemt-front.dtx is emphatic about this: "An Helvetica font must be used on
// the front material. The best and most complete look-alike in LaTeX [...] is
// TeX Gyre Heros. So this font is required to be installed, otherwise an error
// is issued (a fatal one in thesis layout)."
//
// The 0.1.0 template asked for "Nimbus Sans", which is not shipped with
// typst.app. Typst falls back silently, so the title page came out in the
// default serif face. Listing several names makes Typst walk the list until it
// finds one that exists, so this works locally and in the web app.
//
// "TeX Gyre Heros" is the name the OTF exposes; "TeXGyreHeros" is what some
// installers register. Nimbus Sans and Helvetica are the same Helvetica
// metrics; Arial and Liberation Sans are last-resort metric-compatible
// substitutes.
#let front-font = (
  "TeX Gyre Heros",
  "TeXGyreHeros",
  "Nimbus Sans",
  "Helvetica",
  "Arial",
  "Liberation Sans",
)

// Typst measures `leading` between the bottom edge of one line and the top
// edge of the next, where the top edge defaults to the cap height (~0.7em).
// LaTeX's \fontsize{size}{baselineskip} measures baseline to baseline. This
// converts, so the front pages keep kulemt's line spacing.
#let leading-for(size, baselineskip) = baselineskip - 0.7 * size
