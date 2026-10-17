/*
 * equationx.typ
 *
 * 公式环境：按章节编号，并根据标签位置决定整式编号或逐行编号。
 *   - <label> 位于 $$ 外（挂在整式上）：无论多少行，只显示一个编号；
 *   - 无 <label> 或 <label> 在 $$ 内部（挂在某一行上）：每行都编号；
 *   - 行尾加 <revoke>（兼容 <equate:revoke>）：该行不编号。
 * 标签自动添加前缀（默认 "eq:"）：公式里写 <foo>，引用时用 @eq:foo；
 * 若标签本身已带前缀则不重复添加。
 *
 * 行拆分、定界符拉伸、对齐与断行布局参考自 equate
 * (MIT License, Copyright (c) 2024-2026 Eric Biedert)。
 */

#import "@preview/unichar:0.4.1"

// 内置 numbering 函数的别名（参数 numbering 为编号模式字符串，会遮蔽内置函数）
#let _typst-numbering = numbering

// 允许的“本行不编号”标签（行尾 raw 文本，含尖括号）
#let revoke-labels = ("<revoke>", "<equate:revoke>")

// 若标签名未带前缀，则补上前缀
#let prefixed-label(name, label-prefix) = if name.starts-with(label-prefix) {
  name
} else {
  label-prefix + name
}

// ---- 基础元素 ----
#let align-point = $&$.body.func()
#let sequence = $a b$.body.func()
#let counter-update = counter(math.equation).update(1).func()

// ---- 以下实现复制自 equate，仅重命名内部状态 ----
#let replace-lr(eq) = {
  let equation(body) = [
    #math.equation(
      block: true,
      numbering: none,
      body,
    ) <revoke>
  ]

  let height(body) = measure(equation(body)).height

  let children = if eq.body.func() == sequence {
    eq.body.children
  } else {
    (eq.body,)
  }

  let replace-single(child) = {
    if type(child) != content or child.func() != math.lr {
      child
    } else {
      // Unwrap nested lr elements (e.g. `lr(size: #2em, (a + b))`)
      let lr-size = child.fields().at("size", default: 100%)
      if child.body.func() == math.lr {
        child = child.body
        if child.has("size") { lr-size = child.size }
      }

      let lines = if child.body.func() == sequence {
        child.body.children.split(linebreak())
      } else {
        ((child.body,),)
      }

      let (first, ..mid, last) = if child.body.func() == sequence {
        if child.body.children == () {
          return none
        }
        child.body.children
      } else {
        ([], child.body, [])
      }

      let size = calc.max(..lines.map(line => {
        height(math.lr(size: lr-size, first + line.join() + last))
      }))

      // Manually stretch first/last and mid elements.
      let stretched(first, mid, last, size) = {
        let stretch-if-delimiter(elem, apply) = {
          let class = if elem.has("class") {
            elem.class
          } else if elem.has("text") and elem.text.len() == 1 {
            unichar.codepoint(elem.text).math-class
          }

          if class in ("opening", "fence", "closing") {
            elem = math.class(apply, math.stretch(size: size, elem))
          }

          elem
        }

        if first != none {
          stretch-if-delimiter(first, "opening")
        }
        mid
          .map(child => if child.func() == math.mid {
            math.class("relation", math.stretch(size: size, child))
          } else {
            replace-single(child)
          })
          .join()
        if last != none {
          stretch-if-delimiter(last, "closing")
        }
      }

      // Take possible short-fall into account. We may need multiple iterations
      // to ensure that the stretched height matches the original height, and
      // that the middle elements are stretched to the same size.
      let shortfall = 0pt
      for i in range(5) {
        let delta = (
          calc.max(..lines.map(line => {
            height(stretched(first, line, last, size - shortfall))
          }))
            - size
        )

        if delta == 0pt { break }
        shortfall += delta
      }

      stretched(first, mid, last, size - shortfall)
    }
  }

  math.equation(children.map(replace-single).join())
}

// Unpack nested equations.
#let unpack-nested(eq) = {
  let unpack-single(child) = {
    if type(child) == content and child.func() == math.equation {
      unpack-nested(child).body
    } else {
      child
    }
  }

  if eq.body.func() == sequence {
    math.equation(eq.body.children.map(unpack-single).join())
  } else {
    math.equation(unpack-single(eq.body))
  }
}

