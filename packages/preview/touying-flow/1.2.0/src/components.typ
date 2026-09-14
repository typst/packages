#import "utils.typ"

#let _typst-builtin-numbering = numbering

#let cell = block.with(width: 100%, height: 100%, above: 0pt, below: 0pt, outset: 0pt, breakable: false)


/// SIDE BY SIDE
///
/// A simple wrapper around `grid` that creates a grid with a single row.
/// It is useful for creating side-by-side slide.
///
/// It is also the default function for composer in the slide function.
///
/// Example: `side-by-side[a][b][c]` will display `a`, `b`, and `c` side by side.
///
/// - `columns` is the number of columns. Default is `auto`, which means the number of columns is equal to the number of bodies.
///
/// - `gutter` is the space between columns. Default is `1em`.
///
/// - `..bodies` is the contents to display side by side.
#let side-by-side(columns: auto, gutter: 1em, ..bodies) = {
  let bodies = bodies.pos()
  if bodies.len() == 1 {
    return bodies.first()
  }
  let columns = if columns == auto {
    (1fr,) * bodies.len()
  } else {
    columns
  }
  grid(columns: columns, gutter: gutter, ..bodies)
}


/// Adaptive columns layout
///
/// Example: `components.adaptive-columns(outline())`
///
/// - `gutter` is the space between columns.
///
/// - `max-count` is the maximum number of columns.
///
/// - `start` is the content to place before the columns.
///
/// - `end` is the content to place after the columns.
///
/// - `body` is the content to place in the columns.
#let adaptive-columns(gutter: 4%, max-count: 3, start: none, end: none, body) = layout(size => {
  let n = calc.min(
    calc.ceil(measure(body).height / (size.height - measure(start).height - measure(end).height)),
    max-count,
  )
  if n < 1 {
    n = 1
  }
  start
  if n == 1 {
    body
  } else {
    columns(n, body)
  }
  end
})


/// Touying progress bar.
///
/// - `primary` is the color of the progress bar.
///
/// - `secondary` is the color of the background of the progress bar.
///
/// - `height` is the height of the progress bar, optional. Default is `2pt`.
#let progress-bar(height: 2pt, primary, secondary) = utils.touying-progress(ratio => {
  grid(
    columns: (ratio * 100%, 1fr),
    rows: height,
    cell(fill: primary), cell(fill: secondary),
  )
})


/// Left and right.
///
/// - `left` is the content of the left part.
///
/// - `right` is the content of the right part.
#let left-and-right(left, right) = grid(
  columns: (auto, 1fr, auto),
  left, none, right,
)


// Create a slide where the provided content blocks are displayed in a grid and coloured in a checkerboard pattern without further decoration. You can configure the grid using the rows and `columns` keyword arguments (both default to none). It is determined in the following way:
///
/// - If `columns` is an integer, create that many columns of width `1fr`.
/// - If `columns` is `none`, create as many columns of width `1fr` as there are content blocks.
/// - Otherwise assume that `columns` is an array of widths already, use that.
/// - If `rows` is an integer, create that many rows of height `1fr`.
/// - If `rows` is `none`, create that many rows of height `1fr` as are needed given the number of co/ -ntent blocks and columns.
/// - Otherwise assume that `rows` is an array of heights already, use that.
/// - Check that there are enough rows and columns to fit in all the content blocks.
///
/// That means that `#checkerboard[...][...]` stacks horizontally and `#checkerboard(columns: 1)[...][...]` stacks vertically.
#let checkerboard(columns: none, rows: none, ..bodies) = {
  let bodies = bodies.pos()
  let columns = if type(columns) == int {
    (1fr,) * columns
  } else if columns == none {
    (1fr,) * bodies.len()
  } else {
    columns
  }
  let num-cols = columns.len()
  let rows = if type(rows) == int {
    (1fr,) * rows
  } else if rows == none {
    let quotient = calc.quo(bodies.len(), num-cols)
    let correction = if calc.rem(bodies.len(), num-cols) == 0 {
      0
    } else {
      1
    }
    (1fr,) * (quotient + correction)
  } else {
    rows
  }
  let num-rows = rows.len()
  if num-rows * num-cols < bodies.len() {
    panic("number of rows (" + str(num-rows) + ") * number of columns (" + str(num-cols) + ") must at least be number of content arguments (" + str(
      bodies.len(),
    ) + ")")
  }
  let cart-idx(i) = (calc.quo(i, num-cols), calc.rem(i, num-cols))
  let color-body(idx-body) = {
    let (idx, body) = idx-body
    let (row, col) = cart-idx(idx)
    let color = if calc.even(row + col) {
      white
    } else {
      silver
    }
    set align(center + horizon)
    rect(inset: .5em, width: 100%, height: 100%, fill: color, body)
  }
  let body = grid(
    columns: columns, rows: rows,
    gutter: 0pt,
    ..bodies.enumerate().map(color-body)
  )
  body
}


