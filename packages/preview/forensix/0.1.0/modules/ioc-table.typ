// IOC Table Module for Digital Forensics
// Auto-defangs and categorizes Indicators of Compromise

#let mono-fonts = ("DejaVu Sans Mono", "Liberation Mono")

// Defang a string (make URLs/IPs safe)
#let defang(s) = {
  s
    .replace("http://", "hxxp://")
    .replace("https://", "hxxps://")
    .replace("ftp://", "fxp://")
    .replace(".", "[.]")
    .replace("@", "[@]")
}

// Detect IOC type from value
#let detect-ioc-type(value) = {
  // URL patterns
  if value.starts-with("http://") or value.starts-with("https://") or value.starts-with("ftp://") {
    return "URL"
  }

  // Email pattern (contains @ and .)
  if value.contains("@") and value.contains(".") {
    return "Email"
  }

  // IP address pattern (4 groups of digits separated by .)
  let parts = value.split(".")
  if parts.len() == 4 {
    let is-ip = true
    for p in parts {
      // Check if all characters are digits
      if p.len() == 0 or p.len() > 3 {
        is-ip = false
        break
      }
      for c in p {
        if c not in "0123456789" {
          is-ip = false
          break
        }
      }
    }
    if is-ip { return "IPv4" }
  }

  // IPv6 (contains ::)
  if value.contains("::") or (value.contains(":") and value.len() > 15) {
    return "IPv6"
  }

  // Hash detection by length
  let clean = lower(value)
  let hex-chars = "0123456789abcdef"
  let is-hex = true
  for c in clean {
    if c not in hex-chars {
      is-hex = false
      break
    }
  }

  if is-hex {
    if clean.len() == 32 { return "MD5" }
    if clean.len() == 40 { return "SHA1" }
    if clean.len() == 64 { return "SHA256" }
    if clean.len() == 128 { return "SHA512" }
  }

  // Domain (contains . but no protocol)
  if value.contains(".") and not value.contains(" ") {
    return "Domain"
  }

  // Unknown
  "Unknown"
}

/// Renders an IOC table with auto-defanging.
///
/// - title: Optional table title
/// - indicators: Array of IOCs. Each can be:
///   - A string (auto-detect type)
///   - A dictionary with `value` and `type` keys
/// - show-original: Show original value in separate column (default: false)
/// - style: Custom styling options
#let ioc-table(
  title: none,
  indicators: (),
  show-original: false,
  type-header: "Type",
  indicator-header: "Indicator (Defanged)",
  original-header: "Original",
  style: (:),
) = {
  // Default style
  let default-style = (
    font: (size: 9pt, family: mono-fonts),
    title: (size: 12pt, weight: "bold"),
    header: (fill: rgb("#1e3a5f"), text-color: white, weight: "bold"),
    type: (
      url: rgb("#dc2626"),
      ip: rgb("#2563eb"),
      ipv4: rgb("#2563eb"),
      ipv6: rgb("#7c3aed"),
      md5: rgb("#059669"),
      sha1: rgb("#059669"),
      sha256: rgb("#059669"),
      sha512: rgb("#059669"),
      domain: rgb("#d97706"),
      email: rgb("#db2777"),
      unknown: rgb("#6b7280"),
    ),
    row-alt: rgb("#f9fafb"),
  )

  // Merge styles
  let s = default-style
  if "font" in style { s.font = s.font + style.font }
  if "title" in style { s.title = s.title + style.title }
  if "header" in style { s.header = s.header + style.header }
  if "type" in style { s.type = s.type + style.type }

  // Process indicators
  let processed = ()
  for ioc in indicators {
    let value = ""
    let ioc-type = ""

    if type(ioc) == str {
      value = ioc
      ioc-type = detect-ioc-type(ioc)
    } else if type(ioc) == dictionary {
      value = ioc.at("value", default: "")
      ioc-type = ioc.at("type", default: detect-ioc-type(value))
    }

    let defanged = defang(value)

    processed.push((
      original: value,
      defanged: defanged,
      type: ioc-type,
    ))
  }

  // Get type color
  let get-type-color(t) = {
    let key = lower(t)
    if key in s.type { s.type.at(key) } else { s.type.unknown }
  }

  // Build table
  let cols = if show-original { 3 } else { 2 }
  let rows = ()

  // Header
  rows.push(table.cell(fill: s.header.fill, align: center, inset: 10pt, text(
    fill: s.header.text-color,
    weight: s.header.weight,
    size: s.font.size,
  )[#type-header]))
  rows.push(table.cell(fill: s.header.fill, align: left, inset: 10pt, text(
    fill: s.header.text-color,
    weight: s.header.weight,
    size: s.font.size,
  )[#indicator-header]))
  if show-original {
    rows.push(table.cell(fill: s.header.fill, align: left, inset: 10pt, text(
      fill: s.header.text-color,
      weight: s.header.weight,
      size: s.font.size,
    )[#original-header]))
  }

  // Data rows
  for (i, p) in processed.enumerate() {
    let row-fill = if calc.rem(i, 2) == 1 { s.row-alt } else { none }
    let type-color = get-type-color(p.type)

    rows.push(table.cell(fill: row-fill, align: center, inset: 8pt, text(
      size: s.font.size,
      weight: "bold",
      fill: type-color,
    )[#p.type]))
    rows.push(table.cell(fill: row-fill, align: left, inset: 8pt, text(size: s.font.size, font: s.font.family)[#raw(
      p.defanged,
    )]))
    if show-original {
      rows.push(table.cell(fill: row-fill, align: left, inset: 8pt, text(
        size: s.font.size * 0.9,
        fill: rgb("#6b7280"),
        font: s.font.family,
      )[#raw(p.original)]))
    }
  }

  // Render
  {
    if title != none {
      text(size: s.title.size, weight: s.title.weight)[#title]
      v(0.5em)
    }

    let col-widths = if show-original { (auto, 1fr, 1fr) } else { (auto, 1fr) }

    table(
      columns: col-widths,
      stroke: 0.5pt + rgb("#e5e7eb"),
      ..rows
    )
  }
}

// Convenience function for single IOC with manual type
#let ioc(value, type: auto) = {
  if type == auto {
    value
  } else {
    (value: value, type: type)
  }
}