// Extract lines and trim spaces.
#let to-lines(equation) = {
  equation = replace-lr(equation)
  equation = unpack-nested(equation)

  let lines = if equation.body.func() == sequence {
    equation.body.children.split(linebreak())
  } else {
    ((equation.body,),)
  }

  // Trim spaces at begin and end of line.
  let lines = lines
    .filter(line => line != ())
    .map(line => {
      if line.first() == [ ] and line.last() == [ ] {
        line.slice(1, -1)
      } else if line.first() == [ ] {
        line.slice(1)
      } else if line.last() == [ ] {
        line.slice(0, -1)
      } else {
        line
      }
    })

  lines
}

// Layout a single equation line with the given number.
#let layout-line(
  number: none,
  number-align: none,
  number-width: auto,
  text-dir: auto,
  line,
) = context {
  let equation(body, measure: false) = [
    // We may need to measure the width of the equation, so it has to be auto.
    #show math.equation: set block(width: auto) if measure
    #math.equation(
      block: true,
      numbering: _ => none,
      body,
    ) <revoke>
  ]

  // Short circuit if no number has to be added.
  if number == none {
    return equation(line.join())
  }

  // Short circuit if number is a counter update.
  if type(number) == content and number.func() == counter-update {
    return {
      number
      equation(line.join())
    }
  }

  // Resolve number width.
  let number-width = if number-width == auto {
    measure(number).width
  } else {
    number-width
  }

  // Resolve equation alignment in x-direction.
  let equation-align = if align.alignment.x in (left, center, right) {
    align.alignment.x
  } else if text-dir == ltr {
    if align.alignment.x == start { left } else { right }
  } else if text-dir == rtl {
    if align.alignment.x == start { right } else { left }
  }

  // Add numbers to the equation body, so that they are aligned at their
  // respective baselines. If the equation is centered, the number is put
  // on both sides of the equation to keep the center alignment.

  let num = box(width: number-width, align(number-align, number))
  let line-width = measure(equation(line.join(), measure: true)).width
  let gap = 0.5em

  layout(bounds => {
    let space = if bounds.width.pt().is-infinite() {
      // If we're in an unbounded container, the number is placed right next to
      // the equation body, with only the `gap` as spacing.
      0pt
    } else if equation-align == center {
      bounds.width - line-width - 2 * number-width
    } else {
      bounds.width - line-width - number-width
    }

    let body = if number-align.x == left {
      if equation-align == center {
        h(-gap) + num + h(space / 2 + gap) + line.join() + h(space / 2) + hide(num)
      } else if equation-align == right {
        num + h(space + 2 * gap) + line.join()
      } else {
        h(-gap) + num + h(gap) + line.join() + h(space + gap)
      }
    } else {
      if equation-align == center {
        hide(num) + h(space / 2) + line.join() + h(space / 2 + gap) + num + h(-gap)
      } else if equation-align == right {
        h(space + gap) + line.join() + h(gap) + num + h(-gap)
      } else {
        line.join() + h(space + 2 * gap) + num
      }
    }

    equation(body)
  })
}

// State for tracking the shared alignment block we're in.
#let share-align-state = state("equationx/share-align", (stack: (), max: 0))

// State for tracking whether we're in a nested equation.
#let nested-state = state("equationx/nested-depth", 0)

