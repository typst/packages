// ============================================================
// 横向 Typst 模板 —— 适合大尺寸图表、流程图、架构图与多列内容展示
//
// 本文件不会修改原始 template.typ，而是在其基础上复用全部视觉样式，
// 仅将页面改为 A4 横向，并缩小左右页边距以扩大可用画布。
//
// 用法：
//   #import "template-landscape.typ": *
//   #show: conf.with(
//     title: [文档标题],
//     doc-type: "report",
//     authors: ("张三",),
//   )
//   = 正文从这里开始……
// ============================================================

#import "template.typ" as base

// 重新导出原模板的公共颜色、字体和组件，保持使用方式一致。
#let theme-color = base.theme-color
#let theme-color-dark = base.theme-color-dark
#let bg-soft = base.bg-soft
#let border-soft = base.border-soft
#let font-main = base.font-main
#let font-heading = base.font-heading
#let font-mono = base.font-mono
#let font-kai = base.font-kai

#let callout = base.callout
#let note = base.note
#let tip = base.tip
#let warning = base.warning
#let bug = base.bug
#let danger = base.danger
#let divider = base.divider
#let changelog-table = base.changelog-table
#let appendix = base.appendix

#let stepcolor = base.stepcolor
#let stepbox = base.stepbox
#let flowarrow = base.flowarrow
#let loopwrap = base.loopwrap

// 页面参数集中放在这里，后续可按展示密度继续调整。
#let landscape-paper = "a4"
#let landscape-margin = (
  top: 2.2cm,
  bottom: 1.9cm,
  left: 1.8cm,
  right: 1.8cm,
)

// 与原模板 conf() 保持同一调用接口。
#let conf(
  title: "文档标题",
  subtitle: none,
  authors: (),
  org: none,
  date: datetime.today(),
  version: none,
  status: none,
  doc-type: "report",
  lang: "zh",
  cover: true,
  toc: true,
  toc-depth: 3,
  logo: none,
  changelog: none,
  orientation: "landscape",
  body,
) = {
  if orientation == "portrait" {
    // 纵向模式直接使用原模板，保持其页面参数不变。
    base.conf(
      title: title,
      subtitle: subtitle,
      authors: authors,
      org: org,
      date: date,
      version: version,
      status: status,
      doc-type: doc-type,
      lang: lang,
      cover: cover,
      toc: toc,
      toc-depth: toc-depth,
      logo: logo,
      changelog: changelog,
      body,
    )
  } else if orientation == "landscape" {
    // 先设置横向页面，使封面和目录也采用横向布局。
    set page(
      paper: landscape-paper,
      flipped: true,
      margin: landscape-margin,
    )

    base.conf(
      title: title,
      subtitle: subtitle,
      authors: authors,
      org: org,
      date: date,
      version: version,
      status: status,
      doc-type: doc-type,
      lang: lang,
      cover: cover,
      toc: toc,
      toc-depth: toc-depth,
      logo: logo,
      changelog: changelog,
      {
        // 原模板会在正文开始前恢复 A4 纵向；在这里再次切换为横向。
        // 未重新指定页眉、页脚和页码，因此会完整保留原模板设置。
        set page(
          paper: landscape-paper,
          flipped: true,
          margin: landscape-margin,
        )
        body
      },
    )
  } else {
    panic("orientation must be either \"portrait\" or \"landscape\"")
  }
}
