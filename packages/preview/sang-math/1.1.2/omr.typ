// Additive OMR API. Every coordinate comes from the measured print layouts.
#import "omr/embed.typ": omr-embed
#let _omr-profiles = json("omr/profiles.json")
#let sang-omr-catalog = (:)
#for (id, measured) in _omr-profiles {
  sang-omr-catalog.insert(id, measured.profile)
}

// SBD is a prefix: preserve its columns and leave remaining columns blank.
// Only an explicitly requested pad (used for exam codes) adds leading zeros.
// Never truncate: an overlong code could silently identify another pupil.
#let sang-omr-code(value, digits, pad: false) = {
  if value == none or value == "" { return "" }
  if type(value) != str and type(value) != int {
    panic("sang-math OMR: identity must be a digit string or integer")
  }
  let code = str(value)
  if code.len() > digits { panic("sang-math OMR: identity exceeds " + str(digits) + " digits") }
  for character in code.clusters() {
    if not "0123456789".contains(character) {
      panic("sang-math OMR: identity must contain digits only")
    }
  }
  if pad { "0" * (digits - code.len()) + code } else { code }
}

// By default read the state at this sheet's location, not its final value:
// several pupils/exam codes can share a document without leaking the last code.
// `embed` reserves all registration marks vertically on an A4 exam page.
// Standalone A5/A4: page margin 10mm and embed:false.
#let sang-omr-sheet(
  profile: "new-12-2-4-a5",
  sbd: auto,
  ma-de: auto,
  embed: auto,
) = context {
  if type(profile) != str or not (profile in sang-omr-catalog) {
    panic("sang-math OMR: unknown sheet profile " + repr(profile))
  }
  let spec = _omr-profiles.at(profile)
  let pupil = sang-omr-code(if sbd == auto { state("sbd").get() } else { sbd }, spec.numSbd)
  let code = sang-omr-code(if ma-de == auto { state("made").get() } else { ma-de }, spec.numMade, pad: true)
  let embedded = if embed == auto { spec.profile.paper == "a5" } else { embed }
  if type(embedded) != bool { panic("sang-math OMR: embed must be auto or bool") }
  if embedded and spec.profile.paper != "a5" {
    panic("sang-math OMR: only an A5 profile can be embedded")
  }
  import ("omr/layouts/" + profile + ".typ") as sheet
  metadata((kind: "sang-math-omr", version: "1.1.1", profile: profile, sbd: pupil, made: code))
  // Keep printed glyphs consistent with the measured library even when the
  // surrounding exam uses another font or bold text. This scope ends here.
  let body = [
    #set text(font: "Libertinus Serif", weight: "regular")
    #sheet.render(sbd: pupil, ma-de: code)
  ]
  if embedded {
    omr-embed(block(width: 190mm, height: 140mm, inset: (top: 6mm, bottom: 6mm))[
      #body
    ])
  } else {
    body
  }
}
