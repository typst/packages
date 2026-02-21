#let see-it(href, supplement: [it]) = footnote(
  [See #supplement at #link(href, raw(href)).]
)

#let see-impl(href) = see-it(href, supplement: [implementation])
#let see(href) = see-it(href, supplement: [])
#let url(href) = link(href, raw(href))

#let split-str(string) = string.split().map(it => (text(it), [ ])).flatten()

#let split(elem) = {
  if type(elem) == str {
    split-str(elem)
  } else if elem.has("text") {
    split-str(elem.text)
  } else if elem.has("children") {
    elem.children
  } else {
    assert(true, message: "Unexpected element.")
  }
}

/**
 * wrap -- wrap a content one time to fit specific width.
 */
#let wrap(width: none, func: auto, elem) = {
  if width == none {
    return elem
  }

  let func = if func == auto {
    (head, tail) => [#head#tail]
  } else {
    func
  }

  context {
    let seq = split(elem)
    let head = ()
    let tail = seq
    tail = ()
    for (ix, elem) in seq.enumerate() {
      // Trailing spaces do influence geometric size.
      if repr(elem.func()) == "space" {
        head.push(elem)
        continue
      }

      // Measure heading elements and stop looping if width of heading sequence
      // exceeds width limit.
      let shape = measure(head.join() + elem)
      // text(size: 24pt, weight: "regular")[\ #ix #head.len() #shape.width (vs #width)]
      if shape.width > width {
        // text(size: 24pt, weight: "regular")[#shape.width > width]
        tail = seq.slice(ix)
        break
      } else {
        head.push(elem)
      }
    }

    // If there is no split then put all elements to the head sequence
    if head.len() == 0 {
      head = seq
      tail = ()
    }

    // text(size: 16pt, weight: "regular")[lens: #head.len() #tail.len()\ ]
    // text(size: 16pt, weight: "regular")[lens: #head #tail\ ]

    func(head, tail)
  }
}

#let first(head, tail) = head.join()
#let second(head, tail) = tail.join()
#let join-lf(head, tail) = head.join() +[\ ] + tail.join()

/**
 * Utility routine to convert authors (array of content) to authors (array of
 * strings).
 *
 * https://github.com/jgm/pandoc/blob/0e92d9483ce55ca2dc3a7a2d12897ac0e25f4dbd/test/writer.typst
 */
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).at(0)
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}