/// Show progressive outline. It will make other sections except the current section to be semi-transparent.
///
/// - `alpha` is the transparency of the other sections. Default is `60%`.
///
/// - `level` is the level of the outline. Default is `1`.
///
/// - `transform` is the transformation applied to the text of the outline. It should take the following arguments:
///
///   - `cover` is a boolean indicating whether the current entry should be covered.
///
///   - `..args` are the other arguments passed to the `progressive-outline`.
#let progressive-outline(
  alpha: 10%, // 将透明度从60%降低到30%
  level: 1,
  transform: (cover: false, alpha: 10%, ..args, it) => {
    // 根据标题级别设置字号
    let fontSize = if it.element.level == 1 {
      if cover { 0.8em } else { 1.1em } // 一级标题
    } else if it.element.level == 2 {
      if cover { 0.7em } else { 0.8em } // 二级标题
    } else {
      0.8em // 其他级别标题
    }

    let weight = if it.element.level == 1 {
      if cover { "regular" } else { "bold" }
    } else {
      "regular"
    }

    text(
      fill: if cover {
        utils.update-alpha(text.fill, alpha)
      } else {
        text.fill
      },
      size: fontSize,
      weight: weight,
      it
    )
  },
  ..args,
) = (
  context {
    // 起始页和结束页
    let start-page = 1
    let end-page = calc.inf
    if level != none {
      let current-heading = utils.current-heading(level: level)
      if current-heading != none {
        start-page = current-heading.location().page()
        if level != auto {
          let next-headings = query(
            selector(heading.where(level: level)).after(inclusive: false, current-heading.location()),
          )
          if next-headings != () {
            end-page = next-headings.at(0).location().page()
          }
        } else {
          end-page = start-page + 1
        }
      }
    }
    show outline.entry: it => transform(
      cover: it.element.location().page() < start-page or it.element.location().page() >= end-page,
      level: level,
      alpha: alpha,
      ..args,
      it,
    )

    outline(..args)
  }
)





/// Show a custom progressive outline.
///
/// - `self` is the self context.
///
/// - `alpha` is the transparency of the other headings. Default is `60%`.
///
/// - `level` is the level of the outline. Default is `auto`.
///
/// - `numbered` is a boolean array indicating whether the headings should be numbered. Default is `false`.
///
/// - `filled` is a boolean array indicating whether the headings should be filled. Default is `false`.
///
/// - `paged` is a boolean array indicating whether the headings should be paged. Default is `false`.
///
/// - `numbering` is an array of numbering strings for the headings. Default is `()`.
///
/// - `text-fill` is an array of colors for the text fill of the headings. Default is `none`.
///
/// - `text-size` is an array of sizes for the text of the headings. Default is `none`.
///
/// - `text-weight` is an array of weights for the text of the headings. Default is `none`.
///
/// - `vspace` is an array of vertical spaces above the headings. Default is `none`.
///
/// - `title` is the title of the outline. Default is `none`.
///
/// - `indent` is an array of indentations for the headings. Default is `(0em, )`.
///
/// - `fill` is an array of fills for the headings. Default is `repeat[.]`.
///
/// - `short-heading` is a boolean indicating whether the headings should be shortened. Default is `true`.
///
/// - `uncover-fn` is a function that takes the body of the heading and returns the body of the heading when it is uncovered. Default is the identity function.
///
/// - `..args` are the other arguments passed to the `progressive-outline` and `transform`.
#let custom-progressive-outline(
  self: none,
  alpha: 60%,
  level: auto,
  numbered: (false,),
  filled: (false,),
  paged: (false,),
  numbering: (),
  text-fill: none,
  text-size: none,
  text-weight: none,
  vspace: none,
  title: none,
  indent: (0em,),
  fill: (repeat[.],),
  short-heading: true,
  uncover-fn: body => body,
  ..args,
) = progressive-outline(
  alpha: alpha,
  level: level,
  transform: (cover: false, alpha: alpha, ..args, it) => {
    let array-at(arr, idx) = arr.at(idx, default: arr.last())
    let set-text(level, body) = {
      set text(fill: {
        let text-color = if type(text-fill) == array and text-fill.len() > 0 {
          array-at(text-fill, level - 1)
        } else {
          text.fill
        }
        if cover {
          utils.update-alpha(text-color, alpha)
        } else {
          text-color
        }
      })
      set text(
        size: array-at(text-size, level - 1),
      ) if type(text-size) == array and text-size.len() > 0
      set text(
        weight: array-at(text-weight, level - 1),
      ) if type(text-weight) == array and text-weight.len() > 0
      body
    }
    let body = {
      if type(vspace) == array and vspace.len() > it.level - 1 {
        v(vspace.at(it.level - 1))
      }
      h(range(1, it.level + 1).map(level => array-at(indent, level - 1)).sum())
      set-text(
        it.level,
        {
          if array-at(numbered, it.level - 1) {
            let current-numbering = numbering.at(it.level - 1, default: it.element.numbering)
            if current-numbering != none {
              _typst-builtin-numbering(
                current-numbering,
                ..counter(heading).at(it.element.location()),
              )
              h(.3em)
            }
          }
          link(
            it.element.location(),
            {
              if short-heading {
                utils.short-heading(self: self, it.element)
              } else {
                it.element.body
              }
              box(
                width: 1fr,
                inset: (x: .2em),
                if array-at(filled, it.level - 1) {
                  array-at(fill, level - 1)
                },
              )
              if array-at(paged, it.level - 1) {
                _typst-builtin-numbering(
                  if page.numbering != none {
                    page.numbering
                  } else {
                    "1"
                  },
                  ..counter(page).at(it.element.location()),
                )
              }
            },
          )
        },
      )
    }
    if cover {
      body
    } else {
      uncover-fn(body)
    }
  },
  title: title,
  ..args,
)


