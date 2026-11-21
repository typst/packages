// Yanshan University Touying theme: modern navy defense layout.
//
// The layout follows the YSU doctoral defense Beamer deck. The slide is
// 16 cm x 9 cm (12 cm x 9 cm for 4:3), so the positions below are the deck's
// own centimetres and the font sizes its own points.

#import "@preview/touying:0.8.0": *
#import "tokens.typ": *
#import "components.typ": *

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Plain text of a piece of content (for splitting "1.1 Title" and for notes).
#let _plain(it) = {
  if it == none { "" } else if type(it) == str { it } else if type(it) != content {
    str(it)
  } else if it.has("text") { it.text } else if it.has("children") {
    it.children.map(_plain).join()
  } else if it.func() == math.equation { "$" + _plain(it.body) + "$" } else if it.func() == math.attach {
    _plain(it.base) + if it.has("b") { "_" + _plain(it.b) } else { "" } + if it.has("t") { "^" + _plain(it.t) } else { "" }
  } else if it.has("body") { _plain(it.body) } else if it.func() == linebreak {
    " "
  } else if it.func() == parbreak { "\n\n" } else if it.func() == [ ].func() { " " } else { "" }
}

#let _two(n) = if n < 10 { "0" + str(n) } else { str(n) }

/// Place `body` with its `anchor` at (x, y) from the top-left page corner.
/// Anchors: "nw", "n", "ne", "w", "c", "e", "sw", "s", "se".
#let _at(x, y, anchor: "nw", body) = context {
  let size = measure(body)
  let dx = if anchor.ends-with("w") { 0pt } else if anchor.ends-with("e") {
    -size.width
  } else { -size.width / 2 }
  let dy = if anchor.starts-with("n") { 0pt } else if anchor.starts-with("s") {
    -size.height
  } else { -size.height / 2 }
  place(top + left, dx: x + dx, dy: y + dy, body)
}

/// Text whose box ends at the base line, so "sw"/"se" anchors read as the
/// TikZ "base west"/"base east" anchors.
#let _base(body) = text(bottom-edge: "baseline", top-edge: "cap-height", body)

/// A panel of size (w, h) filled with `grad(0%)`, with the white seal as a
/// watermark of the given opacity. The seal is drawn over the ground and a
/// copy of the ground at 1 - opacity covers it, so the seal shows through at
/// `opacity` (Typst images have no opacity).
#let _seal-panel(w, h, grad, seal-x, seal-y, seal-w, opacity: 9%) = box(
  width: w,
  height: h,
  clip: true,
  {
    place(rect(width: w, height: h, fill: grad(0%)))
    place(dx: seal-x - seal-w / 2, dy: seal-y - seal-w / 2, seal(white: true, width: seal-w))
    place(rect(width: w, height: h, fill: grad(opacity)))
  },
)

#let _grad-diag(t) = gradient.linear(
  ysu-night.transparentize(t),
  ysu-navy.transparentize(t),
  angle: -45deg,
)
#let _grad-opener(t) = gradient.radial(
  (ysu-navy.transparentize(t), 0%),
  (ysu-navy.transparentize(t), 18%),
  (ysu-night.transparentize(t), 100%),
  center: (58%, 62%),
  radius: 90%,
)

// Chapters (level-1 headings) and the current chapter number.
#let _chapters() = query(heading.where(level: 1))
#let _chapter-index() = query(selector(heading.where(level: 1)).before(here())).len()

#let _nav-label(self, i, full: false) = {
  let labels = if full and self.store.nav-full-labels != auto {
    self.store.nav-full-labels
  } else { self.store.nav-labels }
  if labels != auto and i <= labels.len() { labels.at(i - 1) } else {
    let chapters = _chapters()
    if i <= chapters.len() { chapters.at(i - 1).body } else { [] }
  }
}

/// Metadata marker on the current page (`<ysu-sub>`, `<ysu-takeaway>`, ...).
#let _on-page(label) = {
  let page = here().page()
  let found = query(label).filter(m => m.location().page() == page)
  if found.len() == 0 { none } else { found.last().value }
}

// ---------------------------------------------------------------------------
// Page markers
// ---------------------------------------------------------------------------

/// Breadcrumb subsection of the current page (原稿 \DefenseSubsection).
#let sub(body) = [#metadata(body) <ysu-sub>]

/// Conclusion sentence of the current page; it becomes the headline
/// (原稿 \DefenseTakeaway).
#let takeaway(body) = [#metadata(body) <ysu-takeaway>]

