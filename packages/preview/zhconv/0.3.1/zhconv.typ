#let zhconv-wasm = plugin("./zhconv_typst.wasm")

#let zhconv_str(text, target, wikitext: false) = {
  let wikitext_flag = if wikitext { (1,) } else { (0,) }
  str(zhconv-wasm.zhconv(bytes(text), bytes(target), bytes(wikitext_flag)))
}

#let is_hans_str(text) = {
  zhconv-wasm.is_hans(bytes(text)).at(0) != 0
}

#let zhconv(document, target, wikitext: false) = {
  if type(document) == str {
    zhconv_str(document, target, wikitext: wikitext)
  }
  else if type(document) == content and document.has("children") { // container
    for child in document.children [
      #zhconv(child, target, wikitext: wikitext)
    ]
  }
  else if type(document) == content and document.has("text"){ // typical content
    zhconv(document.text, target, wikitext: wikitext)
  }
  else if type(document) == content and document.has("body"){ // e.g. circle, rect, list
    let args = document.fields()
    let body = zhconv(args.remove("body"), target, wikitext: wikitext)
    document.func()(body, ..args)
  }
  else  {
    document
  }
}
