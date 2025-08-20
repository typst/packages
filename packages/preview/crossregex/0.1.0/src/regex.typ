#let regex-plugin = plugin("crossregex.wasm")

// we use a plugin because typst regex does not support back-ref
#let regex-match(re, str) = {
  let r = regex-plugin.regex_match(bytes(re), bytes(str))
  r.at(0) > 0
}
