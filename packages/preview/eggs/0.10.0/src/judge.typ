#import "utils.typ": trim-space, is-html, html-style

#let html-pad-judges = state("eggs-html-pad-judges")

/// Typesets the content, then adds negative space
/// of the length of this content.
/// Used to add a judge to the left of a text.
///
/// - j (content): The content to typeset
///
///   *Required*
///
/// -> content
#let judge(
  j
) = context if is-html() {
  context {
    html.elem("span",
      attrs: (
        class: "eggs-judge",
        ..if html-pad-judges.get() {(
          style: html-style(
            position: "absolute",
            transform: "translateX(-100%)"
          )
        )}
      ),
      j
    )
  }
} else {
  [#context(h(-measure(j).width))#j]
}


// given a list of content and a list of judges,
// recursively walk through a list of contents,
// checking if the first child is text and
// is equal to or starts with a judge,
// returning the tail once it is not.
// returns the pair (judge list, tail)
#let parse-judges(children, judges) = {
  if children.len() == 0 {
    return ((), [])
  }
  let head = children.first()
  if (
    type(head) == content and
    head.has("text")
  ) {
    let t = head.text
    let j = judges.find(it => t.starts-with(it))

    if j != none {
      // a judge at the beginning

      let (js, tail) = if t == j {
        // whole child is a judge
        parse-judges(children.slice(1), judges)
      } else {
        // beginning of child is a judge
        parse-judges(
          (text(t.trim(j, at: start)),) + children.slice(1),
          judges
        )
      }
      return ((j,) + js, tail)

    }
  }
  // no judge at the beginning ---
  // stopping and returning as is,
  // trimming initial spaces
  return ((), trim-space(children.join()))
}

// show selected initial characters as corresponding judges
#let format-judges(body, auto-judges: (:)) = {
  // no auto judges or not a text (sequence): skip
  if (
    auto-judges.len() == 0
    or (body.has("children") and body.func() != [\*?].func())
  ) {
    return body
  }
  assert(type(auto-judges) == dictionary, message: "`auto-judges` must be a dictionary")

  let children = body.at("children", default: (body,))
  let (js, tail) = parse-judges(
    // remove initial spaces
    children.slice(children.position(it => it != [ ])),
    auto-judges.keys()
  )

  // print judges (if present)
  if js != () {
    judge(js.map(j => if auto-judges.at(j) {super(j)} else {j}).join())
  }
  tail
}
