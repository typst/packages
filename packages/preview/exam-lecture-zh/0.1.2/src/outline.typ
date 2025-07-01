#import "const-state.typ": *

#let chapter(name) = context {
  pagebreak(weak: true)
  counter("chapter").step()
  set heading(numbering: _ => counter("chapter").display("一、"))
  place(top, hide[= #name <chapter>])
  // 同一个文档写多个章节一heading和question的计数重新开始
  counter(heading).update(0)
  counter("question").update(0)
}

#let title(name, size: 15pt, weight: "bold", font: page-font, position: center, top: 0pt, bottom: 18pt) = {
  v(top)
  align(position, text(font: font, size, weight: weight)[#name <title>])
  v(bottom)
}

#let subject(name, size: 21.5pt, spacing: 1em, font: hei-ti, top: -20pt, bottom: 0pt) = {
  v(top)
  align(center)[
    #text(
      font: font,
      size: size,
    )[#name.text.split("").slice(1, -1).join(h(spacing))]
  ]
  v(bottom)
  subject-state.update(name.text)
}

#let secret = place(top, text(font: "SimHei")[绝密★启用前])

#let exam-type(type, prefix: "试卷类型: ") = place(top + right, text(font: hei-ti)[#prefix#type])

#let exam-info(
  info: (
    时间: "120分钟",
    满分: "150分",
  ),
  weight: 500,
  font: hei-ti,
  size: 11pt,
  gap: 2em,
  top: 0pt,
  bottom: 0pt,
) = {
  set align(center)
  if info.len() == 0 { return }
  grid(
    columns: info.len(),
    gutter: gap,
    inset: (top: top, bottom: bottom),
    align: center + horizon,
    ..for (key, value) in info {
      (text(size: size, font: font, weight: weight)[#key: #value],)
    }
  )
}

#let scoring-box(x: 0pt, y: 0pt) = {
  place(dx: x, dy: y, right + top)[
    #table(
      columns: (auto, 1.6cm),
      inset: 8pt,
    )[得分][][阅卷人]
  ]
}

#let scoring-box_(x: 0pt, y: 0pt) = {
  place(dx: x, dy: y, right + top)[
    #table(
      rows: (auto, 1.2cm),
      inset: 8pt,
    )[得分][#h(3em)]
  ]
}

#let notice(..items) = context {
  set par(first-line-indent: 0em)
  text(font: hei-ti)[注意事项:]
  let indent = 2em
  let _numbering = "1."
  set enum(numbering: _numbering, indent: indent)
  set par(hanging-indent: -indent - enum.body-indent - measure(_numbering).width)
  let arr = items.pos()
  for value in arr [+ #par(value)]
}

// 一种页码格式: "第x页（共xx页）
#let zh-arabic(prefix: "", suffix: "") = (..nums) => {
  let arr = nums.pos()
  [#prefix#h(1em)#subject-state.get()#suffix#h(1em)第#str(arr.at(0))页（共#str(arr.at(-1))页）]
}

#let inline-square(num, width: 1.5em, gap: 0pt, body: "") = {
  set square(stroke: .5pt, width: width)
  grid(
    columns: num,
    gutter: gap,
    ..num * (square(body),)
  )
}

#let _create-seal(
  dash: "dashed",
  supplement: "密封线内不得答题",
  info: (:),
) = {
  set par(spacing: 10pt)
  set text(font: "SimHei", size: 12pt)
  set align(center)
  set grid(columns: 2, align: horizon, gutter: .5em)
  if supplement != "" { text(tracking: .8in)[#supplement] }
  grid(
    columns: if info.len() == 0 { 1 } else { info.len() },
    gutter: 1em,
    ..for (key, value) in info {
      (
        grid(
          key,
          value,
        ),
      )
    }
  )
  line(length: 100%, stroke: (dash: dash))
}

// 密封线
#let _seal-line(
  student-info: (
    姓名: underline[~~~~~~~~~~~~~],
    准考证号: inline-square(14),
    考场号: inline-square(2),
    座位号: inline-square(2),
  ),
  dash: "dashed",
  supplement: "此卷只装订不密封",
  is-separate: true,
) = context {
  // 根据页码决定是否显示密封线
  // 如果当前页面有<title>,则显示密封线,并在该章节最后一页的右侧也设置密封线
  let chapter-location = for value in query(<title>) {
    counter(page).at(value.location())
  }

  if chapter-location.len() == 0 { return }
  let current = counter(page).get().first()
  let last = counter(page).final()

  // 获取上一章最后一页的页码,给最后一页加上密封线
  let chapter-last-page-location = chapter-location.map(item => item - 1) + last
  if page.columns == 2 and is-separate {
    chapter-last-page-location = chapter-location.map(item => item - 2) + (last.first() - 1,)
  }

  // 去除第一章,因为第一章前面没有章节了
  let _ = chapter-last-page-location.remove(0)

  let _margin-y = page.margin * 2
  let _width = page.height - _margin-y
  if page.flipped { _width = page.width - _margin-y }
  block(width: _width)[
    // 判断当前是在当前章节第一页还是章节最后一页
    //当前章节第一页密封线
    #if chapter-location.contains(current) {
      place(
        dx: -_width - 1em,
        dy: -2em,
      )[
        #rotate(-90deg, origin: right + bottom)[
          #_create-seal(dash: dash, info: student-info, supplement: supplement)
        ]
      ]
      return
    }

    #if (chapter-last-page-location).contains(current) {
      _width = if page.flipped {
        page.height
      } else { page.width }
      // 章节最后页的密封线
      place(dx: _width - page.margin - 2em, dy: 2em)[
        #rotate(90deg, origin: left + top, _create-seal())
      ]
    }
  ]
}

#let draft(
  name: "草稿纸",
  student-info: (
    姓名: underline[~~~~~~~~~~~~~],
    准考证号: underline[~~~~~~~~~~~~~~~~~~~~~~~~~~],
    考场号: underline[~~~~~~~],
    座位号: underline[~~~~~~~],
  ),
  dash: "solid",
  supplement: "",
) = {
  set page(margin: .5in, header: none, footer: none)
  title(name.split("").join(h(1em)), bottom: 0pt)
  _create-seal(dash: dash, supplement: supplement, info: student-info)
}
