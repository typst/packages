#let blind-review-state = state("modern-buaa-thesis-blind-review", false)

#let achievement-value(item, key, default: []) = item.at(key, default: default)

#let achievement-join(values, sep: [，]) = {
  if values == none or values == [] or values == () {
    []
  } else if type(values) == array {
    for (i, value) in values.enumerate() {
      if i > 0 {
        sep
      }
      value
    }
  } else {
    values
  }
}

#let achievement-names(values) = {
  context {
    if blind-review-state.get() {
      box(width: 6em, height: 0.9em, fill: black)
    } else {
      achievement-join(values)
    }
  }
}

#let achievement-part(value, prefix: [], suffix: []) = {
  if value != none and value != [] and value != "" and value != () {
    [#prefix#value#suffix]
  }
}

#let achievement-papers(items: ()) = {
  heading(level: 2, outlined: false)[学术论文]

  enum(
    numbering: "[1]",
    ..items.map(item => [
      #achievement-part(achievement-names(achievement-value(item, "authors", default: ())), suffix: [. ])
      #achievement-part(achievement-value(item, "title"), suffix: [. ])
      #achievement-part(achievement-value(item, "venue"), suffix: [. ])
      #achievement-part(achievement-value(item, "year"), suffix: [. ])
      #achievement-part(achievement-value(item, "note"))
    ]),
  )
}

#let achievement-patents(items: ()) = {
  heading(level: 2, outlined: false)[发明专利]

  enum(
    numbering: "[1]",
    ..items.map(item => [
      #achievement-part(achievement-names(achievement-value(item, "authors", default: ())), suffix: [. ])
      #achievement-part(achievement-value(item, "title"), suffix: [. ])
      #achievement-part(achievement-value(item, "patent-no"), prefix: [专利号：], suffix: [. ])
      #achievement-part(achievement-value(item, "year"), suffix: [. ])
      #achievement-part(achievement-value(item, "note"))
    ]),
  )
}

#let achievement-projects(items: ()) = {
  heading(level: 2, outlined: false)[参与的科研项目]

  enum(
    numbering: "[1]",
    ..items.map(item => [
      #achievement-part(achievement-value(item, "title"), suffix: [. ])
      #achievement-part(
        achievement-names(achievement-value(
          item,
          "members",
          default: achievement-value(item, "participants", default: ()),
        )),
        prefix: [参与人：],
        suffix: [. ],
      )
      #achievement-part(achievement-value(item, "year"), suffix: [. ])
      #achievement-part(achievement-value(item, "note"))
    ]),
  )
}
