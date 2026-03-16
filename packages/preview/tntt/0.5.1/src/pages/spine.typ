#let spine(
  // from entry
  info: (:),
  fonts: (:),
  degree: "master",
  twoside: false,
  anonymous: false,
  // options
  default-fonts: (:),
  text-font: "FangSong",
  text-size: "三号",
) = {
  import "../utils/font.typ": _use-fonts, use-size
  import "../utils/util.typ": twoside-pagebreak

  if degree == "bachelor" { return }

  fonts = fonts + default-fonts

  let use-fonts = name => _use-fonts(fonts, name)

  twoside-pagebreak(twoside)

  set page(margin: (x: 1cm, y: 5.4cm))
  set text(font: use-fonts(text-font), size: use-size(text-size))

  place(
    right + top,
    {
      show regex("[\p{script=Han}]"): it => box(rotate(it, -90deg))
      rotate(info.title.sum(), 90deg, origin: right + top, reflow: true)
    },
  )

  // Note that the specification does not require the anonymous behavior
  if anonymous { return }

  place(
    right + bottom,
    {
      show regex("[\p{script=Han}]"): it => box(rotate(it, -90deg), width: 1cm)
      rotate(info.author, 90deg, origin: right + top, reflow: true)
    },
  )
}
