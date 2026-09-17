// ============================================================
// style.typ — 北大格式规范（《研究生学位论文写作指南》2014）
// ============================================================
//
// build(font, fakebold) 返回各元素的字体/字号/间距样式字典，作为全模板的单一事实来源。
// font 为 config() 解析出的当前系统字体方案（font-set.windows/macos/linux），
// fakebold 为对应系统的伪粗体策略（fakebold-rules），透传到需加粗元素的 fakebold 字段。
// 调用方通过 style.正文.font 可直接拿到字体数组，用于 set text() 等。
//
// 条目按指南章节号组织，注释中的字号（三号、小四等）对应 size.typ。
// 如需按 Word 模板做视觉校准，调整 size.typ 中对应字号的 pt 值即可全局生效。

#import "size.typ": size
#import "font.typ": font-set, fakebold-rules

#let build(font, fakebold: (:)) = (
  // ── 1.1 封面 ──
  // "博士研究生学位论文"：小初（36pt）黑体
  封面题头: (font: font.黑体, size: size.小初),
  // "题目：" 前缀标签：二号（22pt）宋体
  封面题目标签: (font: font.宋体, size: size.二号),
  // 题目：一号（26pt）黑体居中加粗
  封面题目: (font: font.黑体, size: size.一号, fakebold: fakebold.黑体),
  // 字段标签（"姓  名："等）：黑体，与仿宋值形成对比
  封面字段标签: (font: font.黑体, size: size.三号),
  // 作者/导师/院系：三号（16pt）仿宋
  封面信息: (font: font.仿宋, size: size.三号),
  // 日期：三号（16pt）宋体
  封面日期: (font: font.宋体, size: size.三号),
  // 日期后缀（"年"、"月"）：黑体
  封面日期标点: (font: font.黑体, size: size.三号),
  // 校徽/字标占位框文字
  封面占位符: (font: font.黑体, size: 0.6em),
  // 盲审封面正文段落
  封面盲审: (leading: 1em, spacing: 1.5em),

  // ── 1.3 中文摘要 ──
  // 标题：三号（16pt）黑体，段前 24bp 后 18bp
  摘要标题: (font: font.黑体, size: size.三号, spacing-before: 24pt, spacing-after: 18pt, weight: "regular"),
  // 内容：小四（12pt）宋体。PKU 指南规定行距固定 20bp，实测 10.5pt 更接近 Word
  摘要内容: (font: font.宋体, size: size.小四, first-line-indent: 2em, leading: 10.5pt, spacing: 10.5pt),
  // 关键词：小四（12pt）宋体
  关键词: (font: font.宋体, size: size.小四),

  // ── 1.4 英文摘要 ──
  // 英文题目：三号（16pt），段前 24bp 后 18bp，单倍间距
  英文题目: (font: font.英文无衬线, size: size.三号, spacing-before: 24pt, spacing-after: 18pt, linespacing: 1.65em, weight: "regular"),
  // 作者/专业/导师：小四（12pt）居中
  英文作者信息: (font: font.英文衬线, size: size.小四, leading: 20pt),
  // "ABSTRACT"：小四（12pt）加粗，段前 8bp 后 6bp
  英文摘要标题: (font: font.英文无衬线, size: size.小四, spacing-before: 8pt, spacing-after: 6pt),
  // 内容：小四（12pt），首行缩进 0.74cm。PKU 指南规定 20bp，实测 12.5pt 更接近 Word
  英文摘要内容: (font: font.英文衬线, size: size.小四, first-line-indent: 0.74cm, leading: 12.5pt),

  // ── 1.5 目录 ──
  // 章标题行：小四（12pt）黑体，段前 6bp
  目录章标题: (font: font.黑体, size: size.小四, spacing-before: 6pt, weight: "regular"),
  // 节标题等：小四（12pt）宋体，实测 10.5pt 更接近 Word
  目录其他: (font: font.宋体, size: size.小四, leading: 10.5pt, 编号间距: 1em, 缩进量: 1em),

  // ── 1.6 主要符号对照表 ──
  符号表: (row-gutter: 10pt, group-gutter: 20pt, 列间距: 4em),

  // ── 1.7 正文 ──
  // 标题行距基准值（默认公式：三号 * 1.3 * 2.41）
  标题行距: size.三号 * 1.3 * 2.41,
  // ── 1.7.1 标题 ──
  // 指南 2014 里的章标题：三号（16pt）黑体居中，段前 24bp 后 18bp，单倍间距
  // 硕士研究生学位论文格式模板（2024）文件里章标题：三号（16pt）黑体居中，段前 17bp 后 16.5bp，2.41 倍间距
  // pkuthss-typst 也采用了最新的 Word 模板（2024）标准用的是段前 17bp 后 16.5bp，2.41 倍间距
  章标题: (font: font.黑体, size: size.三号, align: center, weight: "regular", spacing-before: 17pt, spacing-after: 16.5pt, 编号间距: 1em),
  // 一级节标题：四号（14pt）黑体居左，段前 24bp 后 6bp
  一级节标题: (font: font.黑体, size: size.四号, weight: "regular", spacing-before: 24pt, spacing-after: 6pt, 编号间距: 1em),
  // 二级节标题：13pt 黑体居左，段前 12bp 后 6bp
  二级节标题: (font: font.黑体, size: 13pt, weight: "regular", spacing-before: 12pt, spacing-after: 6pt, 编号间距: 1em),
  // 三级节标题：小四（12pt）黑体居左，段前 12bp 后 6bp
  三级节标题: (font: font.黑体, size: size.小四, weight: "regular", spacing-before: 12pt, spacing-after: 6pt, 编号间距: 1em),

  // ── 1.7.2 段落文字 ──
  // 正文：小四（12pt）宋体。PKU 指南规定行距固定 20bp，实测 10.5pt 更接近 Word
  正文: (font: font.宋体, size: size.小四, first-line-indent: 2em, leading: 10.5pt, spacing: 10.5pt, fakebold: fakebold.宋体),

  // ── 1.7.3 脚注 ──
  // 脚注：小五（9pt）宋体，单倍行距，悬挂缩进
  脚注: (font: font.宋体, size: size.小五, leading: 1.2em, super-size: 0.65em, 悬挂缩进: 1.5em, 编号间距: 0.5em),

  // 正则文本强调：斜体用楷体
  强调: (font: font.楷体, style: "italic"),

  // 公式编号：宋体
  公式编号: (font: font.宋体),

  // 子图编号格式
  子图编号格式: "(a)",

  // 行内代码：五号（10.5pt）等宽字体
  代码样式: (font: font.代码, size: size.五号),

  // ── 1.7.4 图表 ──
  // 图序图名：11pt 宋体居中（指南直接指定，非传统字号名）
  图序图名: (font: font.宋体, size: 11pt),
  // 表序表名：11pt 宋体居中
  表序表名: (font: font.宋体, size: 11pt),
  // 指南 2014 里的表单元格：11pt 宋体
  // 硕士研究生学位论文格式模板（2024）文件里表单元格字号是五号字体，对应 10.5pt
  // pkuthss-typst 也采用了最新的 Word 模板（2024）标准用的是 10.5pt
  表单元格: (font: font.宋体, size: 10.5pt),
  // 代码块标题：11pt 宋体
  代码块标题: (font: font.宋体, size: 11pt),

  // 三线表线宽
  三线表: (顶线: 1.5pt, 表头线: 0.75pt, 底线: 1.5pt),

  // ── 1.7 其他 ──
  // 无序列表符号尺寸（圆/方/菱）
  列表: (符号尺寸: 6pt),
  // 定理证明结束标记（□）字号
  证明: (标记字号: 0.7em),
  // 版权声明内容段落行距 + 标题行距倍数
  版权声明: (段落行距: 15.6pt, linespacing-multiplier: 2, 基准倍数: 1.3),

  // ── 1.8 参考文献 ──
  // 参考文献内容：五号（10.5pt）宋体，行距 ~16bp，段前 3bp
  参考文献内容: (font: font.宋体, size: size.五号, leading: 6.5pt, para-spacing: 6.5pt + 3pt, 悬挂缩进: 1.66em),

  // ── 1.9 附录与后置部分 ──
  // 致谢/后记/说明：格式同正文
  致谢: (font: font.宋体, size: size.小四, leading: 10.5pt, spacing: 10.5pt),
  // 原创性声明与授权说明：固定法律文书，标题加粗
  声明: (font: font.宋体, size: size.小四, leading: 0.95em, spacing: 0.95em, fakebold: fakebold.宋体),
  // 攻读学位期间发表的论文列表
  成果列表: (font: font.宋体, size: size.小四, spacing: 1.14em, 编号格式: "[1]", 悬挂缩进: 1.2em),
  // 书脊页：仿宋 12pt，左右窄边距
  书脊: (font: font.仿宋, size: 12pt, margin: (x: 1cm, y: 5.4cm)),

  // ── 1.11 页面设置 ──
  // A4 纸，左侧装订
  页边距: (top: 3.0cm, bottom: 2.5cm, left: 2.6cm, right: 2.6cm),
  // 页眉：五号（10.5pt）宋体居中，距页顶 2cm
  页眉: (font: font.宋体, size: size.五号, 堆叠间距: 3pt, 垂直位置: 2cm, 下划线粗细: 0.75pt, 编号间距: 0.5em),
  // 页码：五号（10.5pt）居中，距页底 1.75cm（写作指南 2014 版）
  // 硕士研究生学位论文格式模板（2024）文件里页码字号是小五（9pt）
  // pkuthss-typst 也采用了最新的 Word 模板（2024）标准用的是 9pt
  页码: (font: font.英文衬线, size: size.小五, 垂直位置: 1.75cm),
)

/// 默认样式（基于 font-set.windows + fakebold-rules.windows），供以下场景使用：
/// 1. booktab.typ 等用户组件的模块级回退
/// 2. 所有页面函数的 style 参数默认值（参数为 none 时回退到此）
#let style = build(font-set.windows, fakebold: fakebold-rules.windows)
