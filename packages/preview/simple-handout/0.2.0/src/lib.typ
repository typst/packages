#import "imports.typ": tntt
#import tntt: cuti, use-size

#let define-config(
  info: (:),
  fonts: (:),
  twoside: false,
  bibliography: none,
) = {
  import "font.typ": _use-fonts

  import tntt.exports: *
  import "pages/cover.typ": cover
  import "pages/preface.typ": preface

  if type(info.title) == str { info.title = info.title.split("\n") } else {
    assert(type(info.title) == array, message: "标题（info.title）必须是字符串或字符串数组")
  }

  return (
    /// ------ ///
    /// config ///
    /// ------ ///
    info: info,
    fonts: fonts,
    twoside: twoside,
    /// --------- ///
    /// utilities ///
    /// --------- ///
    use-fonts: _use-fonts.with(fonts),
    /// ------- ///
    /// layouts ///
    /// ------- ///
    meta: meta.with(info: (..info, author: info.authors.map(a => a.name))),
    doc: doc.with(default-fonts: fonts),
    front-matter: front-matter,
    main-matter: main-matter.with(twoside: twoside),
    back-matter: back-matter.with(twoside: twoside),
    /// ----- ///
    /// pages ///
    /// ----- ///
    fonts-display: fonts-display.with(fonts: fonts),
    cover: cover.with(info: info, default-fonts: fonts),
    preface: preface.with(twoside: twoside, default-fonts: fonts),
    outline-wrapper: outline-wrapper.with(twoside: twoside, default-fonts: fonts),
    notation: notation.with(twoside: twoside),
    master-list: master-list.with(twoside: twoside),
    figure-list: figure-list.with(twoside: twoside),
    table-list: table-list.with(twoside: twoside),
    equation-list: equation-list.with(twoside: twoside),
    bilingual-bibliography: bilingual-bibliography.with(bibliography),
  )
}

