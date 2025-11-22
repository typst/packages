#import "../utils/fonts.typ": 字体, 字号

#let title-en-conf(
  author: (CN: "王东南", EN: "WANG Dong-nan", ID: "012345"),
  thesisname: (
    CN: "硕士学位论文",
    EN: [
    A Thesis submitted to \
    Southeast University \
    For the Academic Degree of Master of Touching Fish
    ],
    heading: "东南大学硕士学位论文"
  ),
  title: (
    CN: "摸鱼背景下的Typst模板使用研究",
    EN: "A Study of the Use of the Typst Template During Touching Fish"
  ),
  advisors: (
    (CN: "湖牌桥", EN:"HU Pai-qiao", CNTitle: "教授", ENTitle: "Prof."),
    (CN: "苏锡浦", EN:"SU Xi-pu", CNTitle: "副教授", ENTitle: "Associate Prof.")
  ),
  school: (
    CN: "摸鱼学院",
    EN: "School of Touchingfish"
  ),
  date: (
    CN: (
      defenddate: "2099年01月02日", 
      authorizedate: "2099年01月03日",
      finishdate: "2024年01月15日"
    ),
    EN: (
      finishdate: "Jan 15, 2024"
    )
  ),
  anonymous: false,
) = page(margin: (top: 3cm, bottom: 2cm, left:2cm, right: 2cm), numbering: none, header: none, footer: none, {
  set par(first-line-indent: 0pt)
  set align(center)


  block(text(font: 字体.宋体, size: 24pt, weight: "bold", upper(title.EN)))

  v(1cm)

  set text(font: 字体.宋体, size: 16pt, weight: "regular")
  set par(leading: 1.5em)
  set block(spacing: 1.8cm)

  block(
    height: 100% - 160pt,
    grid(
      rows: (auto, 1fr, auto, 1fr, auto, 1fr, auto),
      thesisname.EN,
      [],
      "BY" + "\n" + author.EN,
      [],
      "Supervised by" + "\n" + advisors.map(it => it.ENTitle + " " + it.EN).join("\n and \n"),
      [],
      school.EN + "\n" + "Southeast University" + "\n" + date.EN.finishdate

    )
  )
})


#title-en-conf(
  author: (CN: "王东南", EN: "WANG Dong-nan", ID: "012345"),
  thesisname: (
    CN: "硕士学位论文",
    EN: [
    A Thesis submitted to \
    Southeast University \
    For the Academic Degree of Master of Touching Fish
    ],
    heading: "东南大学硕士学位论文"
  ),
  title: (
    CN: "摸鱼背景下的Typst模板使用研究",
    EN: "A Study of the Use of the Typst Template During Touching Fish"
  ),
  advisors: (
    (CN: "湖牌桥", EN:"HU Pai-qiao", CNTitle: "教授", ENTitle: "Prof."),
    (CN: "苏锡浦", EN:"SU Xi-pu", CNTitle: "副教授", ENTitle: "Associate Prof.")
  ),
  school: (
    CN: "摸鱼学院",
    EN: "School of Touchingfish"
  ),
  date: (
    CN: (
      defenddate: "2099年01月02日", 
      authorizedate: "2099年01月03日",
      finishdate: "2024年01月15日"
    ),
    EN: (
      finishdate: "Jan 15, 2024"
    )
  ),
  anonymous: false,
)