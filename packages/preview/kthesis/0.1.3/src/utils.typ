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
#let content-to-string(it, mode: "plain") = {
  assert(mode == "plain" or mode == "html", message: "mode must be 'plain' or 'html'")
  let content-to-string = content-to-string.with(mode: mode)

  let escape-body = body => {
    if mode == "html" {
      body.replace("<", "&lt;").replace(">", "&gt;")
    } else {
      body
    }
  }

  let tag-or-plain = (tag, body, attrs: none) => {
    if mode == "html" {
      let attrs = if attrs != none {
        " " + attrs
      } else {
        ""
      }
      "<" + tag + attrs + ">" + body + "</" + tag + ">"
    } else {
      body
    }
  }

  if type(it) == str {
    escape-body(it)
  } else if type(it) == content {
    if it.func() == raw {
      if it.block {
        tag-or-plain("pre", it.text)
      } else {
        tag-or-plain("code", it.text)
      }
    } else if it == [ ] {
      " "
    } else if it.func() == linebreak {
      if mode == "html" {
        "<br>"
      } else {
        "\n"
      }
    } else if it.func() == parbreak {
      if mode == "html" {
        "</p><p>"
      } else {
        "\n\n"
      }
    } else if it.func() == smartquote {
      if it.double {
        "\""
      } else {
        "'"
      }
    } else if it.func() == strong {
      tag-or-plain("strong", content-to-string(it.body))
    } else if it.func() == emph {
      tag-or-plain("i", content-to-string(it.body))
    } else if it.func() == super {
      tag-or-plain("sup", content-to-string(it.body))
    } else if it.func() == sub {
      tag-or-plain("sub", content-to-string(it.body))
    } else if it.func() == link and type(it.dest) == str {
      if mode == "html" {
        tag-or-plain("a", content-to-string(it.body), attrs: "href='" + it.dest + "'")
      } else {
        it.body
      }
    } else if it.func() == heading {
      tag-or-plain("h" + str(it.depth), content-to-string(it.body))
    } else if it.has("child") {
      content-to-string(it.child)
    } else if it.has("children") {
      it.children.map(content-to-string).join()
    } else if it.has("body") {
      content-to-string(it.body)
    } else if it.has("text") {
      if type(it.text) == str {
        escape-body(it.text)
      } else {
        content-to-string(it.text)
      }
    } else {
      panic("Cannot serialize content: " + json.encode(it))
    }
  } else {
    panic("Cannot serialize object: " + json.encode(it))
  }
}

#let content-to-html(content) = {
  // trim empty paragraphs
  let html = content-to-string(content, mode: "html")
    .replace(regex("^(</p><p>)+"), "")
    .replace(regex("(</p><p>)+$"), "")

  "<p>" + html.trim() + "</p>"
}
