#let tree-list(
  marker: [├─ ],
  last-marker: [└─ ],
  indent: [│#h(1em)],
  empty-indent: [#h(1.5em)],
  marker-font: "Cascadia Code",
  content,
) = {
  marker = text(font: marker-font, marker)
  last-marker = text(font: marker-font, last-marker)
  indent = text(font: marker-font, indent)
  empty-indent = text(font: marker-font, empty-indent)

  let format(content, __indent: [], __marker: marker) = {
    let body = content.body

    if body.has("children") {
      let iter = body.children.filter(i => i.fields() != (:))

      [#__marker#while (iter.len() > 0) and (not iter.at(0).has("body")) {
        iter.remove(0)
      }\ ]

      if iter.len() == 0 {
        return
      }

      let last = iter.pop()
      for i in iter {
        [#__indent#format(i, __indent: [#__indent#indent])]
      }
      [#__indent#format(last, __indent: [#__indent#empty-indent], __marker: last-marker)]
    } else {
      [#__marker#body\ ]
    }
  }

  let iter = content.children.filter(i => i.fields() != (:))
  let last = iter.pop()

  for i in iter {
    [#format(i, __indent: indent)]
  }
  [#format(last, __indent: empty-indent, __marker: last-marker)]
}
