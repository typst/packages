#import "../utils/font.typ": use-size

#let cover(
  // from entry
  info: (:),
  font: (:),
  // options
  date: datetime.today(),
  display-version: false,
) = {
  /// Auxiliary function to parse the SemVer version and display it as Chinese numbering
  let parse-semver-major(version) = numbering("一", int(version.split(".").at(0)))

  /// Render the cover page
  // Title
  set text(font: font.SongTi)

  v(1fr)

  block(width: 100%)[
    #align(center)[
      #text(
        size: use-size("小初"),
        weight: "bold",
        spacing: 200%,
      )[#info.title.title]

      #text(
        size: use-size("一号"),
        weight: "regular",
      )[#info.title.subtitle]

      #text(
        size: use-size("三号"),
        weight: "regular",
      )[（第#parse-semver-major(info.version)版）]
    ]
  ]

  v(3fr)

  // Author
  set text(font: font.FangSong)

  block(width: 100%)[
    #let author-chunk = range(info.authors.len()).chunks(2)

    #for author-pair in author-chunk {
      grid(
        columns: (1fr,) * author-pair.len(),
        column-gutter: -2em,
        ..author-pair.map(index => align(center)[
          #text(size: use-size("四号"), weight: "bold")[
            #info.authors.at(index).name \
          ]
          #text(size: use-size("小四"), weight: "regular")[
            #link("mailto:" + info.authors.at(index).email)
          ]
          #v(1em)
        ])
      )
    }
  ]

  v(4fr)

  // Date
  set text(font: font.SongTi)

  block(width: 100%, text(size: use-size("小四"), align(center, date.display("[year] 年 [month] 月 [day] 日"))))

  if display-version { block(width: 100%, text(size: use-size("小四"), gray, align(center, [version #info.version]))) }

  v(1fr)
}
