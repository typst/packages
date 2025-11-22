
#let _typst-link = link

#let _ccicon-formats = (
  icon: (
    "by",
    "cc",
    "logo",
    "nc",
    "nceu",
    "ncjp",
    "nd",
    "pd",
    "remix",
    "sa",
    "sampling",
    "sampling.plus",
    "share",
    "zero",
  ),
  shield: (
    "cc-by-nc-nd",
    "cc-by-nc-sa",
    "cc-by-nc",
    "cc-by-nd",
    "cc-by-sa",
    "cc-by",
    "cc-pd",
    "cc-zero",
  ),
  badge: (
    "cc-by-nc-nd",
    "cc-by-nc-sa",
    "cc-by-nc",
    "cc-by-nceu",
    "cc-by-nceu-nd",
    "cc-by-nceu-sa",
    "cc-by-nd",
    "cc-by-sa",
    "cc-by",
    "cc-pd",
    "cc-zero",
  ),
)
#let _ccicon-aliases = (
  cc-logo: "logo",
  cc-by-nc-sa-eu: "cc-by-nceu-sa",
  cc-by-nc-sa-jp: "cc-by-ncjp-sa",
  cc-by-nc-nd-eu: "cc-by-nceu-sa",
  cc-by-nc-nd-jp: "cc-by-ncjp-sa",
  publicdomain: "pd",
  public-domain: "pd",
  ccbysa: "cc-by-sa",
  ccbynd: "cc-by-nd",
  ccbync: "cc-by-nc",
  ccbyncsa: "cc-by-nc-sa",
  ccbyncnd: "cc-by-nc-nd",
  ccbynceusa: "cc-by-nceu-sa",
  ccbyncjpsa: "cc-by-ncjp-sa",
  ccbyncsaeu: "cc-by-nceu-sa",
  ccbyncsajp: "cc-by-ncjp-sa",
  ccbynceund: "cc-by-nceu-nd",
  ccbyncjpnd: "cc-by-ncjp-nd",
  ccbyncndeu: "cc-by-nceu-nd",
  ccbyncndjp: "cc-by-ncjp-nd",
)
#let _ccicon-all-keys = _ccicon-formats.icon + _ccicon-formats.shield + _ccicon-formats.badge
_ccicon-all-keys = _ccicon-all-keys.dedup()

#let _cc-colorize(icon-file, fill: black, ..args) = {
  let svg-data = read(icon-file)
  svg-data = svg-data.replace("<path", "<path style=\"fill:" + fill.to-hex() + "\"").replace(
    "<polygon",
    "<polygon style=\"fill:" + fill.to-hex() + "\"",
  )
  return image.decode(..args.named(), svg-data)
}

#let _cc-resolve-name(name) = {
  let parts = name.split("/")
  let resolved = (
    parts.first(),
    "icon",
    if parts.len() > 1 {
      parts.slice(1).join("/")
    } else {
      ""
    },
  )

  parts = resolved.first().split("-")
  if parts.last() in ("shield", "badge") {
    resolved.at(1) = parts.pop()
    resolved.at(0) = parts.join("-")
  }

  resolved.at(0) = _ccicon-aliases.at(resolved.at(0), default: resolved.at(0))

  return resolved
}

#let _cc-parse(name) = {
  let cc-info = (
    license: "",
    parts: (),
    version: "4.0",
    lang: "en",
    format: "icon",
  )

  let (name, format, version) = _cc-resolve-name(name)

  cc-info.license = name
  cc-info.parts = name.split("-")
  cc-info.format = format

  let parts = version.split("/")
  while parts.len() > 1 {
    if parts.last().position(regex("\d\.\d")) != none {
      cc-info.version = parts.pop()
    } else {
      cc-info.lang = parts.pop()
    }
  }

  return cc-info
}

#let cc-is-valid(name) = {
  let (name, fmt, _) = _cc-resolve-name(name)
  if fmt == "icon" {
    return name in _ccicon-all-keys
  } else {
    return name in _ccicon-formats.at(fmt)
  }
}

#let cc-url(name) = {
  let base = "https://creativecommons.org/licenses/"

  let cc-info = _cc-parse(name)
  if cc-info.parts.first() == "cc" {
    let _ = cc-info.parts.remove(0)
  }

  let url = base + cc-info.parts.join("-") + "/" + cc-info.version
  if cc-info.lang not in (auto, "en") {
    url += "/deed." + cc-info.lang
  }
  return url
}

#let cc-icon(name, scale: 1.0, baseline: 5%, format: auto, link: false, fill: auto) = {
  let cc-info = _cc-parse(name)

  if format in ("icon", "badge", "shield") {
    cc-info.format = format
  }

  let icon
  if cc-info.format == "icon" {
    icon = cc-info.parts.map(name => box(context _cc-colorize(
      height: .75em * scale,
      "assets/svg/icon/" + name + ".svg",
      fill: if fill == auto {
        text.fill
      } else {
        fill
      },
    ))).join(
      h(1.5pt),
    )
  } else {
    if not cc-info.license.starts-with("cc") {
      cc-info.license = "cc-" + cc-info.license
    }
    icon = image(height: .75em * scale, "assets/svg/" + cc-info.format + "/" + cc-info.license + ".svg")
  }

  // TODO: Only generate links, if a license page is available
  if link != false {
    _typst-link(cc-url(name), box(baseline: baseline, icon))
  } else {
    box(baseline: baseline, icon)
  }
}
#let ccicon = cc-icon