/// Opener data of the chapter. Write it right after `= 标题`.
#let chapter-opener(
  question: none,
  keywords: (),
  keyword-icons: (),
  icon: none,
  outline: auto,
  bridge: none,
) = [#metadata((
    question: question,
    keywords: keywords,
    keyword-icons: keyword-icons,
    icon: icon,
    outline: outline,
    bridge: bridge,
  )) <ysu-opener>]

// ---------------------------------------------------------------------------
// Speaker notes (原稿 deck-notes 的 
ote)
// ---------------------------------------------------------------------------

/// Speaker note of the current slide. Write it anywhere in the slide body;
/// several notes on one slide join as paragraphs. The note goes to pdfpc,
/// and with `ysu-theme(notes: true)` to a notes page after the slide.
#let note(body) = {
  speaker-note(body)
  [#metadata(body) <ysu-note-body>]
}

#let _note-param(body) = if body == none { none } else { note(body) }

// Physical frame number: one per slide, as the LaTeX frames are counted.
#let _frame-counter = counter("ysu-frame")

/// Notes of the slide that just ended: the note bodies after the previous
/// `<ysu-note-tail>`, on the slide's last page (subslides repeat them).
/// Emits the `<ysu-note>` export record (frame, page, kind, title, sub,
/// chapter-no, chapter, plain text), followed by the note bodies when
/// `render` is set. `kind` is "cover", "outline", "opener", "slide" or
/// "ending".
#let _note-record(kind, title, render: true) = {
  let prev = query(selector(<ysu-note-tail>).before(here()))
  let sel = selector(<ysu-note-body>).before(here())
  let sel = if prev.len() > 0 { sel.after(prev.last().location()) } else { sel }
  let marks = query(sel)
  let p = calc.max(0, ..marks.map(m => m.location().page()))
  let bodies = marks.filter(m => m.location().page() == p).map(m => m.value)
  if bodies.len() > 0 {
    let hs = query(selector(heading.where(level: 1)).or(heading.where(level: 2)).before(here()))
    let chapters = query(selector(heading.where(level: 1)).before(here()))
    let title = if title != auto { _plain(title) } else if hs.len() > 0 { _plain(hs.last().body) } else { none }
    let subs = query(<ysu-sub>).filter(m => m.location().page() == p)
    [#metadata((
        frame: _frame-counter.get().first(),
        page: p,
        kind: kind,
        title: title,
        sub: if subs.len() > 0 { _plain(subs.last().value) } else { none },
        chapter-no: chapters.len(),
        chapter: if chapters.len() > 0 { _plain(chapters.last().body) } else { none },
        text: bodies.map(b => _plain(b).trim()).join("\n\n"),
      )) <ysu-note>]
  }
  if render { bodies.join(parbreak()) }
}

/// After each slide: the notes page when notes are on (FerroStage / pympress
/// contract: same width, height x 13.5/16, label `notes:N`), otherwise only
/// the export record. `title` is the frame title of structure slides; `auto`
/// takes the last level-1 or level-2 heading.
#let _notes-tail(self, kind: "slide", title: auto) = {
  _frame-counter.step()
  if self.store.notes {
    let w = self.page.width
    page(
      width: w,
      height: w * 13.5 / 16,
      margin: (x: 0.5cm, y: 0.5cm),
      fill: rgb("#252320"),
      numbering: "notes:1",
      header: none,
      footer: none,
      background: none,
      foreground: none,
    )[
      // The notes page shares the label number of the slide before it.
      #counter(page).update(n => n - 1)
      #set text(size: 18pt, fill: rgb("#E6DFD8"))
      #set par(justify: false, first-line-indent: 0pt, leading: 6pt, spacing: 0.4em)
      #show strong: set text(fill: rgb("#FAF9F5"))
      #context _note-record(kind, title)
      #metadata(none) <ysu-note-tail>
    ]
  } else {
    context _note-record(kind, title, render: false)
    [#metadata(none) <ysu-note-tail>]
  }
}

/// `touying-slide` followed by the notes tail.
#let _emit(self, kind: "slide", title: auto, ..args) = {
  touying-slide(self: self, ..args)
  _notes-tail(self, kind: kind, title: title)
}

// ---------------------------------------------------------------------------
// Content page header and footer
// ---------------------------------------------------------------------------

#let _headline-lines(self, head) = {
  let w = self.store.headline-width
  let h = measure(block(width: w, text(size: 14pt, weight: "bold", par(leading: 0.42em, head)))).height
  calc.max(1, calc.round((h - 9.8pt) / 17pt) + 1)
}