/// Show mini slides. It is usually used to show the navigation of the presentation in header.
///
/// - `self` is the self context, which is used to get the short heading of the headings.
///
/// - `fill` is the fill color of the headings. Default is `rgb("000000")`.
///
/// - `alpha` is the transparency of the headings. Default is `60%`.
///
/// - `display-section` is a boolean indicating whether the sections should be displayed. Default is `false`.
///
/// - `display-subsection` is a boolean indicating whether the subsections should be displayed. Default is `true`.
///
/// - `short-heading` is a boolean indicating whether the headings should be shortened. Default is `true`.
#let mini-slides(
  self: none,
  fill: rgb("000000"),           // 填充颜色，默认为黑色
  alpha: 60%,                    // 非当前章节的透明度
  display-section: false,        // 是否显示章节的幻灯片链接
  display-subsection: true,      // 是否显示子章节的幻灯片链接
  short-heading: true,           // 是否使用简短的标题
) = (
  context {
    // 查询所有一级和二级标题
    let headings = query(heading.where(level: 1).or(heading.where(level: 2)))
    // 过滤出一级标题（章节）
    let sections = headings.filter(it => it.level == 1)
    // 如果没有章节，直接返回
    if sections == () {
      return
    }
    // 获取第一个章节所在的页面编号
    let first-page = sections.at(0).location().page()
    // 过滤掉第一个章节之前的标题
    headings = headings.filter(it => it.location().page() >= first-page)
    // 查询幻灯片元数据，过滤出有效的幻灯片
    let slides = query(<touying-metadata>).filter(it => (
      utils.is-kind(it, "touying-new-slide") and it.location().page() >= first-page
    ))
    // 获取当前页面编号
    let current-page = here().page()
    // 计算当前章节的索引
    let current-index = sections.filter(it => it.location().page() <= current-page).len() - 1
    // 初始化用于存储列的数组
    let cols = ()
    let col = ()
    // 遍历标题，构建目录结构
    for (hd, next-hd) in headings.zip(headings.slice(1) + (none,)) {
      // 获取下一个标题的页面编号，如果没有则设为正无穷
      let next-page = if next-hd != none {
        next-hd.location().page()
      } else {
        calc.inf
      }
      // 如果是一级标题（章节）
      if hd.level == 1 {
        // 如果当前列不为空，将其添加到列数组中并重置
        if col != () {
          cols.push(align(left, col.sum()))
          col = ()
        }
        // 构建章节内容
        col.push({
          // 获取标题内容，可能是简短形式
          let body = if short-heading {
            utils.short-heading(self: self, hd)
          } else {
            hd.body
          }
          // 创建指向该章节的链接
          [#link(hd.location(), body)<touying-link>]
          linebreak()
          // 处理该章节下的幻灯片
          while slides.len() > 0 and slides.at(0).location().page() < next-page {
            let slide = slides.remove(0)
            if display-section {
              // 获取下一个幻灯片的页面编号
              let next-slide-page = if slides.len() > 0 {
                slides.at(0).location().page()
              } else {
                calc.inf
              }
              // 判断幻灯片是否为当前页面，并显示相应的圆形符号
              if slide.location().page() <= current-page and current-page < next-slide-page {
                [#link(slide.location(), sym.circle.filled)<touying-link>]
              } else {
                [#link(slide.location(), sym.circle)<touying-link>]
              }
            }
          }
          // 如果需要显示章节和子章节，添加换行
          if display-section and display-subsection {
            linebreak()
          }
        })
      } else {
        // 如果是二级标题（子章节）
        col.push({
          // 处理该子章节下的幻灯片
          while slides.len() > 0 and slides.at(0).location().page() < next-page {
            let slide = slides.remove(0)
            if display-subsection {
              // 获取下一个幻灯片的页面编号
              let next-slide-page = if slides.len() > 0 {
                slides.at(0).location().page()
              } else {
                calc.inf
              }
              // 判断幻灯片是否为当前页面，并显示相应的圆形符号
              if slide.location().page() <= current-page and current-page < next-slide-page {
                [#link(slide.location(), sym.circle.filled)<touying-link>]
              } else {
                [#link(slide.location(), sym.circle)<touying-link>]
              }
            }
          }
          // 如果需要显示子章节，添加换行
          if display-subsection {
            linebreak()
          }
        })
      }
    }
    // 将最后一个列添加到列数组中
    if col != () {
      cols.push(align(left, col.sum()))
      col = ()
    }

    // 自适应字号计算
    let num_sections = sections.len()       // 章节数量
    let max_size = .5em                     // 最大字号
    let min_size = .3em                     // 最小字号
    let size_range = max_size - min_size    // 字号范围
    let max_sections = 3                    // 章节数量小于等于3时使用最大字号

    // 计算非当前章节的字号
    let computed_size = if num_sections <= max_sections {
      max_size
    } else {
      let size = max_size - (num_sections - max_sections) * (size_range / (num_sections - 1))
      // 确保字号不小于最小字号
      if size < min_size {
        min_size
      } else {
        size
      }
    }
    let small-size = computed_size          // 非当前章节的字号

    // 计算当前章节的字号，比非当前章节大一些
    let large-size = small-size + .1em      // 当前章节的字号

    // 设置各章节的显示样式
    if current-index < 0 or current-index >= cols.len() {
      // 如果当前索引无效，所有章节都使用非当前章节的样式
      cols = cols.map(body => text(fill: fill, size: small-size, body))
    } else {
      // 遍历所有章节
      cols = cols.enumerate().map(pair => {
        let (idx, body) = pair
        if idx == current-index {
          // 当前章节，使用较大字号和正常颜色
          text(fill: fill, size: large-size, body)
        } else {
          // 非当前章节，使用较小字号和透明度处理的颜色
          text(fill: utils.update-alpha(fill, alpha), size: small-size, body)
        }
      })
    }
    // 设置对齐方式为顶部对齐
    set align(top)
    // 设置显示块的内边距
    show: block.with(inset: (top: .5em, x: 2em))
    // 调整换行符的垂直偏移，减少行间距
    show linebreak: it => it + v(-1em)
    // 创建网格布局，排列各章节列
    grid(columns: cols.map(_ => auto).intersperse(1fr), ..cols.intersperse([]))
  }
)







#let simple-navigation(
  self: none,
  short-heading: true,
  primary: white,
  secondary: gray,
  background: black,
  logo: none,
) = (
  context {
    let body() = {
      let sections = query(heading.where(level: 1))
      if sections.len() == 0 {
        return
      }
      let current-page = here().page()
      set text(size: 0.5em)
      for (section, next-section) in sections.zip(sections.slice(1) + (none,)) {
        set text(fill: if section.location().page() <= current-page and (
          next-section == none or current-page < next-section.location().page()
        ) {
          primary
        } else {
          secondary
        })
        box(inset: 0.5em)[#link(
            section.location(),
            if short-heading {
              utils.short-heading(self: self, section)
            } else {
              section.body
            },
          )<touying-link>]
      }
    }
    block(
      fill: background,
      inset: 0pt,
      outset: 0pt,
      grid(
        align: center + horizon,
        columns: (1fr, auto),
        rows: 1.8em,
        gutter: 0em,
        cell(
          fill: background,
          body(),
        ),
        block(fill: background, inset: 4pt, height: 100%, text(fill: primary, logo)),
      ),
    )
  }
)


/// LaTeX-like knob marker for list
///
/// Example: `#set list(marker: components.knob-marker(primary: rgb("005bac")))`
#let knob-marker(primary: rgb("#005bac")) = box(
  width: 0.5em,
  place(
    dy: 0.1em,
    circle(
      fill: gradient.radial(
        primary.lighten(100%),
        primary.darken(40%),
        focal-center: (30%, 30%),
      ),
      radius: 0.25em,
    ),
  ),
)