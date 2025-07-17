/// Accenting functions for the diacritics of the IPA.
/// 
/// This file was auto-generated. Re-run the package's
/// `./util/make-diacritics.py` script if you have
/// updated the definitions in `./src/_diacritics.csv`.
/// 
/// File generated on: 2025-07-05T12:16:57
/// Definitions included: 52

/*** Phonation diacritics***/

/// Apply the 'Aspirated' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Superscript h
/// / IPA description: Aspirated
/// / Unicode name: Modifier letter small h
/// / Unicode hex: `0x2b0`
/// / TyIPA name: aspirated
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let aspirated(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{2b0}")
  }
  modified.join("")
}

/// Apply the 'Breathy voiced' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Subscript umlaut
/// / IPA description: Breathy voiced
/// / Unicode name: Combining diaeresis below
/// / Unicode hex: `0x324`
/// / TyIPA name: breathy
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let breathy(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{324}")
  }
  modified.join("")
}

/// Apply the 'Creaky voiced' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Subscript tilde
/// / IPA description: Creaky voiced
/// / Unicode name: Combining tilde below
/// / Unicode hex: `0x330`
/// / TyIPA name: creaky
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let creaky(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{330}")
  }
  modified.join("")
}

/// Apply the 'Voiced' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Subscript wedge
/// / IPA description: Voiced
/// / Unicode name: Combining caron below
/// / Unicode hex: `0x32c`
/// / TyIPA name: voiced
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let voiced(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{32c}")
  }
  modified.join("")
}

/// Apply the 'Voiceless (above)' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Over-ring
/// / IPA description: Voiceless (above)
/// / Unicode name: Combining ring above
/// / Unicode hex: `0x30a`
/// / TyIPA name: voiceless-above
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let voiceless-above(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{30a}")
  }
  modified.join("")
}

/// Apply the 'Voiceless' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Under-ring
/// / IPA description: Voiceless
/// / Unicode name: Combining ring below
/// / Unicode hex: `0x325`
/// / TyIPA name: voiceless-below
/// / TyIPA alias(es): voiceless
/// 
/// -> str
#let voiceless-below(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{325}")
  }
  modified.join("")
}

/// Alias for `voiceless-below`.
#let voiceless = voiceless-below

/*** Place of articulation diacritics***/

/// Apply the 'Apical' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Inverted subscript bridge
/// / IPA description: Apical
/// / Unicode name: Combining inverted bridge below
/// / Unicode hex: `0x33a`
/// / TyIPA name: apical
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let apical(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{33a}")
  }
  modified.join("")
}

/// Apply the 'Dental' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Subscript bridge
/// / IPA description: Dental
/// / Unicode name: Combining bridge below
/// / Unicode hex: `0x32a`
/// / TyIPA name: dental
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let dental(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{32a}")
  }
  modified.join("")
}

/// Apply the 'Laminal' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Subscript square
/// / IPA description: Laminal
/// / Unicode name: Combining square below
/// / Unicode hex: `0x33b`
/// / TyIPA name: laminal
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let laminal(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{33b}")
  }
  modified.join("")
}

/// Apply the 'Linguolabial' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Subscript seagull
/// / IPA description: Linguolabial
/// / Unicode name: Combining seagull below
/// / Unicode hex: `0x33c`
/// / TyIPA name: linguolabial
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let linguolabial(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{33c}")
  }
  modified.join("")
}

/*** Quality diacritics***/

/// Apply the 'Advanced' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Subscript plus
/// / IPA description: Advanced
/// / Unicode name: Combining plus sign below
/// / Unicode hex: `0x31f`
/// / TyIPA name: advanced
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let advanced(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{31f}")
  }
  modified.join("")
}

/// Apply the 'Advanced tongue root (ATR)' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Advancing sign
/// / IPA description: Advanced tongue root (ATR)
/// / Unicode name: Combining left tack below
/// / Unicode hex: `0x318`
/// / TyIPA name: atr
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let atr(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{318}")
  }
  modified.join("")
}

/// Apply the 'Centralized' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Umlaut
/// / IPA description: Centralized
/// / Unicode name: Combining diaeresis
/// / Unicode hex: `0x308`
/// / TyIPA name: centralized
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let centralized(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{308}")
  }
  modified.join("")
}

