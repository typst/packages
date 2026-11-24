// 个人信息
#import "../utils/style.typ": get-fonts
#import "../utils/page-foreground.typ": mainmatter-foreground

#let backmatter(
  // documentclass 传入参数
  anonymous: false,
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
  // 其他参数
  title: [作者简历及攻读学位期间发表的学术论文与其他相关学术成果],
  outlined: true,
  body,
) = {
  if (not anonymous) {
    // 起始三件套（P30）：先清样式（填充页干净），再换页，最后重申正文域样式。
    // 标题（黑体四号加粗居中）与正文字体行距继承自外层 mainmatter 作用域
    // （show 规则嵌套，标准顺序下本函数位于其内），此处不重复设置。
    fonts = get-fonts(fontset) + fonts
    set page(numbering: none, foreground: none)
    pagebreak(weak: true, to: if twoside { "odd" })
    set page(
      numbering: "1",
      footer: none,
      foreground: mainmatter-foreground(
        twoside: twoside,
        info: info,
        fonts: fonts,
      ),
    )
    [
      #heading(
        level: 1,
        numbering: none,
        outlined: outlined,
        title,
      ) <no-auto-pagebreak>
      #set par(first-line-indent: (amount: 0pt, all: true))

      #body
    ]
  }
}
