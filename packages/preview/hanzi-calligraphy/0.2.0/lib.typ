#let calligraphy-paper(
  cols: 12, // 田字格列数
  rows: 18, // 田字格行数
  color: red, // 田字格线条颜色
  size: 4em, // 田字格大小（字体尺寸）
  blank-row: 2, // 底部留空的行数
  blank-col: 2, // 右侧留空的列数
  type: "Normal", // 田字格类型：Normal（默认）、AllH（全留空行）、AllV（全留空列）、Full（无留白）
  show-tian-zi: true, // 是否显示田字格线条
  spacing: 1.2em, // 田字格内部线条的间距
) = {
  // 根据类型调整空行和空列设置
  if type == "AllH" {
    blank-col = 0 // 全部行留空，列不留空
    blank-row = rows
  } else if type == "AllV" {
    blank-col = cols // 全部列留空，行不留空
    blank-row = 0
  } else if type == "Full" {
    blank-col = 0 // 无留白
    blank-row = 0
  }

  // 定义田字格的绘制内容（斜线和中线）
  let tianzi = [
    #line(angle: 45deg, length: (calc.sqrt(2)) * 100%, stroke: (paint: color, dash: "dashed"))  // 右上至左下的斜线
    #v(-spacing)
    #line(angle: -45deg, length: (calc.sqrt(2)) * 100%, stroke: (paint: color, dash: "dashed")) // 左上至右下的斜线
    #v(-spacing - 0.5 * size)
    #line(length: 100%, stroke: (paint: color, dash: "dashed")) // 水平中心线
    #v(-spacing - 0.5 * size)
    #line(angle: 90deg, length: 100%, stroke: (paint: color, dash: "dashed")) // 垂直中心线
  ]

  // 设置田字格网格布局
  set grid(
    columns: (size,) * cols, // 定义网格列数及尺寸
    rows: (size,) * rows, // 定义网格行数及尺寸
    stroke: color, // 网格线颜色
  )

  // 渲染田字格
  rotate(180deg)[
    #figure(
      grid(
        grid.hline(stroke: 3pt, y: 0), // 顶部边界线
        grid.vline(stroke: 3pt, x: 0), // 左侧边界线
        grid.vline(stroke: 3pt, x: cols), // 右侧边界线
        grid.hline(stroke: 3pt, y: rows), // 底部边界线

        // 渲染右侧空列
        ..(grid.cell(rowspan: rows)[],) * blank-col,

        // 渲染底部空行
        ..(grid.cell(colspan: if cols > blank-col { cols - blank-col } else { 1 })[],) * blank-row,

        // 渲染剩余田字格区域
        ..(
          grid.cell()[ #if show-tian-zi { tianzi } ],
        )
          * (cols - blank-col)
          * (rows - blank-row)
      ),
    )
  ]
}

