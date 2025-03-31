/* Note: some of the code here is adapted from Touying's codebase
 * The original license is available at https://github.com/touying-typ/touying/tree/main. 
 */

#let t2sdefaults(
  duration-physical: 2,
  transition: "fade",
  transition-duration: 0,
) = {
  [ #metadata((t: "T2sdefaults", v: (
    duration_physical: duration-physical,
    transition: transition,
    transition_duration: transition-duration,
  ))) <pdfpc> ]
}

#let markup-text(it, indent: 0) = {
  // Adapted from touying
  let indent-markup-text = markup-text.with(indent: indent + 2)
  let markup-text = markup-text.with(indent: indent)
  if type(it) == str {
    it
  } else if type(it) == content {
    if it.func() == raw {
      if it.block {
        (
          "\n"
            + indent * " "
            + "```"
            + it.lang
            + it.text.split("\n").map(l => "\n" + indent * " " + l).sum(default: "")
            + "\n"
            + indent * " "
            + "```"
        )
      } else {
        "`" + it.text + "`"
      }
    } else if it == [ ] {
      " "
    } else if it.func() == enum.item {
      "\n" + indent * " " + "+ " + indent-markup-text(it.body)
    } else if it.func() == list.item {
      "\n" + indent * " " + "- " + indent-markup-text(it.body)
    } else if it.func() == terms.item {
      "\n" + indent * " " + "/ " + markup-text(it.term) + ": " + indent-markup-text(it.description)
    } else if it.func() == linebreak {
      "\n" + indent * " "
    } else if it.func() == parbreak {
      "\n\n" + indent * " "
    } else if it.func() == strong {
      markup-text(it.body)
    } else if it.func() == emph {
      markup-text(it.body)
    } else if it.func() == link and type(it.dest) == str {
      markup-text(it.body)
    } else if it.func() == heading {
      markup-text(it.body)
    } else if it.has("children") {
      it.children.map(markup-text).join()
    } else if it.has("body") {
      markup-text(it.body)
    } else if it.has("text") {
      if type(it.text) == str {
        it.text
      } else {
        markup-text(it.text)
      }
    } else if it.func() == smartquote {
      if it.double {
        "\""
      } else {
        "'"
      }
    } else {
      ""
    }
  } else {
    repr(it)
  }
}

#let t2s(start-from: -1, body) = {
  /*
  let body = if type(body) == str {
    body
  } else if type(body) == content and body.func() == raw {
    body.text.trim()
  } else if type(body) == content and body.func() == text {
    body.text.trim()
  } else {
    panic("A note must either be a string or a raw block, got " + str(type(body)))
  }
  */
  let body = if type(body) == str {
    body
  } else if type(body) == content and body.func() == raw {
    body.text.trim()
  } else if type(body) == content and body.func() == text {
    body.text.trim()
  } else {
    markup-text(body)
  }
  [ #metadata((t: "T2s", v: (start_from: start-from, body: body))) <pdfpc> ]
}

// label: section number
// index: pdfpage count
// overlay: slide number in a logical slide

#let duration(logical: -1, physical: ()) = {
  if logical > 0 {
    [ #metadata((t: "T2s-duration-logical", v: logical)) <pdfpc> ]
  } else if physical.len() > 0 {
    [ #metadata((t: "T2s-duration-physical", v: physical)) <pdfpc> ]
  } else {
    // panic("either physical or logical duration must be provided")
  }
}

#let video-overlay(
  start-from: -1,
  video: "", x: 0, y: 0, width: -1, height: -1,
  reverse: false,
) = {
  [ #metadata((t: "T2s-video-overlay", v: (
    start_from: start-from,
    video: video,
    x: x,
    y: y,
    width: width,
    height: height,
    reverse: reverse,
  ))) <pdfpc> ]
}

#let t2s-file(loc) = {
  let arr = query(<pdfpc>).map(it => it.value)
  let (config, ..slides) = arr.split((t: "NewSlide"))
  let pdfpc = (
    pdfpcFormat: 2,
    disableMarkdown: false,
  )
  for item in config {
    pdfpc.insert(lower(item.t.at(0)) + item.t.slice(1), item.v)
  }
  let pages = ()
  for slide in slides {
    let page = (
      idx: 0,
      label: 1,
      overlay: 0,
      forcedOverlay: false,
      hidden: false,
      t2s: (),
    )
    for item in slide {
      if item.t == "Idx" {
        page.idx = item.v
      } else if item.t == "LogicalSlide" {
        page.label = str(item.v)
      } else if item.t == "Overlay" {
        page.overlay = item.v
        page.forcedOverlay = item.v > 0
      } else if item.t == "HiddenSlide" {
        page.hidden = true
      } else if item.t == "SaveSlide" {
        if "savedSlide" not in pdfpc {
          pdfpc.savedSlide = page.label - 1
        }
      } else if item.t == "EndSlide" {
        if "endSlide" not in pdfpc {
          pdfpc.endSlide = page.label - 1
        }
      } else if item.t == "Note" {
        page.note = item.v
      } else if item.t.starts-with("T2s") {
        page.t2s.push(item)
      } else {
        pdfpc.insert(lower(item.t.at(0)) + item.t.slice(1), item.v)
      }
    }
    pages.push(page)
  }
  pdfpc.insert("pages", pages)
  [#metadata(pdfpc)<t2s-file>]
}