/// Apply the 'Labialized' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Superscript w
/// / IPA description: Labialized
/// / Unicode name: Modifier letter small w
/// / Unicode hex: `0x2b7`
/// / TyIPA name: labialized
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let labialized(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{2b7}")
  }
  modified.join("")
}

/// Apply the 'Less rounded' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Subscript left half-ring
/// / IPA description: Less rounded
/// / Unicode name: Combining left half ring below
/// / Unicode hex: `0x31c`
/// / TyIPA name: less-rounded
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let less-rounded(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{31c}")
  }
  modified.join("")
}

/// Apply the 'Lowered' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Lowering sign
/// / IPA description: Lowered
/// / Unicode name: Combinign down tack below
/// / Unicode hex: `0x31e`
/// / TyIPA name: lowered
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let lowered(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{31e}")
  }
  modified.join("")
}

/// Apply the 'Mid-centralized' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Over-cross
/// / IPA description: Mid-centralized
/// / Unicode name: Combining x above
/// / Unicode hex: `0x33d`
/// / TyIPA name: mid-centralized
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let mid-centralized(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{33d}")
  }
  modified.join("")
}

/// Apply the 'More rounded' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Subscript right half-ring
/// / IPA description: More rounded
/// / Unicode name: Combining right half ring below
/// / Unicode hex: `0x339`
/// / TyIPA name: more-rounded
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let more-rounded(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{339}")
  }
  modified.join("")
}

/// Apply the 'Nasalized' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Superscript tilde
/// / IPA description: Nasalized
/// / Unicode name: Combining tilde
/// / Unicode hex: `0x303`
/// / TyIPA name: nasalized
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let nasalized(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{303}")
  }
  modified.join("")
}

/// Apply the 'Palatalized' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Superscript j
/// / IPA description: Palatalized
/// / Unicode name: Modifier letter small j
/// / Unicode hex: `0x2b2`
/// / TyIPA name: palatalized
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let palatalized(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{2b2}")
  }
  modified.join("")
}

/// Apply the 'Pharyngealized' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Superscript reversed glottal stop
/// / IPA description: Pharyngealized
/// / Unicode name: Modifer letter small reversed glottal stop
/// / Unicode hex: `0x2e4`
/// / TyIPA name: pharyngealized
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let pharyngealized(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{2e4}")
  }
  modified.join("")
}

/// Apply the 'Raised' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Raising sign
/// / IPA description: Raised
/// / Unicode name: Combining up tack below
/// / Unicode hex: `0x31d`
/// / TyIPA name: raised
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let raised(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{31d}")
  }
  modified.join("")
}

/// Apply the 'Retracted' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Under-bar
/// / IPA description: Retracted
/// / Unicode name: Combining minus sign below
/// / Unicode hex: `0x320`
/// / TyIPA name: retracted
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let retracted(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{320}")
  }
  modified.join("")
}

/// Apply the 'Rhoticity' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Right hook
/// / IPA description: Rhoticity
/// / Unicode name: Modifier letter rhotic hook
/// / Unicode hex: `0x2de`
/// / TyIPA name: rhotic
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let rhotic(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{2de}")
  }
  modified.join("")
}

/// Apply the 'Diacritic retroflexion' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Retroflex hook
/// / IPA description: Diacritic retroflexion
/// / Unicode name: Combining retroflex hook below
/// / Unicode hex: `0x322`
/// / TyIPA name: retroflex
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let retroflex(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{322}")
  }
  modified.join("")
}

/// Apply the 'Retracted tongue root (RTR)' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Retracting sign
/// / IPA description: Retracted tongue root (RTR)
/// / Unicode name: Combining right tack below
/// / Unicode hex: `0x319`
/// / TyIPA name: rtr
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let rtr(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{319}")
  }
  modified.join("")
}

/// Apply the 'Velarized' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Superscript gamma
/// / IPA description: Velarized
/// / Unicode name: Modifier letter small gamma
/// / Unicode hex: `0x2e0`
/// / TyIPA name: velarized
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let velarized(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{2e0}")
  }
  modified.join("")
}

/// Apply the 'Velarized or pharyngealized' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Superimposed tilde
/// / IPA description: Velarized or pharyngealized
/// / Unicode name: Combining tilde overlay
/// / Unicode hex: `0x334`
/// / TyIPA name: velopharyngealized
/// / TyIPA alias(es): dark
/// 
/// -> str
#let velopharyngealized(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{334}")
  }
  modified.join("")
}