// Splitting an equation into multiple lines breaks the inbuilt alignment
// with alignment points, so it is emulated here by adding spacers manually.
#let realign(lines) = {
  // Utility shorthand for unnumbered block equation.
  let equation(body) = [
    // We need this for measuring the width, so it has to be auto.
    #show math.equation: set block(width: auto)
    #math.equation(
      block: true,
      numbering: none,
      body,
    ) <revoke>
  ]

  // Consider lines of other equations in shared alignment block.
  let extra-lines = if share-align-state.get().stack != () {
    let num = share-align-state.get().stack.last()
    let align-state = state("equationx/align/" + str(num), ())
    remove-labels(align-state.final())
  } else {
    ()
  }

  let lines = extra-lines + lines

  // Short-circuit if no alignment points.
  if lines.all(line => align-point() not in line) {
    return lines.slice(extra-lines.len())
  }

  // Store widths of each part between alignment points.
  let part-widths = lines.map(line => {
    line.split(align-point()).map(part => measure(equation(part.join())).width)
  })

  // Get maximum width of each part.
  let part-widths = for i in range(calc.max(..part-widths.map(points => points.len()))) {
    (calc.max(..part-widths.map(line => line.at(i, default: 0pt))),)
  }

  // Get maximum width of each slice of parts.
  let max-slice-widths = array
    .zip(..lines.map(line => range(part-widths.len()).map(i => {
      let parts = line.split(align-point()).map(array.join)
      if i >= parts.len() {
        0pt
      } else {
        let slice = parts.slice(0, i + 1).join()
        measure(equation(slice)).width
      }
    })))
    .map(widths => calc.max(..widths))

  // Add spacers for each part, so that the part widths are the same for all lines.
  let lines = lines.map(line => {
    line
      .split(align-point())
      .enumerate()
      .map(((i, part)) => {
        // Add spacer to make part the correct width.
        let width-diff = part-widths.at(i) - measure(equation(part.join())).width
        let spacing = if width-diff > 0pt { h(0pt) + box(fill: yellow, width: width-diff) + h(0pt) }

        if calc.even(i) {
          spacing + part.join() // Right align.
        } else {
          part.join() + spacing // Left align.
        }
      })
      .intersperse(align-point())
  })

  // Update maximum slice widths to include spacers.
  let max-slice-widths = array
    .zip(..lines.map(line => range(part-widths.len()).map(i => {
      let parts = line.split(align-point()).map(array.join)
      if i >= parts.len() {
        0pt
      } else {
        let slice = parts.slice(0, i + 1).join()
        calc.max(max-slice-widths.at(i), measure(equation(slice)).width)
      }
    })))
    .map(widths => calc.max(..widths))

  // Add spacers between parts to ensure correct spacing with combined parts.
  lines = for line in lines {
    let parts = line.split(align-point()).map(array.join)
    for i in range(max-slice-widths.len()) {
      if i >= parts.len() {
        break
      }
      let slice = parts.slice(0, i).join() + h(0pt) + parts.at(i)
      let slice-width = measure(equation(slice)).width
      if slice-width < max-slice-widths.at(i) {
        parts.at(i) = h(0pt) + box(fill: green, width: max-slice-widths.at(i) - slice-width) + h(0pt) + parts.at(i)
      }
    }
    (parts,)
  }

  // Append remaining spacers at the end for lines that have less align points.
  let line-widths = lines.map(line => measure(equation(line.join())).width)
  let max-line-width = calc.max(..line-widths)
  lines = lines
    .zip(line-widths)
    .map(((line, line-width)) => {
      if line-width < max-line-width {
        line.push(h(0pt) + box(fill: red, width: max-line-width - line-width))
      }
      line
    })

  lines.slice(extra-lines.len())
}

// Remove labels from lines, so that they don't interfere when measuring.
#let remove-labels(lines) = {
  lines.map(line => {
    if line.len() == 0 { return line }
    if line.last().func() != raw { return line }
    if line.last().lang != "typc" { return line }
    if line.last().text.match(regex("^<.+>$")) == none { return line }

    let _ = line.remove(-1)
    let _ = if line.at(-1, default: none) == [ ] { line.remove(-1) }
    line
  })
}