/// Header content: kicker, headline and the extra height of a headline that
/// wraps (17 pt per extra line).
#let _header-parts(self) = {
  let sub = _on-page(<ysu-sub>)
  let take = _on-page(<ysu-takeaway>)
  let title = if self.store.at("slide-title", default: auto) != auto {
    self.store.slide-title
  } else {
    let h = utils.current-heading(level: 2, depth: self.slide-level)
    if h == none { none } else { h.body }
  }
  let sep = text(fill: ysu-base, [#h(0.5em)/#h(0.5em)])
  if take == none {
    (kick: sub, head: title)
  } else {
    (kick: if sub == none { title } else { [#title#sep#sub] }, head: take)
  }
}

#let _header(self) = context {
  let parts = _header-parts(self)
  let W = page.width
  let mx = 0.8cm
  let lines = if parts.head == none { 1 } else { _headline-lines(self, parts.head) }
  let rule-y = 1.30cm + (lines - 1) * 17pt
  if parts.kick != none {
    _at(mx, 0.33cm, anchor: "w", text(size: 6.5pt, fill: ysu-muted, parts.kick))
  }
  _at(W - mx, 0.33cm, anchor: "e", seal(height: 0.42cm))
  if parts.head != none {
    place(top + left, dx: mx, dy: 0.60cm, block(width: self.store.headline-width, text(
      size: 14pt,
      weight: "bold",
      fill: ysu-navy,
      par(leading: 0.42em, parts.head),
    )))
  }
  place(top + left, dx: mx, dy: rule-y, line(length: W - 2 * mx, stroke: 0.4pt + ysu-line))
  place(top + left, dx: mx, dy: rule-y - 1.5pt, rect(width: 0.9cm, height: 3pt, fill: ysu-red))
}

#let _nav-bar(self) = context {
  let current = _chapter-index()
  let n = _chapters().len()
  set text(size: 5.5pt)
  for i in range(1, n + 1) {
    if i > 1 { h(0.275cm) }
    let label = _nav-label(self, i)
    if i == current {
      box(stroke: (bottom: 0.7pt + ysu-navy), outset: (bottom: 2.4pt), text(
        fill: ysu-navy,
        weight: "bold",
        label,
      ))
    } else {
      text(fill: ysu-muted, label)
    }
  }
}

#let _page-pill(self) = {
  // The background is laid out before the slide body steps the counter, so
  // read the counter at the page marker that the body carries.
  let label = text(size: 5.5pt, fill: white, weight: "bold", context {
    let page = here().page()
    let mark = query(<ysu-page>).filter(m => m.location().page() == page)
    let n = if mark.len() > 0 { utils.slide-counter.at(mark.first().location()).first() } else {
      utils.slide-counter.get().first()
    }
    [#n#h(0.15em)/#h(0.15em)#utils.last-slide-number]
  })
  // A small parallelogram from navy to navy!70!white.
  context {
    let s = measure(label)
    let (w, h) = (s.width + 10pt, s.height + 2.4pt + 3pt)
    box(width: w + 3pt, height: h, {
      place(polygon(
        fill: grad-page,
        (0pt, h),
        (w, h),
        (w + 3pt, 0pt),
        (3pt, 0pt),
      ))
      place(center + horizon, dx: 1.5pt, label)
    })
  }
}

#let _footer(self) = context {
  let W = page.width
  let H = page.height
  let y = H - 0.45cm
  place(top + left, dy: y, line(length: W, stroke: 0.4pt + ysu-line))
  let mid = y + 0.235cm
  _at(0.8cm, mid, anchor: "w", text(size: 5.5pt, fill: ysu-muted, [
    #self.info.author#h(0.5em)·#h(0.5em)#self.info.at("stage", default: [])
  ]))
  _at(W / 2, mid, anchor: "c", _nav-bar(self))
  _at(W - 0.8cm, mid, anchor: "e", _page-pill(self))
}

// ---------------------------------------------------------------------------
// Slides
// ---------------------------------------------------------------------------

/// Content slide. `== 标题` opens one; `sub` and `takeaway` set the breadcrumb
/// subsection and the headline (same as the `#sub[]` / `#takeaway[]` markers).
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  align: auto,
  title: auto,
  sub: none,
  takeaway: none,
  ..bodies,
) = touying-slide-wrapper(self => {
  let slide-align = if align == auto { self.store.align } else { align }
  let self = utils.merge-dicts(
    self,
    config-store(slide-title: title),
    config-page(background: {
      _header(self + (store: self.store + (slide-title: title)))
      _footer(self)
    }),
  )
  let markers = {
    if sub != none { [#metadata(sub) <ysu-sub>] }
    if takeaway != none { [#metadata(takeaway) <ysu-takeaway>] }
  }
  let new-setting = body => {
    // A headline that wraps pushes the body down by 17 pt per extra line.
    let extra = context {
      let parts = _header-parts(self)
      let lines = if parts.head == none { 1 } else { _headline-lines(self, parts.head) }
      v((lines - 1) * 17pt, weak: false)
    }
    [#metadata(none) <ysu-page>]
    markers
    extra
    show: std.align.with(slide-align)
    show: setting
    body
  }
  _emit(
    self,
    config: config,
    repeat: repeat,
    setting: new-setting,
    composer: composer,
    ..bodies,
  )
})

#let _plain-page(self, config) = utils.merge-dicts(
  self,
  config,
  config-page(header: none, footer: none, background: none, margin: 0pt),
)

/// Cover. `research-line` lists the research threads shown on the navy
/// column: `((no: "03", icon: none, label: [状态感知]), ...)`.
#let title-slide(config: (:), research-line: (), note: none, ..args) = touying-slide-wrapper(self => {
  let self = _plain-page(self, config)
  let info = self.info + args.named()
  let body = context {
    let W = page.width
    let H = page.height
    let r = W / 16cm
    let left-w = 10.25cm * r
    let cx = left-w / 2
    // Left column.
    _at(0.8cm, 0.7cm, logo(height: 0.75cm))
    // Stage tab: a navy trapezoid, wider at the bottom.
    let stage = text(size: 10.5pt, weight: "bold", fill: white, info.at("stage", default: []))
    _at(cx, 2.75cm, anchor: "c", context {
      let s = measure(stage)
      let (w, h) = (s.width + 1.1cm, s.height + 8pt)
      box(width: w, height: h, {
        place(polygon(fill: ysu-navy, (0.22cm, 0pt), (w - 0.22cm, 0pt), (w, h), (0pt, h)))
        place(center + horizon, stage)
      })
    })
    _at(cx, 3.3cm, anchor: "n", block(width: 9.2cm * r, {
      set std.align(center)
      text(size: 15.5pt, weight: heavy, fill: ysu-navy, par(leading: 0.5em, info.title))
      v(0.275cm, weak: false)
      rect(width: 0.9cm, height: 0.05cm, fill: ysu-red)
    }))
    _at(cx, 6.2cm, anchor: "c", tab-pill(text(size: 11.5pt, [汇报人：#info.author])))
    let items = (
      if "supervisor" in info [导师：#info.supervisor],
      if "subject" in info [专业：#info.subject],
      if "school" in info [学院：#info.school],
      if info.date != none [日期：#utils.display-info-date(self)],
    ).filter(it => it != none)
    if r == 1 {
      // 16:9: two rows of two items at the deck's positions.
      for (i, it) in items.enumerate() {
        let x = if calc.even(i) { 0.8cm } else { 5.45cm }
        let y = if i < 2 { 7.25cm } else { 8.1cm }
        _at(x, y, anchor: "sw", _base(text(size: 12pt, fill: ysu-ink, it)))
      }
    } else {
      // Narrow pages: one item per line, centred in the white column.
      _at(cx, 6.75cm, anchor: "n", text(size: 10pt, fill: ysu-ink, stack(spacing: 0.32cm, ..items)))
    }
    // Right column.
    let rw = W - left-w
    place(top + left, dx: left-w, _seal-panel(rw, H, _grad-diag, 14.625cm * r - left-w, 1.75cm, 5.75cm))
    let x0 = left-w + 0.65cm
    let x1 = W - 0.65cm
    if research-line.len() > 0 {
      let pitch = 0.7875cm
      let y0 = 5.375cm
      _at(x0, 4.81cm, text(size: 5.7pt, weight: "bold", fill: ysu-kicker, tracking: 0.12em, [RESEARCH LINE]))
      for i in range(research-line.len() + 1) {
        place(top + left, dx: x0, dy: y0 + i * pitch, line(length: x1 - x0, stroke: 0.4pt + mix(white, 28%, base: ysu-navy)))
      }
      for (i, item) in research-line.enumerate() {
        let y = y0 + (i + 0.5) * pitch
        _at(x0, y, anchor: "w", text(size: 6.4pt, fill: ysu-kicker, item.at("no", default: "")))
        _at(x0 + 0.725cm, y, anchor: "w", text(size: 9.2pt, weight: "bold", fill: white, {
          let ic = item.at("icon", default: none)
          if ic != none { ic; h(0.2cm) }
          item.label
        }))
      }
    }
    let en = info.at("stage-en", default: none)
    _at(x0, 8.35cm, anchor: "sw", block(width: W - x0 - 0.3cm, text(size: 5.7pt, fill: ysu-kicker, [
      Yanshan University#if en != none [#h(0.5em)·#h(0.5em)#en]
    ])))
  }
  _emit(self, kind: "cover", title: info.title, body + _note-param(note))
})

/// Overall table of contents. `groups` highlights consecutive core chapters:
/// `((from: 3, to: 5, tags: ([..], ..), icons: (..)),)`.
#let outline-slide(config: (:), title: [目#h(0.2em)录], groups: (), note: none) = touying-slide-wrapper(self => {
  let self = _plain-page(self, config)
  let body = context {
    let W = page.width
    let H = page.height
    let r = W / 16cm
    let chapters = _chapters()
    let n = chapters.len()
    let groups = groups.filter(g => g.to <= n)
    let group-of(i) = groups.position(g => g.from <= i and i <= g.to)
    // Rows are 0.8 cm apart; a group adds 0.2 cm before and after itself.
    let gaps(i) = groups.filter(g => i >= g.from and g.from > 1).len() + groups.filter(g => i > g.to).len()
    let total = (n - 1) * 0.8cm + gaps(n) * 0.2cm
    let y-top = (H - total) / 2
    let row-y(i) = y-top + (i - 1) * 0.8cm + gaps(i) * 0.2cm
    let xs = (
      disc: 5.45cm * r,
      num: 5.85cm * r,
      title: 6.85cm * r,
      line0: 5.24cm * r,
      line1: 14.8cm * r,
      tag: 14.8cm * r,
      g0: 5.05cm * r,
      g1: 15.1cm * r,
    )
    // Left column.
    place(rect(width: 4.25cm * r, height: H, fill: _grad-diag(0%)))
    _at(0.6cm, 0.8cm, text(size: 21pt, weight: heavy, fill: white, title))
    _at(0.6cm, 1.75cm, text(size: 6.4pt, weight: "bold", fill: ysu-kicker, tracking: 0.3em, [CONTENTS]))
    _at(0.6cm, 8.35cm, anchor: "sw", logo(white: true, height: 0.95cm))
    // Group grounds.
    for g in groups {
      let y0 = row-y(g.from) - 0.475cm
      let y1 = row-y(g.to) + 0.475cm
      place(top + left, dx: xs.g0, dy: y0, rect(width: xs.g1 - xs.g0, height: y1 - y0, radius: 0.1cm, fill: ysu-tint))
    }
    for (k, ch) in chapters.enumerate() {
      let i = k + 1
      let y = row-y(i)
      let gi = group-of(i)
      if gi != none {
        let g = groups.at(gi)
        let j = i - g.from
        let icons = g.at("icons", default: ())
        if j < icons.len() and icons.at(j) != none {
          _at(xs.disc, y, anchor: "c", icon-disc(icons.at(j)))
        }
        _at(xs.num, y, anchor: "w", text(size: 12pt, weight: "bold", fill: ysu-red, _two(i)))
        _at(xs.title, y, anchor: "w", text(size: 9.5pt, weight: "bold", fill: ysu-ink, ch.body))
        let tags = g.at("tags", default: ())
        if j < tags.len() {
          _at(xs.tag, y, anchor: "e", box(
            fill: ysu-navy,
            radius: 0.2cm,
            inset: (x: 0.175cm, y: 0.07cm),
            text(size: 5.7pt, weight: "bold", fill: white, tags.at(j)),
          ))
        }
        if i < g.to {
          place(top + left, dx: xs.line0, dy: y + 0.4cm, line(length: xs.line1 - xs.line0, stroke: 0.4pt + ysu-line))
        }
      } else {
        _at(xs.num, y, anchor: "w", text(size: 12pt, weight: "bold", fill: ysu-base, _two(i)))
        _at(xs.title, y, anchor: "w", text(size: 9.5pt, fill: ysu-ink, ch.body))
        // Hairline under the row, except before a group and after the last row.
        if i < n and group-of(i + 1) == none {
          place(top + left, dx: 5.35cm * r, dy: y + 0.4cm, line(
            length: xs.g1 - 5.35cm * r,
            stroke: 0.4pt + mix(ysu-line, 60%),
          ))
        }
      }
    }
  }
  _emit(self, kind: "outline", title: title, body + _note-param(note))
})

/// Chapter opener, drawn for each `= 标题`. `chapter-opener(...)` right after
/// the heading adds the question, keywords, contents and bridge line.
#let new-section-slide(config: (:), level: 1, numbered: false, body) = touying-slide-wrapper(self => {
  let self = _plain-page(self, config)
  let slide-body = context {
    let W = page.width
    let H = page.height
    let r = W / 16cm
    let k = _chapter-index()
    let chapters = _chapters()
    let n = chapters.len()
    let hd = chapters.at(k - 1, default: none)
    let title = if hd == none { [] } else { hd.body }
    let data = _on-page(<ysu-opener>)
    let data = if data == none { (:) } else { data }
    let get(key, default) = data.at(key, default: default)
    let text-w = W - 6.15cm * r
    let block-x = 5.25cm * r
    show strong: set text(fill: white)
    place(_seal-panel(W, H, _grad-opener, W - 1.8cm, H - 2.4cm, 5.5cm, opacity: 8%))
    _at(W - 0.8cm, 0.4cm, anchor: "ne", logo(white: true, height: 0.5cm))
    // Chapter number; a red rule 0.25 cm under its base line.
    let number = text(size: 77pt * calc.min(1, r * 0.95), weight: heavy, fill: white, top-edge: "cap-height", bottom-edge: "baseline", _two(k))
    _at(0.85cm, 1.0cm, number)
    place(top + left, dx: 0.95cm, dy: 1.0cm + measure(number).height + 0.25cm - 1.5pt, rect(
      width: 1.2cm,
      height: 3pt,
      fill: ysu-red,
    ))
    // Title, question and keywords.
    let title-text = text(size: 16pt, weight: heavy, fill: white, title)
    let title-w = if measure(title-text).width > 9.85cm * r { 10.5 * 16pt } else { text-w }
    _at(block-x, 1.05cm, block(width: text-w, {
      block(width: title-w, par(leading: 0.35em, title-text))
      v(0.25cm, weak: false)
      line(length: 100%, stroke: 0.4pt + mix(white, 30%, base: ysu-navy))
      v(0.15cm, weak: false)
      if get("question", none) != none or get("keywords", ()).len() > 0 {
        grid(
          columns: (auto, 1fr),
          box(fill: ysu-red, radius: 1.5pt, inset: (x: 3pt, y: 1.6pt), text(
            size: 5.7pt,
            weight: "bold",
            fill: white,
            tracking: 0.15em,
            [本章问题],
          )),
          std.align(right, {
            let icons = get("keyword-icons", ())
            for (i, kw) in get("keywords", ()).enumerate() {
              if i > 0 { h(0.15cm) }
              let ic = icons.at(i, default: none)
              box(
                stroke: 0.4pt + mix(white, 50%, base: ysu-navy),
                radius: 0.25cm,
                inset: (x: 0.2cm, y: 0.09cm),
                text(size: 6.5pt, fill: white, { if ic != none { ic; h(0.12cm) }; kw }),
              )
            }
          }),
        )
        v(0.14cm, weak: false)
        text(size: 9.5pt, fill: white, par(leading: 0.55em, get("question", none)))
      }
    }))
    // Chapter contents.
    let rows = get("outline", auto)
    let rows = if rows == auto {
      let next = chapters.at(k, default: none)
      let sel = selector(heading.where(level: 2)).after(hd.location())
      let sel = if next == none { sel } else { sel.before(next.location()) }
      let seen = ()
      for h in query(sel) {
        let t = _plain(h.body)
        if t not in seen { seen.push(t) }
      }
      seen.map(t => {
        let m = t.match(regex("^([0-9]+(?:\.[0-9]+)*)\s+(.+)$"))
        if m == none { ("", t) } else { (m.captures.at(0), m.captures.at(1)) }
      })
    } else { rows }
    let kicker(body) = text(size: 5.7pt, weight: "bold", fill: ysu-kicker, tracking: 0.15em, body)
    if rows.len() > 0 {
      let list-y = 4.8cm
      place(top + left, dx: 0.85cm, dy: list-y - 0.25cm, line(length: W - 1.7cm, stroke: 0.4pt + mix(white, 18%, base: ysu-navy)))
      _at(0.85cm, list-y + 0.08cm, kicker[本章内容])
      let ic = get("icon", none)
      for (i, row) in rows.enumerate() {
        let (no, t) = row
        _at(block-x, list-y + i * 0.44cm, text(size: 9.5pt, {
          if ic != none {
            // Disc center 0.12 cm above the baseline (the CJK glyph center).
            // A bare length shifts the baseline up and drops the disc; anchor
            // the horizon, then move that anchor down by 0.12 cm.
            box(baseline: (at: horizon, shift: -0.12cm), circle(
              radius: 0.16cm,
              fill: mix(ysu-navy, 70%),
              inset: 0pt,
              std.align(center + horizon, text(size: 5.2pt, fill: white, ic)),
            ))
            h(0.2cm)
          }
          if no != "" { text(weight: "bold", fill: ysu-kicker, no); h(0.22cm) }
          text(fill: white, t)
        }))
      }
    }
    let bridge = get("bridge", none)
    if bridge != none {
      _at(0.85cm, 7.55cm, anchor: "sw", _base(kicker[承接 · 输出]))
      _at(block-x, 7.55cm, anchor: "sw", block(width: text-w, _base(text(size: 8.5pt, fill: ysu-kicker, bridge))))
    }
    // Progress row.
    let pitch = (W - 1.7cm) / calc.max(n, 1)
    for i in range(1, n + 1) {
      let x = 0.9cm + (i - 1) * pitch
      let (bar, fg, weight) = if i == k { (white, white, "bold") } else if i < k {
        (mix(white, 55%, base: ysu-navy), ysu-kicker, "regular")
      } else { (mix(white, 18%, base: ysu-navy), ysu-faint, "regular") }
      place(top + left, dx: x, dy: 8.025cm, rect(width: pitch - 0.1cm, height: 0.05cm, fill: bar))
      _at(x, 8.175cm, text(size: 5.5pt, fill: fg, weight: weight, [#_two(i)#h(0.5em)#_nav-label(self, i, full: true)]))
    }
  }
  _emit(self, kind: "opener", config: config, slide-body + body)
})

/// Closing page. With `recap` (three `(title:, chapter:, icon:, body:,
/// tags:)` entries) it shows the contribution cards; otherwise `title` and
/// the body sit under the navy bar.
#let ending-slide(
  config: (:),
  title: [敬请各位老师批评指正],
  kicker: [THANK YOU],
  recap: (),
  note: none,
  ..bodies,
) = touying-slide-wrapper(self => {
  let self = _plain-page(self, config)
  let body = bodies.pos().at(0, default: none)
  let slide-body = context {
    let W = page.width
    let H = page.height
    let r = W / 16cm
    let bar-h = 2.65cm
    place(_seal-panel(W, bar-h, _grad-diag, W - 1.625cm, 1.0cm, 4.75cm, opacity: 8%))
    _at(0.9cm, 0.7cm, text(size: 6.4pt, weight: "bold", fill: ysu-kicker, tracking: 0.3em, kicker))
    _at(0.9cm, 2.05cm, anchor: "sw", _base(text(size: 21pt, weight: heavy, fill: white, tracking: 0.06em, title)))
    _at(W - 0.9cm, 2.05cm, anchor: "se", logo(white: true, height: 0.65cm))
    if recap.len() > 0 {
      let n = recap.len()
      let gap = 0.5cm
      let cw = (W - 1.8cm - (n - 1) * gap) / n
      for (i, item) in recap.enumerate() {
        let x = 0.9cm + i * (cw + gap)
        place(top + left, dx: x, dy: 3.05cm, title-box(
          icon: item.at("icon", default: none),
          title: item.title,
          aside: item.at("chapter", default: none),
          width: cw,
          height: 4.35cm,
          body-size: 10.5pt,
          {
            set par(leading: 0.62em)
            show strong: set text(fill: ysu-navy)
            item.body
            let tags = item.at("tags", default: ())
            if tags.len() > 0 {
              place(bottom + left, dy: 0.05cm, block(width: 100%, {
                set par(leading: 0.42em)
                tags.map(t => box(fill: mix(ysu-navy, 12%), radius: 2pt, inset: (x: 3.5pt, y: 2pt), text(
                  size: 8pt,
                  weight: "bold",
                  fill: ysu-navy,
                  t,
                ))).join(h(3pt))
              }))
            }
          },
        ))
      }
    } else {
      let body = if body != none { body } else {
        stack(dir: ttb, spacing: 0.3cm, seal(height: 2.2cm), wordmark(height: 0.8cm))
      }
      _at(W / 2, (bar-h + H - 0.9cm) / 2, anchor: "c", block(width: W - 1.8cm, std.align(center, body)))
    }
    let info = self.info
    _at(0.9cm, 8.3cm, anchor: "sw", _base(text(size: 9pt, fill: ysu-muted, {
      [答辩人#h(0.5em)#text(fill: ysu-ink, weight: "bold", info.author)]
      if "supervisor" in info { h(0.5cm); [指导教师#h(0.5em)#text(fill: ysu-ink, weight: "bold", info.supervisor)] }
    })))
    if info.date != none {
      _at(W - 0.9cm, 8.3cm, anchor: "se", _base(text(size: 9pt, fill: ysu-ink, utils.display-info-date(self))))
    }
  }
  _emit(self, kind: "ending", title: title, slide-body + _note-param(note))
})

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------

/// YSU defense theme.
///
/// - aspect-ratio: "16-9" (16 cm x 9 cm) or "4-3" (12 cm x 9 cm).
/// - align: vertical alignment of slide bodies (`horizon` centers them under
///   the header, as the defense deck does; `top` pins them).
/// - nav-labels: short chapter labels of the footer; `auto` uses the
///   level-1 headings.
/// - nav-full-labels: labels of the opener progress row; `auto` uses
///   `nav-labels`.
/// - font: `(latin: (..), cjk: (..))` font families.
/// - notes: add a notes page after every slide (see `note`).
#let ysu-theme(
  aspect-ratio: "16-9",
  align: horizon,
  nav-labels: auto,
  nav-full-labels: auto,
  font: (latin: font-latin, cjk: font-cjk),
  notes: false,
  ..args,
  body,
) = {
  let width = if aspect-ratio == "4-3" { 12cm } else { 16cm }
  show: touying-slides.with(
    config-page(
      width: width,
      height: 9cm,
      fill: white,
      header: none,
      footer: none,
      header-ascent: 0pt,
      footer-descent: 0pt,
      margin: (top: 1.75cm, bottom: 0.8cm, x: 1cm),
      // Page labels pair slides with their notes pages (`N`, `notes:N`).
      numbering: if notes { "1" } else { none },
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      receive-body-for-new-section-slide-fn: true,
      show-strong-with-alert: false,
      zero-margin-header: false,
      zero-margin-footer: false,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(
          size: 10pt,
          fill: ysu-ink,
          font: _font-stack(font.latin, font.cjk),
          lang: "zh",
          region: "cn",
        )
        set par(justify: false, leading: 0.75em, spacing: 0.9em)
        set block(spacing: 0.8em)
        set heading(outlined: false)
        set list(
          marker: (
            box(baseline: -0.18em, rect(width: 0.36em, height: 0.36em, fill: ysu-navy)),
            box(baseline: -0.22em, rect(width: 0.26em, height: 0.26em, fill: ysu-navy)),
          ),
          body-indent: 0.5em,
          spacing: 0.75em,
        )
        set enum(numbering: n => text(weight: "bold", fill: ysu-navy, _two(n)))
        // Lists at full frame width use a larger size and a wider item gap;
        // lists in a column keep the base size.
        show list: it => layout(size => context {
          if size.width > 0.8 * (page.width - 2cm) {
            set text(size: 12pt)
            set list(spacing: 0.9em)
            it
          } else { it }
        })
        show strong: set text(weight: "bold", fill: ysu-navy)
        show raw: set text(font: ("DejaVu Sans Mono",) + font.cjk)
        show figure.caption: set text(size: 8pt, fill: ysu-muted)
        show figure.where(kind: table): set figure.caption(position: top)
        show footnote.entry: set text(size: 7pt)
        body
      },
      alert: (self: none, it) => text(fill: ysu-red, weight: "bold", it),
    ),
    config-colors(
      primary: ysu-navy,
      primary-dark: ysu-night,
      primary-light: ysu-base,
      primary-lighter: ysu-line,
      primary-lightest: ysu-tint,
      secondary: ysu-red,
      neutral-darkest: ysu-ink,
      neutral-dark: ysu-muted,
      neutral-lightest: white,
    ),
    config-store(
      align: align,
      nav-labels: nav-labels,
      nav-full-labels: nav-full-labels,
      headline-width: width - 2.4cm,
      notes: notes,
      slide-title: auto,
    ),
    ..args,
  )

  body
}
