/// Spine Page
///
/// - info (dictionary): The information to be displayed on the spine page.
/// - fonts (dictionary): The font family to use.
/// - twoside (bool, str): Whether to use two-sided printing.
/// - anonymous (bool): Whether to use anonymous mode.
/// - default-fonts (dictionary): The default font family to use if not specified in fonts
/// - text-font (str): The font family to use for the text on the spine.
/// - text-size (str | length): The font size to use for the text on the spine.
/// -> content
#let spine(
  // from entry
  info: (:),
  fonts: (:),
  twoside: false,
  anonymous: false,
  // options
  default-fonts: (:),
  text-font: "FangSong",
  text-size: "三号",
) = {
  import "../utils/font.typ": _use-fonts, use-size
  import "../utils/util.typ": twoside-pagebreak

  fonts = default-fonts + fonts

  let use-fonts = name => _use-fonts(fonts, name)

  /// Render
  twoside-pagebreak(twoside)

  set page(margin: (x: 1cm, y: 5.4cm))
  set text(font: use-fonts(text-font), size: use-size(text-size))

  place(right + top, {
    show regex("[\p{script=Han}]"): it => box(rotate(it, -90deg))
    rotate(info.title.sum(), 90deg, origin: right + top, reflow: true)
  })

  // Note that the specification does not require the anonymous behavior
  if anonymous { return }

  place(right + bottom, {
    show regex("[\p{script=Han}]"): it => box(rotate(it, -90deg), width: 1cm)
    rotate(info.author, 90deg, origin: right + top, reflow: true)
  })
}
