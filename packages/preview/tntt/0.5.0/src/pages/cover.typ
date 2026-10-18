/// Convert a date to a Chinese date string, using Chinese numerals for the year and month
///
/// This is not designed to be a general date formatting function
///
/// - date: The date to convert
/// -> str
#let _display-zh(date) = {
  let date-map = (
    "0": "○",
    "1": "一",
    "2": "二",
    "3": "三",
    "4": "四",
    "5": "五",
    "6": "六",
    "7": "七",
    "8": "八",
    "9": "九",
    "10": "十",
    "11": "十一",
    "12": "十二",
  )

  str(date.year()).clusters().map(c => date-map.at(c)).sum() + "年" + date-map.at(str(date.month())) + "月"
}

/// Cover Page
///
/// - anonymous (bool): Whether to use anonymous mode.
/// - fonts (dictionary): The font family to use.
/// - info (dictionary): The information to be displayed on the cover page.
/// - degree (str): The degree.
/// - degree-type (str): The type of degree.
/// - default-fonts (dictionary): The default font family to use if not specified in fonts.
/// - doc-info (dictionary): The document information to extend the info with.
/// - content (list): Custom content to be used instead of the preset content.
/// - info-items (dictionary): The items to be displayed in the info section, mapping keys to their display names.
/// - info-item-width (length, auto, none): The width of the info item labels. If `auto`, a default width is used based on the degree type.
/// -> content
#let cover(
  // from entry
  anonymous: false,
  fonts: (:),
  info: (:),
  degree: "bachelor",
  degree-type: "academic",
  // options
  default-fonts: (:),
  doc-info: (:),
  content: [],
  info-items: (:),
  info-item-width: none,
) = {
  import "../utils/font.typ": _use-cjk-fonts, _use-fonts, use-size
  import "../utils/text.typ": distr-text, fixed-text, space-text
  import "../utils/util.typ": is-not-empty

  info = info + doc-info
  fonts = fonts + default-fonts

  let use-fonts = name => _use-fonts(fonts, name)
  let use-cjk-fonts = name => _use-cjk-fonts(fonts, name)
  let use-anonymous = width => block(width: width, fill: black, "", outset: (y: 2pt))

  // @typstyle off
  let preset-info-items = (
    bachelor: (department: "系别", major: "专业", author: "姓名", supervisor: "指导教师"),
    graduate: (department: "培养单位", major: "学科", author: "研究生", supervisor: "指导教师", co-supervisor: "联合指导教师"),
  )

  if info-items == (:) {
    info-items = if degree == "bachelor" { preset-info-items.bachelor } else { preset-info-items.graduate }
  }

  assert(
    info-items.keys().all(k => k in info),
    message: "Required info-items for info:" + info-items.keys().filter(k => k not in info).join(", "),
  )

  // Calculate suitable width of info items
  info-item-width = if info-item-width == none { if degree == "bachelor" { 4em } else { 5em } } else if (
    info-item-width == auto
  ) { calc.max(info-items.values().map(v => v.clusters().len())) * 1em } else { info-item-width }
  let format-info-item(it) = block(
    width: info-item-width + if degree == "bachelor" { 0em } else { 0.5em },
    fixed-text(it, info-item-width) + if degree == "bachelor" { "" } else { " " },
  )

  info.supervisor = info.supervisor.chunks(2)
  if degree != "bachelor" { info.co-supervisor = info.co-supervisor.chunks(2) }

  // Calculate suitable width of supervisor
  let supervisor-width = {
    let name-width = calc.max(
      info.author.clusters().len(),
      ..info.supervisor.map(p => p.first().clusters().len()),
      ..if degree != "bachelor" { info.co-supervisor.map(p => p.first().clusters().len()) },
    )
    let post-width = calc.max(
      ..info.supervisor.map(p => p.last().clusters().len()),
      ..if degree != "bachelor" { info.co-supervisor.map(p => p.last().clusters().len()) },
    )

    if name-width <= 3 and post-width >= 4 { (3em, (post-width + 1) * 1em) } else {
      (calc.max(4, name-width) * 1em, calc.max(4, post-width + 1) * 1em)
    }
  }

  // TODO: add pretty formatting
  info.author = if anonymous { use-anonymous(4em) } else {
    block(fixed-text(info.author, supervisor-width.first()), width: supervisor-width.first())
  }

  let format-supervisor(arr) = arr
    .intersperse("")
    .map(p => if p == "" { ("", "") } else {
      if anonymous { use-anonymous(8em) } else {
        block(
          fixed-text(p.first(), supervisor-width.first()) + fixed-text("　" + p.last(), supervisor-width.last()),
          width: supervisor-width.sum(),
        )
      }
    })
  info.supervisor = format-supervisor(info.supervisor)

  if degree != "bachelor" { info.co-supervisor = format-supervisor(info.co-supervisor) }

  let placed-content(content, dy) = place(bottom + center, content, dy: dy)
  let format-info(items) = grid(
    align: (center, left, left), rows: 1.09cm, columns: (2.80cm, 0.82cm, 5.62cm),
    ..items.keys().map(k => (format-info-item(items.at(k)), "：", info.at(k))).flatten()
  )

  let preset-content = (
    bachelor: {
      set page(margin: (top: 3.8cm, bottom: 3.2cm, x: 3cm))
      v(2em)
      image("../assets/logo.png", width: 7.81cm)
      v(-1em)
      text(size: use-size("小初"), font: use-fonts("HeiTi"), weight: "bold", space-text("综合论文训练"))
      v(1em)
      {
        set par(leading: 0.95em)
        text(size: use-size("一号"), font: use-fonts("HeiTi"), info.title.join("\n"))
      }
      placed-content(text(size: use-size("三号"), font: use-cjk-fonts("FangSong"), format-info(info-items)), -17em)
      placed-content(text(size: use-size("三号"), font: use-cjk-fonts("SongTi"), _display-zh(info.date)), -5em)
    },
    graduate: {
      set page(margin: (x: 4cm, y: 6cm))
      set par(leading: 1.15em, spacing: 1.3em)
      v(1.2em)
      text(size: use-size("一号"), font: use-fonts("HeiTi"), info.title.join("\n"))
      parbreak()
      text(size: use-size("小二"), font: use-fonts("SongTi"), [（申请清华大学#info.degree-name;学位论文）])
      placed-content(text(size: use-size("三号"), font: use-cjk-fonts("FangSong"), format-info(info-items)), -7.5em)
      placed-content(text(size: use-size("三号"), font: use-cjk-fonts("SongTi"), _display-zh(info.date)), -0.9em)
    },
  )

  /// Render cover page
  set align(center)

  if is-not-empty(content) { content } else {
    if degree == "bachelor" { preset-content.bachelor } else { preset-content.graduate }
  }
}

/// English Cover Page
///
/// - anonymous (bool): Whether to use anonymous mode.
/// - fonts (dictionary): The font family to use.
/// - info (dictionary): The information to be displayed on the cover page.
/// - degree (str): The degree.
/// - degree-type (str): The type of degree.
/// - twoside (bool, str): Whether to use two-sided printing.
/// - default-fonts (dictionary): The default font family to use if not specified in fonts
/// - doc-info (dictionary): The document information to extend the info with.
/// - info-items (dictionary): The items to be displayed in the info section, mapping keys to their display names.
/// -> content
#let cover-en(
  // from entry
  anonymous: false,
  fonts: (:),
  info: (:),
  degree: "master",
  degree-type: "academic",
  twoside: false,
  // options
  default-fonts: (:),
  doc-info: (:),
  info-items: (supervisor: "Thesis Supervisor", co-supervisor: "Associate Supervisor"),
) = {
  if degree == "bachelor" { return }

  import "../utils/util.typ": twoside-pagebreak
  import "../utils/font.typ": _use-fonts, use-size

  info = info + doc-info
  fonts = fonts + default-fonts

  let use-fonts = name => _use-fonts(fonts, name)
  let use-anonymous = width => block(width: width, fill: black, "", outset: (y: 2pt))

  assert(
    info-items.keys().all(k => k in info),
    message: "Required info-items for info:" + info-items.keys().filter(k => k not in info).join(", "),
  )

  let placed-content(content, dy) = place(bottom + center, content, dy: dy)
  let format-supervisor(items) = grid(
    align: (right, left), columns: (5.95cm, 1fr), rows: 1.1cm, column-gutter: 9.5pt,
    ..items
      .keys()
      .map(k => (items.at(k) + " : ", if anonymous { use-anonymous(10em) } else { info.at(k).intersperse("") }))
      .flatten()
  )

  if type(info.title) == str { info.title = info.title.split("\n") }

  /// Render cover page
  twoside-pagebreak(twoside)

  set align(center)
  set page(margin: (x: 4cm, y: 5.8cm))
  set text(size: use-size("三号"))

  text(size: use-size("二号"), font: use-fonts("HeiTi"), strong(info.title.join("\n")))

  placed-content(
    {
      set par(leading: 1em, spacing: 1.05em)
      set text(font: use-fonts("SongTi"))
      [
        Thesis submitted to

        *Tsinghua University*

        in partial fulfillment of the requirement

        for the degree of
      ]
      v(-0.4pt)
      strong(text(font: use-fonts("HeiTi"), info.degree-name))
      v(3pt)
      [in]
      v(3pt)
      strong(text(font: use-fonts("HeiTi"), info.major))
    },
    -11.64em,
  )

  placed-content(
    {
      set text(font: use-fonts("HeiTi"))
      [by]
      v(3pt)
      strong(if anonymous { use-anonymous(5em) } else { info.author })
      v(-21pt)
      text(font: use-fonts("SongTi"), tracking: -0.45pt, format-supervisor(info-items))
    },
    -2.56em,
  )

  placed-content(strong(text(font: use-fonts("HeiTi"), info.date.display("[month repr:long], [year]"))), 3pt)
}
