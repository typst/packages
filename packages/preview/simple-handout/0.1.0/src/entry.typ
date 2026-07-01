#import "layouts/doc.typ": meta, doc
#import "layouts/front-matter.typ": front-matter
#import "layouts/main-matter.typ": main-matter
#import "layouts/back-matter.typ": back-matter

#import "pages/font-display.typ": font-display
#import "pages/cover.typ": cover

#import "pages/preface.typ": preface
#import "pages/outline-wrapper.typ": outline-wrapper

#import "pages/notation.typ": notation
#import "pages/figure-list.typ": figure-list
#import "pages/table-list.typ": table-list
#import "pages/equation-list.typ": equation-list

#import "utils/font.typ": use-size, _use-font
#import "utils/biliography.typ": bilingual-bibliography

#let define-config(
  font: (:),
  twoside: false,
  bibliography: none,
  info: (
    title: (title: "标 题", subtitle: "副标题"),
    authors: ((name: "作者", email: "mail@example.com"),),
    version: "0.0.0",
  ),
) = {
  return (
    /// ------------- ///
    /// entry options ///
    /// ------------- ///
    twoside: twoside,
    use-font: name => _use-font(font, name),
    info: info,
    font: font,
    /// ------- ///
    /// layouts ///
    /// ------- ///
    // doc layout
    meta: (..args) => meta(
      info: info,
      ..args,
    ),
    // after cover layout
    doc: (..args) => doc(
      ..args,
      font: font + args.named().at("font", default: (:)),
    ),
    // front matter layout
    front-matter: (..args) => front-matter(
      twoside: twoside,
      ..args,
    ),
    // main matter layout
    main-matter: (..args) => main-matter(
      twoside: twoside,
      ..args,
    ),
    // back matter layout
    back-matter: (..args) => back-matter(
      twoside: twoside,
      ..args,
    ),
    /// ----- ///
    /// pages ///
    /// ----- ///
    // font display page
    font-display: (..args) => font-display(
      ..args,
      font: font + args.named().at("font", default: (:)),
    ),
    // cover page
    cover: (..args) => cover(
      info: info,
      ..args,
      font: font + args.named().at("font", default: (:)),
    ),
    // preface page
    preface: (..args) => preface(
      twoside: twoside,
      ..args,
      font: font + args.named().at("font", default: (:)),
    ),
    // outline page
    outline-wrapper: (..args) => outline-wrapper(
      twoside: twoside,
      ..args,
      font: font + args.named().at("font", default: (:)),
    ),
    // notation page
    notation: (..args) => notation(
      twoside: twoside,
      ..args,
    ),
    // figure list page
    figure-list: (..args) => figure-list(
      twoside: twoside,
      ..args,
    ),
    // table list page
    table-list: (..args) => table-list(
      twoside: twoside,
      ..args,
    ),
    // equation list page
    equation-list: (..args) => equation-list(
      twoside: twoside,
      ..args,
    ),
    // bilingual bibliography
    bilingual-bibliography: (..args) => bilingual-bibliography(
      bibliography: bibliography,
      ..args,
    ),
  )
}