// ---- 标签策略 ----
// 返回 (numbered, revoked, lines, block-mode)：
// - numbered：显示编号的行下标（block-mode 下只有最后一行）；
// - revoked：不编号的行下标；
// - lines：内层标签已替换为带编号元数据的 figure；
// - block-mode：整式是否只有一个编号。
#let replace-labels(
  lines,
  numbering,
  supplement,
  has-label,
  heading,
  main,
  label-prefix,
) = {
  // Indices of lines that contain a label.
  let labelled = lines
    .enumerate()
    .filter(((i, line)) => {
      if line.len() == 0 { return false }
      if line.last().func() != raw { return false }
      if line.last().lang != "typc" { return false }
      if line.last().text.match(regex("^<.+>$")) == none { return false }
      return true
    })
    .map(((i, _)) => i)

  // Indices of lines that are marked not to be numbered.
  let revoked = lines
    .enumerate()
    .filter(((i, line)) => {
      if i not in labelled { return false }
      return line.last().text in revoke-labels
    })
    .map(((i, _)) => i)

  // The "revoke" label shall not count as a labelled line.
  let labelled = labelled.filter(i => i not in revoked)

  // 标签策略：整式外层标签 -> 只显示一个编号；否则每行编号。
  let block-mode = has-label
  let numbered = if block-mode {
    if lines.len() == 0 { () } else { (lines.len() - 1,) }
  } else {
    range(lines.len()).filter(i => i not in revoked)
  }

  let lines = lines
    .enumerate()
    .map(((i, line)) => {
      if i in revoked {
        // Remove "revoke" label and space and return line.
        let _ = line.remove(-1)
        let _ = if line.at(-2, default: none) == [ ] { line.remove(-2) }
        return line
      }

      if i not in labelled { return line }

      // Remove trailing spacing (before label).
      let _ = if line.at(-2, default: none) == [ ] { line.remove(-2) }

      // 该行引用的编号：(章号, 公式号)。
      let nums = if block-mode {
        (heading, main)
      } else {
        (heading, main + numbered.position(n => n == i))
      }

      // 使用 figure 保存编号元数据，使该行可被引用。
      line.at(-1) = [#figure(
          metadata(nums),
          kind: math.equation,
          numbering: numbering,
          supplement: supplement,
        )#label(prefixed-label(line.last().text.slice(1, -1), label-prefix))]

      line
    })

  (numbered, revoked, lines, block-mode)
}

// 处理公式引用（整式或子公式行），非公式引用返回 none。
#let equationx-ref(it, default-numbering: "(1.1)") = {
  if it.element == none {
    return none
  }
  let f = it.element.func()
  let is-line = (
    f == figure and it.element.kind == math.equation and it.element.body != none and it.element.body.func() == metadata
  )
  if f != math.equation and not is-line {
    return none
  }

  if f == math.equation {
    // 整式引用：编号模式取目标公式自身的 numbering（正文/附录各自设置），
    // 章号与公式号按目标位置取计数器，跨章引用也不会错。
    let location = it.element.location()
    let pattern = if it.element.numbering != none {
      it.element.numbering
    } else {
      default-numbering
    }
    return link(
      it.target,
      it.element.supplement
        + [ ]
        + _typst-numbering(
          pattern,
          counter(heading).at(location).at(0),
          counter(math.equation).at(location).at(0),
        ),
    )
  }

  // 子公式行引用：编号直接来自 figure 的 metadata 与 numbering
  link(
    it.target,
    it.element.supplement + [ ] + _typst-numbering(it.element.numbering, ..it.element.body.value),
  )
}

