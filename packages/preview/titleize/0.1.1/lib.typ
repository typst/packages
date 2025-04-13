#let _plugin = plugin("titleize.wasm")

#let string-to-titlecase(s) = {
  str(_plugin.titlecase(bytes(s)))
}

#let titlecase(body, limit: 4) = {
  show regex(".{" + str(limit) + ",}"): it => string-to-titlecase(it.text)

  body
}