/// Alias for `velopharyngealized`.
#let dark = velopharyngealized

/*** Quantity diacritics***/

/// Apply the 'Extra-short' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Breve
/// / IPA description: Extra-short
/// / Unicode name: Combining breve
/// / Unicode hex: `0x306`
/// / TyIPA name: extra-short
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let extra-short(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{306}")
  }
  modified.join("")
}

/// Apply the 'Half-long' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Half-length mark
/// / IPA description: Half-long
/// / Unicode name: Modifier letter half triangular colon
/// / Unicode hex: `0x2d1`
/// / TyIPA name: half-long
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let half-long(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{2d1}")
  }
  modified.join("")
}

/// Apply the 'Long' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Length mark
/// / IPA description: Long
/// / Unicode name: Modifier letter triangular colon
/// / Unicode hex: `0x2d0`
/// / TyIPA name: long
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let long(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{2d0}")
  }
  modified.join("")
}

/*** Release diacritics***/

/// Apply the 'Ejective' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Apostrophe
/// / IPA description: Ejective
/// / Unicode name: Modifier letter apostrophe
/// / Unicode hex: `0x2bc`
/// / TyIPA name: ejective
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let ejective(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{2bc}")
  }
  modified.join("")
}

/// Apply the 'Lateral release' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Superscript l
/// / IPA description: Lateral release
/// / Unicode name: Modifier letter small l
/// / Unicode hex: `0x2e1`
/// / TyIPA name: lateral-release
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let lateral-release(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{2e1}")
  }
  modified.join("")
}

/// Apply the 'Nasal release' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Superscript n
/// / IPA description: Nasal release
/// / Unicode name: Superscript lating small letter n
/// / Unicode hex: `0x207f`
/// / TyIPA name: nasal-release
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let nasal-release(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{207f}")
  }
  modified.join("")
}

/// Apply the 'No audible release' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Corner
/// / IPA description: No audible release
/// / Unicode name: Combining left angle above
/// / Unicode hex: `0x31a`
/// / TyIPA name: no-release
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let no-release(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{31a}")
  }
  modified.join("")
}

/*** Segmentation diacritics***/

/// Apply the 'Tie bar (above)' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Top tie bar
/// / IPA description: Tie bar (above)
/// / Unicode name: Combining double inverted breve
/// / Unicode hex: `0x361`
/// / TyIPA name: tied-above
/// / TyIPA alias(es): tied
/// 
/// -> str
#let tied-above(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  assert(
    type(base) == str,
    message: "tied-above() expects argument of type `str`, `" + str(type(base)) + "` given"
  )
  let parts = base.split("")
  assert(
    parts.len() == 4,
    message: "tied-above() expects argument of length 2, " + str(parts.len() - 2) + " given"
  )
  parts.at(1) + "\u{361}" + parts.at(2)
}

/// Alias for `tied-above`.
#let tied = tied-above

/// Apply the 'Tie bar (below)' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Bottom tie bar
/// / IPA description: Tie bar (below)
/// / Unicode name: Combining double breve below
/// / Unicode hex: `0x35c`
/// / TyIPA name: tied-below
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let tied-below(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  assert(
    type(base) == str,
    message: "tied-below() expects argument of type `str`, `" + str(type(base)) + "` given"
  )
  let parts = base.split("")
  assert(
    parts.len() == 4,
    message: "tied-below() expects argument of length 2, " + str(parts.len() - 2) + " given"
  )
  parts.at(1) + "\u{35c}" + parts.at(2)
}

/*** Syllabicity diacritics***/

/// Apply the 'Non-syllabic' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Subscript arch
/// / IPA description: Non-syllabic
/// / Unicode name: Combining inverted breve below
/// / Unicode hex: `0x32f`
/// / TyIPA name: non-syllabic
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let non-syllabic(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{32f}")
  }
  modified.join("")
}

/// Apply the 'Syllabic' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Syllabicity mark
/// / IPA description: Syllabic
/// / Unicode name: Combining vertical line below
/// / Unicode hex: `0x329`
/// / TyIPA name: syllabic
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let syllabic(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{329}")
  }
  modified.join("")
}

/*** Tone diacritics***/

