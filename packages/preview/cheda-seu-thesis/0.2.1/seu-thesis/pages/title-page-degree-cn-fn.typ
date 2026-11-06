#import "../utils/packages.typ": fakebold, show-cn-fakebold
#import "../utils/fonts.typ": 字体, 字号, chineseunderline, justify-words

#let title-cn-conf(
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
  major: (
    main: "摸鱼科学",
    submajor: "计算机摸鱼"
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
  thanks: "本论文受到摸鱼基金委的基金赞助（123456）",
  anonymous: false,
) = page(margin: (top: 3cm, bottom: 2cm, left:2cm, right: 2cm), numbering: none, header: none, footer: none, {
  set align(center)
  set par(first-line-indent: 0pt)
  image("../assets/vi/seu.png", width: 180pt)

  block(fakebold(text(font: 字体.标题宋体, size: 字号.小初, thesisname.CN)))

  v(40pt)

  block(text(font: 字体.黑体, size: 字号.一号, weight: "bold", title.CN))
  
  v(40pt)

  set text(font: 字体.宋体, size: 字号.小二, weight: "bold")
  grid(
    columns: (5em, 1em, 10em),
    row-gutter: 3em,

    text(font: 字体.黑体, "专业名称".clusters().join(h(1em/3))), 
    "：", 
    chineseunderline(major.main),

    text(font: 字体.黑体, "研究生姓名"), 
    "：", 
    chineseunderline(author.CN),

    text(font: 字体.黑体, "导师姓名".clusters().join(h(1em/3))), 
    "：", 
    chineseunderline(advisors.map(it => it.CN + " " + it.CNTitle).join("\n")),
  )

  if thanks != none {
    place(bottom + left, text(font: 字体.宋体, size: 字号.小四, thanks))
  }
})


#title-cn-conf(
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
  major: (
    main: "摸鱼科学",
    submajor: "计算机摸鱼"
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
  thanks: "本论文受到摸鱼基金委的基金赞助（123456）",
  anonymous: false,
)