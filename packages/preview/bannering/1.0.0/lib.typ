#let banner-plugin = plugin("typst_banners.wasm")
#banner-plugin.init()
#let banner-width = 20
#let banner-height = 40
#let banner(code) = box(image(
  banner-plugin.banner(bytes(code)), 
  format: (encoding: "rgba8", width: banner-width, height: banner-height),
  height: 1em,
  scaling: "pixelated"
))
#let banner-dict(dict) = {
  let ret = dict
  for pair in ret {
    ret.insert(pair.at(0), banner(pair.at(1)))
  }
  return ret
}
#let banners(dict, string, disable-spacing: false) = {
  let ret = []
  let arr = string.matches(regex("([^ \t\r\n]+)|([ \t\r\n]+)"))
  for (i, match) in arr.enumerate() {
    let key = match.text
    if key not in dict {
      ret += [#key]
    }
    else {
      ret += dict.at(key)
    }
  }
  if disable-spacing {
    return ret
  }
  return text(spacing: 0.05em, par(leading: 0.05em, ret))
}