/// Apply the 'Extra high level tone' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Double acute accent (over)
/// / IPA description: Extra high level tone
/// / Unicode name: Combining adouble acute accent
/// / Unicode hex: `0x30b`
/// / TyIPA name: extra-high
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let extra-high(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{30b}")
  }
  modified.join("")
}

/// Apply the 'Extra low level tone' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Double grave accent (over)
/// / IPA description: Extra low level tone
/// / Unicode name: Combiing double grave accent
/// / Unicode hex: `0x30f`
/// / TyIPA name: extra-low
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let extra-low(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{30f}")
  }
  modified.join("")
}

/// Apply the 'Falling contour tone' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Circumflex
/// / IPA description: Falling contour tone
/// / Unicode name: Combinign circumflex accent
/// / Unicode hex: `0x302`
/// / TyIPA name: falling
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let falling(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{302}")
  }
  modified.join("")
}

/// Apply the 'Falling-rising contour tone' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Acute + grave + acute accent
/// / IPA description: Falling-rising contour tone
/// / Unicode name: Combining acute-grave-acute
/// / Unicode hex: `0x1dc9`
/// / TyIPA name: falling-rising
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let falling-rising(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{1dc9}")
  }
  modified.join("")
}

/// Apply the 'High level tone' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Acute accent (over)
/// / IPA description: High level tone
/// / Unicode name: Combining acute accent
/// / Unicode hex: `0x301`
/// / TyIPA name: high
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let high(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{301}")
  }
  modified.join("")
}

/// Apply the 'High-mid falling contour tone' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Acute accent + macron
/// / IPA description: High-mid falling contour tone
/// / Unicode name: Combining acute-macron
/// / Unicode hex: `0x1dc7`
/// / TyIPA name: high-mid-falling
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let high-mid-falling(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{1dc7}")
  }
  modified.join("")
}

/// Apply the 'High rising contour tone' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Macron + acute accent
/// / IPA description: High rising contour tone
/// / Unicode name: Combining macron-acute
/// / Unicode hex: `0x1dc4`
/// / TyIPA name: high-rising
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let high-rising(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{1dc4}")
  }
  modified.join("")
}

/// Apply the 'Low level tone' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Grave accent (over)
/// / IPA description: Low level tone
/// / Unicode name: Combining grave accent
/// / Unicode hex: `0x300`
/// / TyIPA name: low
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let low(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{300}")
  }
  modified.join("")
}

/// Apply the 'Low rising contour tone' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Grave accent + macron
/// / IPA description: Low rising contour tone
/// / Unicode name: Combining grave-macron
/// / Unicode hex: `0x1dc5`
/// / TyIPA name: low-rising
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let low-rising(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{1dc5}")
  }
  modified.join("")
}

/// Apply the 'Mid level tone' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Macron
/// / IPA description: Mid level tone
/// / Unicode name: Combining macron
/// / Unicode hex: `0x304`
/// / TyIPA name: mid
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let mid(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{304}")
  }
  modified.join("")
}

/// Apply the 'Mid-low falling contour tone' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Macron + grave accent
/// / IPA description: Mid-low falling contour tone
/// / Unicode name: Combining macron-grave
/// / Unicode hex: `0x1dc6`
/// / TyIPA name: mid-low-falling
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let mid-low-falling(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{1dc6}")
  }
  modified.join("")
}

/// Apply the 'Rising contour tone' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Wedge, hacek
/// / IPA description: Rising contour tone
/// / Unicode name: Combiing caron
/// / Unicode hex: `0x30c`
/// / TyIPA name: rising
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let rising(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{30c}")
  }
  modified.join("")
}

/// Apply the 'Rising-falling contour tone' diacritic to `base`.
/// 
/// Adds the following diacritic to `base`:
/// / IPA name: Grave + acute + grave accent
/// / IPA description: Rising-falling contour tone
/// / Unicode name: Combining grave-acute-grave
/// / Unicode hex: `0x1dc8`
/// / TyIPA name: rising-falling
/// / TyIPA alias(es): (none)
/// 
/// -> str
#let rising-falling(
  /// The character(s) to which the diacritic should be added.
  /// -> str | symbol
  base
) = {
  let modified = ()
  for chr in str(base) {
    modified.push(chr + "\u{1dc8}")
  }
  modified.join("")
}

