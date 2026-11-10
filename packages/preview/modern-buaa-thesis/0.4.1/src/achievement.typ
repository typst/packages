#let blind-review-state = state("modern-buaa-thesis-blind-review", false)
#let achievement-author-state = state("modern-buaa-thesis-achievement-author", ())

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

#let achievement-part(value, prefix: [], suffix: []) = {
  if value != none and value != [] and value != "" and value != () {
    [#prefix#value#suffix]
  }
}

#let achievement-name-key(value) = if type(value) == str { lower(value).trim() } else { value }

#let achievement-rank(item, names) = {
  let rank = achievement-value(item, "author-rank", default: none)
  if rank == none {
    let authors = achievement-value(item, "authors", default: ())
    if type(authors) == array {
      let keys = names.map(achievement-name-key)
      let index = authors.position(value => keys.contains(achievement-name-key(value)))
      if index != none {
        rank = index + 1
      }
    }
  }
  if type(rank) != int or rank < 1 {
    panic("盲审成果无法确定申请者排序，请核对 authors 或设置正整数 author-rank。")
  }
  rank
}

#let achievement-names(item, patent: false, suffix: []) = {
  context {
    if blind-review-state.get() {
      let rank = achievement-rank(item, achievement-author-state.get())
      let label = if patent { [排名第#rank] } else { [第#(rank)作者] }
      achievement-part(label, suffix: suffix)
    } else {
      achievement-part(achievement-join(achievement-value(item, "authors", default: ())), suffix: suffix)
    }
  }
}

#let achievement-identifier(value, prefix: [], suffix: []) = {
  context {
    if not blind-review-state.get() {
      achievement-part(value, prefix: prefix, suffix: suffix)
    }
  }
}

#let achievement-papers(items: ()) = {
  heading(level: 2, outlined: false)[学术论文]

  enum(
    numbering: "[1]",
    ..items.map(item => [
      #achievement-names(item, suffix: [. ])
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
      #achievement-names(item, patent: true, suffix: [. ])
      #achievement-part(achievement-value(item, "title"), suffix: [. ])
      #achievement-identifier(achievement-value(item, "patent-no"), prefix: [专利号：], suffix: [. ])
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
      #achievement-part(achievement-value(item, "year"), suffix: [. ])
      #achievement-part(achievement-value(item, "note"))
    ]),
  )
}