// 主函数：设置章节编号、整式/逐行编号、断行与引用。
#let equationx(
  numbering: "(1.1)",
  breakable: true,
  reset: 1,
  label-prefix: "eq:",
  body,
) = {
  // 保证块级公式会步进计数器（numbering 非 none）
  set math.equation(numbering: numbering)

  // 按章重置公式计数器（show 规则需在函数顶层注册，不能在 if 块内声明）
  show heading.where(level: if type(reset) == int { reset } else { 1 }): it => {
    if type(reset) == int {
      [#counter(math.equation).update(0) #it]
    } else {
      it
    }
  }

  show math.equation.where(block: true): set block(breakable: breakable) if type(breakable) == bool

  // 隐藏承载编号元数据的 figure（行内标签与整式引用载体）
  show figure.where(kind: math.equation): it => {
    if it.body != none and it.body.func() == metadata {
      none
    } else {
      it
    }
  }

  show math.equation.where(block: true): it => {
    // 整式退出：使用 <revoke> 标签恢复默认行为
    if it.has("label") and ("<" + str(it.label) + ">") in revoke-labels {
      return it
    }
    if it.numbering == none {
      return it
    }

    // 主公式编号（已包含原公式自身的步进）
    let main = counter(math.equation).get().first()
    let heading = counter(heading).get().first()

    let (numbered, revoked, lines, block-mode) = replace-labels(
      to-lines(it),
      numbering,
      it.supplement,
      it.has("label"),
      heading,
      main,
      label-prefix,
    )

    // 整式（外层标签）的引用载体：标签名自动加前缀。
    // 若标签已带前缀，则直接引用原公式自身（避免重复标签）。
    let carrier = if it.has("label") and not str(it.label).starts-with(label-prefix) {
      [
        #figure(
          metadata((heading, main)),
          kind: math.equation,
          numbering: numbering,
          supplement: it.supplement,
        )#label(label-prefix + str(it.label))
      ]
    } else {
      []
    }

    // Resolve text direction.
    let text-dir = if text.dir == auto {
      if (
        text.lang
          in (
            "ar",
            "dv",
            "fa",
            "he",
            "ks",
            "pa",
            "ps",
            "sd",
            "ug",
            "ur",
            "yi",
          )
      ) { rtl } else { ltr }
    } else {
      text.dir
    }

    // Resolve number position in x-direction.
    let number-align = if it.number-align.x in (left, right) {
      it.number-align.x
    } else if text-dir == ltr {
      if it.number-align.x == start { left } else { right }
    } else if text-dir == rtl {
      if it.number-align.x == start { right } else { left }
    }

    // 单行公式：直接布局一行
    if lines.len() == 1 {
      let number = if 0 in numbered {
        _typst-numbering(numbering, heading, main)
      } else {
        none
      }
      return [
        #layout-line(
          lines.first(),
          number: number,
          number-align: number-align,
          text-dir: text-dir,
        )
        // 原公式已步进一次，布局行再步进一次，这里退回一步
        #counter(math.equation).update(n => n - 1)
        #carrier
      ]
    }

    // 该公式消耗的编号个数
    let consumed = if block-mode { 1 } else { numbered.len() }

    // Calculate maximum width of all numberings in this equation.
    let max-number-width = calc.max(0pt, ..numbered.map(i => {
      let eq = if block-mode { main } else { main + numbered.position(n => n == i) }
      measure(_typst-numbering(numbering, heading, eq)).width
    }))

    let result = if block-mode {
      // 整式编号：所有行只显示一个编号，垂直居中于整个公式块。
      let num = _typst-numbering(numbering, heading, main)
      let grid-content = block(grid(
        columns: 1,
        row-gutter: par.leading,
        ..realign(lines)
          .enumerate()
          .map(((i, line)) => {
            // 各行都预留编号宽度（隐藏），保持与逐行编号一致的排版；
            // 真正显示的编号由下方的 place 垂直居中放置。
            let number = if i in revoked {
              counter(math.equation).update(n => n - 1)
            } else {
              hide(box(width: max-number-width))
            }
            layout-line(
              line,
              number: number,
              number-align: number-align,
              number-width: max-number-width,
              text-dir: text-dir,
            )
          })
      ))

      layout(bounds => {
        let height = measure(grid-content).height
        block(
          width: bounds.width,
          height: height,
        )[
          #grid-content
          #place(horizon + right, box(width: max-number-width, align(number-align, num)))
        ]
      })
    } else {
      // Layout equation as grid to allow page breaks.
      block(grid(
        columns: 1,
        row-gutter: par.leading,
        ..realign(lines)
          .enumerate()
          .map(((i, line)) => {
            let number = if i in numbered {
              _typst-numbering(numbering, heading, main + numbered.position(n => n == i))
            } else if i in revoked {
              // 该行不编号：退回其步进的计数
              counter(math.equation).update(n => n - 1)
            } else {
              none
            }

            layout-line(
              line,
              number: number,
              number-align: number-align,
              number-width: max-number-width,
              text-dir: text-dir,
            )
          })
      ))
    }

    [
      #result
      #carrier
      // 每行布局都会步进一次计数器（revoke 行已退回），
      // 这里再调整，使整个公式净消耗 consumed 个编号。
      #counter(math.equation).update(n => n + consumed - 1 - lines.len() + revoked.len())
    ]
  }

  // 公式引用
  show ref: it => {
    if it.element == none {
      return it
    }
    let eq = equationx-ref(it, default-numbering: numbering)
    if eq != none {
      return eq
    }
    it
  }

  body
}
