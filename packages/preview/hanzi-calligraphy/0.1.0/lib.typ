#let calligraphy-paper(
  cols: 12,   // 田字格列数
  rows: 18,   // 田字格行数
  color: red, // 田字格线条颜色
  size: 4em,  // 田字格大小（字体尺寸）
  blank-row: 2, // 底部留空的行数
  blank-col: 2, // 右侧留空的列数
  type: "Normal", // 田字格类型：Normal（默认）、AllH（全留空行）、AllV（全留空列）、Full（无留白）
  show-tian-zi: true, // 是否显示田字格线条
  spacing: 1.2em, // 田字格内部线条的间距
) = {
  // 根据类型调整空行和空列设置
  if type == "AllH" { 
    blank-col = 0  // 全部行留空，列不留空
    blank-row = rows 
  } else if type == "AllV" { 
    blank-col = cols  // 全部列留空，行不留空
    blank-row = 0 
  } else if type == "Full" { 
    blank-col = 0  // 无留白
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
    rows: (size,) * rows,    // 定义网格行数及尺寸
    stroke: color,          // 网格线颜色
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
        ) * (cols - blank-col) * (rows - blank-row)
      ),
    )
  ]
}

#let calligraphy-work(
  font: "FZYingBiKaiShu-S15S", // 默认字体（方正硬笔楷书）
  size: 4em,    // 字体大小
  cols: 12,     // 列数
  rows: 18,     // 行数
  color: red,   // 田字格颜色
  blank-row: 2, // 底部空行数
  blank-col: 2, // 右侧空列数
  type: "Normal", // 纸张类型
  show-tian-zi: true, // 是否显示田字格
  miao: false,  // 是否启用描红（灰色字样）
  body,         // 书写内容
) = {
  let spacing = 1em * 29%  // 文字行间距
  let x = (21cm - size * cols) / 2 + 1em * 16%  // 水平边距计算
  let y = (29.7cm - size * rows) / 2 + 1em * 26% // 垂直边距计算
  let tracking = 1em * 15%  // 字符间距调整

  set page(
    margin: (x: x, y: y,),  // 页边距设置
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

  set par(leading: spacing, spacing: spacing)  // 行距设置

  text(
    size: size * 87%, // 字体大小调整
    font: font,       // 字体
    lang: "cn",       // 语言设置
    tracking: tracking, // 字符间距
    fill: if miao { gray } else { black },  // 是否描红
  )[
    #body  // 渲染书写内容
  ]
}