#let calligraphy-work(
  font: "FZYingBiKaiShu-S15S", // 默认字体（方正硬笔楷书）
  size: 4em, // 字体大小
  cols: 12, // 列数
  rows: 18, // 行数
  color: red, // 田字格颜色
  blank-row: 2, // 底部空行数
  blank-col: 2, // 右侧空列数
  type: "Normal", // 纸张类型
  show-tian-zi: true, // 是否显示田字格
  miao: false, // 是否启用描红（灰色字样）
  paper: "a4", // 纸张大小
  width: auto, // 自定义纸张宽度
  height: auto, // 自定义纸张高度
  first-line-indent: true,
  spacing-rate: 29%,
  x-rate: 16%,
  y-rate: 26%,
  col-gutter: 0pt, // 列间距（用于AllV模式）
  // Vertical punctuation positioning (for AllV mode)
  punc-dx: 0.1em, // 标点水平偏移
  punc-dy: -0.5em, // 标点垂直偏移
  open-bracket-dx: 0pt, // 开括号水平偏移
  open-bracket-dy: 0.2em, // 开括号垂直偏移
  close-bracket-dx: 0pt, // 闭括号水平偏移
  close-bracket-dy: -0.3em, // 闭括号垂直偏移
  sutegana-dx: 0.15em, // 小假名水平偏移
  sutegana-dy: -0.1em, // 小假名垂直偏移
  sutegana-scale: 0.8, // 小假名缩放比例
  body, // 书写内容
) = {
  let paper-sizes = (
    "a3": (297mm, 420mm),
    "a4": (210mm, 297mm),
    "a5": (148mm, 210mm),
    "iso-b5": (176mm, 250mm),
    "us-letter": (8.5in, 11in),
    "us-legal": (8.5in, 14in),
  )

  let (default-w, default-h) = if paper in paper-sizes {
    paper-sizes.at(paper)
  } else {
    (210mm, 297mm)
  }

  let pw = if width != auto { width } else { default-w }
  let ph = if height != auto { height } else { default-h }

  // 根据类型调整空行和空列设置，以便正确计算页边距
  if type == "AllH" {
    blank-col = 0
    blank-row = rows
  } else if type == "AllV" {
    blank-col = cols
    blank-row = 0
  } else if type == "Full" {
    blank-col = 0
    blank-row = 0
  }

  let spacing = 1em * spacing-rate // 文字行间距
  let x = (pw - size * cols) / 2 + 1em * x-rate // 水平边距计算
  let y = (ph - size * rows) / 2 + 1em * y-rate // 垂直边距计算
  let tracking = 1em * 15% // 字符间距调整

  // 计算用于页边距避让的空白列数
  // 如果是 AllV 模式，虽然 blank-col 为 cols，但不应该避让，否则无法显示内容
  let margin-blank-col = if type == "AllV" { 0 } else { blank-col }

  // 计算用于页边距避让的空白行数
  // 如果是 AllH 模式，虽然 blank-row 为 rows，但不应该避让，否则无法显示内容
  let margin-blank-row = if type == "AllH" { 0 } else { blank-row }

  let page-settings = (
    paper: paper,
    margin: (left: x, top: y, right: x + size * margin-blank-col, bottom: y + size * margin-blank-row), // 页边距设置
    background: calligraphy-paper(
      spacing: spacing,
      cols: cols,
      rows: rows,
      color: color,
      blank-row: blank-row,
      blank-col: blank-col,
      type: type,
      show-tian-zi: show-tian-zi,
      size: size,
    ),
  )

  if width != auto { page-settings.insert("width", width) }
  if height != auto { page-settings.insert("height", height) }

  set page(..page-settings)

  let par-settings = (
    leading: spacing,
    spacing: spacing,
    first-line-indent: if first-line-indent {
      (amount: 2.3em, all: true,)
    } else {
      (amount: 0pt, all: false)
    },
  )
  set par(..par-settings) // 行距设置

  // Vertical punctuation helpers for AllV mode
  // 标点符号（逗号、顿号、句号等）- 右上角
  let vp(p) = box(
    width: 1em,
    height: 0.8em,
    move(dx: punc-dx, dy: punc-dy)[#p]
  )
  
  // 开括号（﹁ ︵ 等）- 底部居中
  let vpo(p) = box(
    width: 1em,
    height: 0.8em,
    move(dx: open-bracket-dx, dy: open-bracket-dy)[#p]
  )
  
  // 闭括号（﹂ ︶ 等）- 顶部居中
  let vpc(p) = box(
    width: 1em,
    height: 0.8em,
    move(dx: close-bracket-dx, dy: close-bracket-dy)[#p]
  )

  // Small kana helper - positioned slightly right for vertical text
  let vk(p) = box(
    width: 1em,
    height: 1em,
    move(dx: sutegana-dx, dy: sutegana-dy)[#text(size: sutegana-scale * 1em)[#p]]
  )

  if type == "AllV" {
    // 伪竖排效果：使用分栏布局，每栏宽度为一个字宽
    // Apply show rules for automatic vertical punctuation
    show "，": vp[，]
    show "、": vp[、]
    show "。": vp[。]
    show "．": vp[．]
    show "！": box(width: 1em, height: 1em, align(center + horizon)[！])
    show "？": box(width: 1em, height: 1em, align(center + horizon)[？])
    show "!": box(width: 1em, height: 1em, align(center + horizon)[！])
    show "?": box(width: 1em, height: 1em, align(center + horizon)[？])
    show "「": vpo[﹁]
    show "」": vpc[﹂]
    show "『": vpo[﹃]
    show "』": vpc[﹄]
    show "（": vpo[︵]
    show "）": vpc[︶]
    show "【": vpo[︻]
    show "】": vpc[︼]
    show "〈": vpo[︿]
    show "〉": vpc[﹀]
    show "《": vpo[︽]
    show "》": vpc[︾]
    
    // Small hiragana (sutegana) - positioned upper-right
    show "っ": vk[っ]
    show "ゃ": vk[ゃ]
    show "ゅ": vk[ゅ]
    show "ょ": vk[ょ]
    show "ぁ": vk[ぁ]
    show "ぃ": vk[ぃ]
    show "ぅ": vk[ぅ]
    show "ぇ": vk[ぇ]
    show "ぉ": vk[ぉ]
    
    // Small katakana - positioned upper-right
    show "ッ": vk[ッ]
    show "ャ": vk[ャ]
    show "ュ": vk[ュ]
    show "ョ": vk[ョ]
    show "ァ": vk[ァ]
    show "ィ": vk[ィ]
    show "ゥ": vk[ゥ]
    show "ェ": vk[ェ]
    show "ォ": vk[ォ]
    
    let content = text(
      size: size * 87%, // 字体大小调整
      font: font, // 字体
      lang: "cn", // 语言设置
      tracking: tracking, // 字符间距
      fill: if miao { gray } else { black }, // 是否描红
    )[
      #body  // 渲染书写内容
    ]
    
    columns(cols, gutter: col-gutter, content)
  } else {
    let content = text(
      size: size * 87%, // 字体大小调整
      font: font, // 字体
      lang: "cn", // 语言设置
      tracking: tracking, // 字符间距
      fill: if miao { gray } else { black }, // 是否描红
    )[
      #body  // 渲染书写内容
    ]
    content
  }
}
