#let _base = "https://orcid.org/"

/// Normalizes input (bare iD or full orcid.org URL) and validates it.
/// Returns the canonical bare iD, e.g. "0000-0002-1825-0097".
#let _normalize(id) = {
  assert(type(id) == str, message: "ORCID must be a string, got " + str(type(id)))

  let id = id.trim().replace(regex("^https?://(www\.)?orcid\.org/"), "").trim("/", at: end).trim()
  id = upper(id)

  assert(
    id.contains(regex("^(?:\d{4}-){3}\d{3}[\dX]$")),
    message: "Invalid ORCID format: \"" + id + "\" (expected 0000-0000-0000-000X)",
  )

  // ISO 7064 mod 11-2 check digit
  let digits = id.replace("-", "")
  let total = 0
  for c in digits.clusters().slice(0, 15) { total = (total + int(c)) * 2 }
  let r = calc.rem(12 - calc.rem(total, 11), 11)
  let expected = if r == 10 { "X" } else { str(r) }
  assert(digits.at(15) == expected, message: "ORCID checksum failed (typo?): " + id)
  id
}

/// The iD as a canonical URL string.
#let orcid-url(id) = _base + _normalize(id)

/// The iD icon alone. Pass `logo` to replace the default icon.
/// `alt` is the alternative text of the default icon (used by accessible PDFs).
#let orcid-icon(size: 1em, baseline: 0.125em, logo: none, alt: "ORCID iD") = box(
  if logo == none { image("assets/images/ORCID_iD.svg", alt: alt) } else { logo },
  width: size,
  height: size,
  baseline: baseline,
)

#let orcid(
  id,
  icon: "before", // "before" | "after" | none
  display: "url", // "url" | "id" | none
  linked: "all", // "all" | "text" | none
  gap: 0.25em,
  size: 1em,
  logo: none, // custom icon content, replaces the default
  alt: "ORCID iD", // alt text of the default icon (accessible PDFs)
) = {
  let icon-options = ("before", "after", none)
  assert(icon in icon-options, message: "icon: " + icon-options.join(", ", last: " or "))

  let display-options = ("url", "id", none)
  assert(display in display-options, message: "display: " + display-options.join(", ", last: " or "))

  let linked-options = ("all", "text", none)
  assert(linked in linked-options, message: "linked: " + linked-options.join(", ", last: " or "))

  assert(icon != none or display != none, message: "nothing to show: icon and display are both none")
  assert(
    not (linked == "text" and display == none),
    message: "linked: \"text\" has nothing to link when display is none; use linked: \"all\"",
  )

  let id = _normalize(id)
  let url = _base + id

  let shown = if display == "url" { url } else if display == "id" { id } else { none }
  if shown != none and linked == "text" { shown = link(url, shown) }

  // The icon always keeps its alt text: Typst forbids marking content inside a link as a PDF artifact, and PDF/UA requires alt text on every image.
  let glyph = if icon == none { none } else { orcid-icon(size: size, logo: logo, alt: alt) }
  let parts = if icon == "after" { (shown, glyph) } else { (glyph, shown) }
  let body = parts.filter(p => p != none).join(h(gap))

  box(if linked == "all" { link(url, body) } else { body })
}
