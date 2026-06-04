#let make-cover(
  degree: (master: true, doctor: false),
  institute: "Department of Computer Science and Informantion Engineering",
  title: (
    en: "A Thesis/Dissertation Template written in Typst for National Cheng Kung University",
    zh-tw: "以 Typst 撰寫之國立成功大學碩博士論文模板論文模板",
  ),
  student: (en: "Chun-Hao Chang", zh-tw: "張峻豪"),
  advisor: (en: "Dr. Chia-Chi Tsai", zh-tw: "蔡家齊 博士"),
  coadvisor: (
    (en: "Dr. Ha Ha Lin", zh-tw: "林哈哈 博士"),
    (en: "Dr. Ha Ha Wang", zh-tw: "王哈哈 博士"),
  ),
) = {
  // checking degree
  assert(
    (
      (degree.master and (not degree.doctor))
        or (degree.doctor and (not degree.master))
    ), // XOR logic
    message: "Wrong degree configuration!",
  )

  // set page margin
  set page(
    numbering: none,
    margin: (top: 23mm, bottom: 30mm, left: 20mm, right: 20mm),
    background: image("../assets/watermark-20160509_v2-a4.svg"),
  )


  // top of the cover
  align(
    top + center,
    stack(
      text(size: 25pt)[National Cheng Kung University],
      v(1cm),
      text(size: 25pt)[#institute],
      v(1cm),
      text(size: 25pt)[
        #if degree.master {
          [Master Thesis]
        } else {
          [Doctoral Dissertation]
        }
      ],
    ),
  )

  // title of the cover
  place(
    center + horizon,
    stack(
      text(size: 17pt)[#title.zh-tw],
      v(1.5em),
      text(size: 17pt)[#title.en],
    ),
  )

  // author info and date
  // check whether there is any co-advisor
  let has_coadvisor = (coadvisor.len() > 0)
  let coadvisor_en = ()
  let coadvisor_zh-tw = ()
  if has_coadvisor {
    for element in coadvisor {
      coadvisor_en.push(element.en)
      coadvisor_zh-tw.push(element.zh-tw)
    }
  }
  align(bottom + center)[
    // author (2 columns, zh-tw and en)
    // first column: zh-tw ver.
    #grid(
      columns: (50%, 50%),
      align: (top, top),
      stack(
        grid(
          columns: (45%, 10%, 45%),
          align: (right, center, left),
          text(size: 17pt)[學生],
          text(size: 17pt)[:],
          text(size: 17pt)[#student.zh-tw],
        ),
        v(1cm),
        grid(
          columns: (45%, 10%, 45%),
          align: (right, center, left),
          text(size: 17pt)[指導教授],
          text(size: 17pt)[:],
          text(size: 17pt)[#advisor.zh-tw],
        ),
        if has_coadvisor { v(0.75cm) } else { none },
        if has_coadvisor {
          grid(
            columns: (45%, 10%, 45%),
            align: (right, center, left),
            text(size: 17pt)[共同指導教授],
            text(size: 17pt)[:],
            text(size: 17pt)[#coadvisor_zh-tw.join("\n")],
          )
        } else { none },
      ),
      // second column: english ver.
      stack(
        grid(
          columns: (35%, 10%, 55%),
          align: (right, center, left),
          text(size: 17pt)[Student],
          text(size: 17pt)[:],
          text(size: 17pt)[#student.en],
        ),
        v(1cm),
        grid(
          columns: (35%, 10%, 55%),
          align: (right, center, left),
          text(size: 17pt)[Advisor],
          text(size: 17pt)[:],
          text(size: 17pt)[#advisor.en],
        ),
        if has_coadvisor { v(0.75cm) } else { none },
        if has_coadvisor {
          grid(
            columns: (35%, 10%, 55%),
            align: (right, center, left),
            text(size: 17pt)[Co-Advisor],
            text(size: 17pt)[:],
            text(size: 17pt)[#coadvisor_en.join("\n")],
          )
        } else { none },
      ),
    )
    // intentionally left vertical space
    #v(5em)
    // date
    #text(size: 17pt)[#datetime.today().display()]
  ]

  // ensure page-break
  pagebreak()
}
