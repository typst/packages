// Every measurement on the page, derived from a single unit.
//
// `staff-space` is the distance between two string lines. Line weights, stem
// lengths, beam thickness and type sizes are all fractions of it, so changing
// that one value rescales a whole sheet without the proportions drifting.

/// Build a theme.
///
/// Only `staff-space` normally needs setting; the rest are escape hatches for
/// callers who want to depart from the defaults deliberately.
///
/// ```typc
/// theme(staff-space: 3.2mm)
/// ```
#let theme(
  staff-space: 2.9mm,
  font: ("Montserrat", "Noto Sans", "DejaVu Sans"),
  lyric-font: ("Libertinus Serif",),
  color: black,
  faint: luma(90),
  // Draw fret numbers on an opaque patch instead of breaking the string lines.
  // Both hide the line behind the digits; the patch matches the look of the
  // published sheets, breaking the lines also works on a tinted page.
  mask: "gap",
  // "plain" is the bare thick-thin-and-dots repeat sign. "ornate" adds the
  // flared serifs of an engraved one, as published rock tab uses.
  repeat-style: "plain",
) = {
  let sp = staff-space
  assert(mask in ("gap", "box"), message: "theme: mask must be \"gap\" or \"box\"")
  assert(
    repeat-style in ("plain", "ornate"),
    message: "theme: repeat-style must be \"plain\" or \"ornate\"",
  )

  (
    staff-space: sp,
    font: font,
    lyric-font: lyric-font,
    color: color,
    faint: faint,
    mask: mask,
    repeat-style: repeat-style,

    // --- rules ---
    // String lines are hairlines; barlines must read as heavier than them.
    line: 0.075 * sp,
    barline: 0.12 * sp,
    heavy-barline: 0.45 * sp,
    // Clearance on either side of a fret number where the line breaks. Measured
    // off the reference sheets, where the gap hugs the digit closely — a wider
    // one reads as a hole in the staff rather than as room for the number.
    gap-padding: 0.08 * sp,

    // --- rhythm ---
    // Stems hang from the beams down towards the staff.
    stem: 0.09 * sp,
    stem-length: 2.0 * sp,
    beam-thickness: 0.5 * sp,
    beam-gap: 0.32 * sp,
    // Distance from the top string line up to the foot of the stems.
    rhythm-clearance: 0.15 * sp,

    // --- type ---
    fret-size: 1.02 * sp,
    chord-size: 1.15 * sp,
    section-size: 1.3 * sp,
    count-size: 1.0 * sp,
    technique-size: 0.95 * sp,
    bend-size: 0.85 * sp,
    tempo-size: 1.15 * sp,
    title-size: 3.4 * sp,
    credit-size: 1.2 * sp,
    copyright-size: 0.8 * sp,

    // --- horizontal spacing ---
    // Optical rather than proportional: width grows with duration, but far more
    // slowly, so that a whole note does not eat a whole system.
    spacing-exponent: 0.6,
    // Width of a quarter note before justification.
    quarter-width: 3.6 * sp,
    // Never let two events collide, whatever their durations say.
    min-event-gap: 0.55 * sp,
    // Air after the opening barline and before the closing one.
    measure-padding: 0.7 * sp,
    // Room at the start of each system for the vertical TAB mark.
    tab-mark-width: 2.7 * sp,

    // --- vertical spacing ---
    system-gap: 4.0 * sp,
    lane-gap: 0.30 * sp,
  )
}

/// The default theme, used when a caller supplies none.
#let default-theme = theme()
