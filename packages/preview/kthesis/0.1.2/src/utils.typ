#import "@preview/linguify:0.4.2": linguify

#let kth-blue = rgb("#004791")
#let kth-navy = rgb("#000061")

#let lang-db = toml("./lang.toml")

#let t = key => linguify(key, from: lang-db)

#let get-one-liner(lang, info) = {
  let title = info.at("title")
  let subtitle = info.at("subtitle")

  if subtitle == none {
    return title
  }

  // I don't really understand why this is the intended behavior either...
  if lang == "sv" {
    title + " - " + subtitle
  } else {
    title + ": " + subtitle
  }
}

#let extract-name(person) = {
  return person.at("first-name") + " " + person.at("last-names")
}

#let join-names(names) = {
  return names.join(", ", last: t("separator-last"))
}

#let omit-dict-none(d) = {
  return d.pairs().filter(((_, v)) => v != none).to-dict()
}

// This function most definitely should not exist, but alas...
#let content-to-newline-aware-html(content) = {
  if content.func() == text {
    content.at("text").replace("<", "&lt;").replace(">", "&gt;")
  } else if content.has("children") {
    content.at("children").map(content-to-newline-aware-html).join("").trim()
  } else if content == [ ] {
    " "
  } else if content.func() == linebreak {
    "\n"
  } else if content.func() == parbreak {
    "\n\n"
  } else if content.func() == smartquote {
    if content.at("double") {
      "\""
    } else {
      "'"
    }
  } else {
    let tag = if content.func() == emph {
      "i"
    } else if content.func() == strong {
      "strong"
    } else if content.func() == super {
      "sup"
    } else if content.func() == sub {
      "sub"
    } else {
      panic("Cannot serialize content: " + json.encode(content))
    }

    let body = content-to-newline-aware-html(content.at("body")).trim()

    "<" + tag + ">" + body + "</" + tag + ">"
  }
}

#let content-to-html(content) = {
  // ensure conversion from string to content, if needed
  let newline-aware = content-to-newline-aware-html([#content])

  let with-breaks = newline-aware.replace("\n\n", "<br>")

  "<p>" + with-breaks.replace("\n", "</p><p>") + "</p>"
}
