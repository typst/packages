// Front page: the UCPH publication header plus the thesis title block.
//
// The header follows "Placement of logo on publications" from the official
// logo sheet (KU_CMYK.pdf): logotype top left, seal top right, a large dot
// down-left of the seal, and a full-width rule with a small dot centred under
// the seal. All proportions below are measured from that sheet and expressed
// relative to the seal diameter, so the header scales as one unit.

#import "colors.typ" as colors
#import "logos.typ" as uc-logos
#import "i18n.typ" as i18n
#import "utils.typ" as utils

// Geometry, measured from the official sheet, in units of seal diameter.
#let _geo = (
  wordmark-to-seal: 3.922, // width of the EN logotype / seal diameter
  seal-drop: 0.295,        // seal top below logotype top
  big-dot: 0.475,          // diameter of the large dot
  big-dot-dx: -0.6095,     // large dot centre, from seal centre
  big-dot-dy: 0.7305,
  rule-dy: 1.2385,         // rule centre line, from seal centre
  small-dot: 0.248,        // diameter of the small dot (centred on the rule)
  rule: 0.0094,            // rule thickness
)

/// The UCPH publication header, placed absolutely at the top of the page.
///
/// - lang (str): "en" or "da"; picks the logotype.
/// - lines (array): extra lines under the logotype (faculty, department).
/// - seal (length): seal diameter. 24mm on A4 matches the official sheet.
/// - margin (length): distance from the page edges to logotype and seal.
/// - offset (length): distance from the top edge to the logotype.
#let ucph-header(
  lang: "en",
  lines: (),
  seal: 24mm,
  margin: 20mm,
  offset: 15mm,
  color: colors.red,
  text-color: colors.logotype-grey,
) = {
  let d = seal
  let wm = if lang == "da" { "wordmark-da" } else { "wordmark-en" }
  // keep DA and EN glyphs at the same scale: scale from the EN width
  let scale = _geo.wordmark-to-seal * d / uc-logos.natural-size("wordmark-en").first()
  let wm-width = uc-logos.natural-size(wm).first() * scale
  let wm-height = uc-logos.natural-size(wm).last() * scale

  // logotype and faculty/department lines
  place(top + left, dx: margin, dy: offset, {
    uc-logos.logo(wm, width: wm-width)
    // faculty/department in letterspaced capitals, subordinate to the logotype
    set text(fill: text-color, size: wm-height, tracking: 0.16em)
    set par(leading: 0.6em)
    let lines = lines.filter(l => l != none)
    if lines.len() > 0 {
      v(0.5 * wm-height)
      lines.map(upper).join(linebreak())
    }
  })

  // seal, dots and rule, positioned from the seal centre
  context {
    let w = page.width
    let cx = w - margin - d / 2
    let cy = offset + _geo.seal-drop * d + d / 2
    place(top + left, dx: cx - d / 2, dy: cy - d / 2, uc-logos.logo("seal", width: d))
    let bd = _geo.big-dot * d
    place(top + left, dx: cx + _geo.big-dot-dx * d - bd / 2, dy: cy + _geo.big-dot-dy * d - bd / 2,
      circle(radius: bd / 2, fill: color, stroke: none))
    let ry = cy + _geo.rule-dy * d
    let th = _geo.rule * d
    place(top + left, dx: 0pt, dy: ry - th / 2, rect(width: w, height: th, fill: color, stroke: none))
    let sd = _geo.small-dot * d
    place(top + left, dx: cx - sd / 2, dy: ry - sd / 2, circle(radius: sd / 2, fill: color, stroke: none))
  }
}

/// Vertical position of the rule, for laying out content beneath the header.
#let header-rule-y(seal: 24mm, offset: 15mm) = offset + _geo.seal-drop * seal + seal / 2 + _geo.rule-dy * seal

/// The complete front page.
#let front-page(
  lang: "en",
  type: none,
  title: none,
  subtitle: none,
  authors: (),
  advisors: (),
  date: none,
  faculty: none,
  department: none,
  cover-image: none,
  heading-font: (),
  margin: 20mm,
) = page(
  margin: 0pt,
  header: none,
  footer: none,
  numbering: none,
  {
    ucph-header(lang: lang, lines: (faculty, department), margin: margin)

    let rule-y = header-rule-y()
    set text(font: heading-font, fill: black)
    set par(justify: false, leading: 0.45em)

    // optional cover image, between the rule and the title block
    if cover-image != none {
      place(top + left, dx: margin, dy: rule-y + 16mm, box(
        width: 100% - 2 * margin,
        height: 80mm,
        clip: true,
        align(left + horizon, {
          set image(height: 80mm, fit: "contain")
          cover-image
        }),
      ))
    }

    // title block
    place(top + left, dx: margin, dy: 182mm, block(width: 100% - 2 * margin - 10mm, {
      if type != none {
        text(size: 12pt, weight: "bold", fill: colors.red, tracking: 0.08em, upper(type))
        v(5mm)
      }
      if title != none {
        text(size: 24pt, weight: "bold", hyphenate: false, title)
      }
      if subtitle != none {
        v(3mm)
        text(size: 15pt, subtitle)
      }
      let names = utils.as-array(authors)
      if names.len() > 0 {
        v(8mm)
        set text(size: 13pt)
        for (i, a) in names.enumerate() {
          if i > 0 { linebreak() }
          utils.person-name(a)
          let id = utils.person-detail(a)
          if id != none { text(fill: colors.logotype-grey, size: 10pt, h(0.6em) + id) }
        }
      }
      v(10mm)
      set text(size: 10.5pt, fill: colors.ucph-dark.grey)
      set par(leading: 0.6em)
      let advs = utils.as-array(advisors)
      if advs.len() > 0 {
        let key = if advs.len() > 1 { "advisors" } else { "advisor" }
        i18n.t(lang, key) + ": " + advs.map(utils.person-name).join(", ", last: if lang == "da" { " og " } else { " and " })
        linebreak()
      }
      if date != none {
        i18n.t(lang, "submitted") + ": " + i18n.format-date(lang, date)
      }
    }))
  },
)
