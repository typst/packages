#let cover(
  // from entry
  info: (:),
  fonts: (:),
  // options
  default-fonts: (:),
  display-version: false,
) = {
  import "../font.typ": _use-fonts
  import "../imports.typ": tntt
  import tntt: space-text, use-size

  let use-fonts = _use-fonts.with(fonts + default-fonts)

  let parse-semver-major(version) = numbering("一", int(version.split(".").at(0)))

  set text(font: use-fonts("SongTi"))

  /// Render the cover page
  // Title
  v(1fr)

  block(width: 100%, align(center, [
    #text(size: use-size("小初"), weight: "bold", spacing: 200%, space-text(info.title.sum()))

    #text(size: use-size("一号"), weight: "regular", info.subtitle)

    #text(size: use-size("三号"), weight: "regular", [（第#parse-semver-major(info.version)版）])
  ]))

  v(3fr)

  // Author
  block(width: 100%, {
    set text(font: use-fonts("FangSong"))

    let author-chunk = range(info.authors.len()).chunks(2)

    for author-pair in author-chunk {
      grid(
        columns: (1fr,) * author-pair.len(), column-gutter: -2em,
        ..author-pair.map(index => align(center)[
          #text(size: use-size("四号"), weight: "bold")[ #info.authors.at(index).name \ ]
          #text(size: use-size("小四"), weight: "regular", link("mailto:" + info.authors.at(index).email))
          #v(1em)
        ])
      )
    }
  })

  v(4fr)

  // Date
  block(width: 100%, text(size: use-size("小四"), align(center, info.date.display("[year] 年 [month] 月 [day] 日"))))

  if display-version {
    block(width: 100%, text(size: use-size("小四"), gray, align(center, [version #info.version])))
  }

  v(1fr)
}
