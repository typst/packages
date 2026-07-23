#import "../tools/lib.typ": *
#import "info.typ": *
#import "font.typ": *
#import "word_spacing.typ": (
  above-leading-space, below-leading-space, heading-1, heading-2, heading-3, heading-4, word-below-leading-space,
  word-leading-space,
)

#let supplement-中文摘要 = "中文摘要"
#let supplement-英文摘要 = "英文摘要"
#let supplement-目录 = "目录"
#let supplement-图目录 = "图目录"
#let supplement-表目录 = "表目录"
#let supplement-正文 = "正文"
#let supplement-致谢 = "致谢"
#let supplement-附录 = "附录"
#let supplement-参考文献 = "参考文献"
#let supplement-攻读学位期间取得成果 = "攻读学位期间取得成果"

// --- 定义状态变量 ---
#let last-heading-level = state("last-heading-info", (level: 0, excess: 0pt))

#let set-global-heading(info, body) = {
  // --- 1. 状态重置机制 ---
  // 遇到正文、图表、公式时，标记"上一个元素不是标题"
  show par: it => {
    last-heading-level.update((level: 0, excess: 0pt))
    it
  }
  show figure: it => {
    last-heading-level.update((level: 0, excess: 0pt))
    it
  }
  show math.equation.where(block: true): it => {
    last-heading-level.update((level: 0, excess: 0pt))
    it
  }
  show list: it => {
    last-heading-level.update((level: 0, excess: 0pt))
    it
  }
  show enum: it => {
    last-heading-level.update((level: 0, excess: 0pt))
    it
  }

  // --- 2. 一级标题 (通常强制分页，只需更新状态) ---
  show heading.where(level: 1): it => context {
    // 一级标题强制分页，不需要判断 above 为 0，但需要更新状态供二级标题检测
    pagebreak(weak: false)
    last-heading-level.update((level: 1, excess: heading-1.below - below-leading-space(heading-1.below)))

    set text(size: font-size.小三, font: get-hei-font(info))
    set align(center)
    if it.numbering != none {
      block(
        width: 100%,
        above: heading-1.above,
        below: below-leading-space(heading-1.below),
        sticky: true,
        inset: (top: heading-1.above),
      )[
        #counter(heading).display(it.numbering)#h(0.5em)#it.body
      ]
    } else {
      v(heading-1.above)
      it
      v(heading-1.below)
    }
  }

  // --- 3. 二级标题 (需要判断是否紧跟一级标题) ---
  show heading.where(level: 2): it => context {
    let prev-level = last-heading-level.get().level
    // 如果上一个是标题，则段前为 0；否则使用默认值
    let spacing-above = if prev-level > 0 { 0pt } else { above-leading-space(space: heading-2.above) }

    // 渲染前先更新状态 (放在 block 后面也行，但 context 内通常顺序执行)
    last-heading-level.update((level: 2, excess: heading-2.below - below-leading-space(heading-2.below)))

    set align(left)
    set text(size: font-size.四号, font: get-hei-font(info))

    if last-heading-level.get().excess != 0pt {
      v(last-heading-level.get().excess + above-leading-space())
    }
    block(
      width: 100%,
      above: spacing-above, // <--- 应用动态间距
      sticky: true,
      below: below-leading-space(heading-2.below),
    )[
      #if it.numbering == none {
        [#it.body]
      } else {
        [#counter(heading).display(it.numbering)#h(0.5em)#it.body]
      }
    ]
  }

  // --- 4. 三级标题 (需要判断是否紧跟二级标题) ---
  show heading.where(level: 3): it => context {
    let prev-level = last-heading-level.get().level
    let spacing-above = if prev-level > 0 { 0pt } else { above-leading-space(space: heading-3.above) }

    last-heading-level.update((level: 3, excess: heading-3.below - below-leading-space(heading-3.below)))

    set align(left)
    set text(size: font-size.四号, font: get-hei-font(info))
    if last-heading-level.get().excess != 0pt {
      v(last-heading-level.get().excess + above-leading-space())
    }
    block(
      width: 100%,
      above: spacing-above, // <--- 应用动态间距
      sticky: true,
      below: below-leading-space(heading-3.below),
    )[
      #counter(heading).display(it.numbering)#h(0.5em)#it.body
    ]
  }

  // --- 5. 四级标题 ---
  show heading.where(level: 4): it => context {
    let prev-level = last-heading-level.get().level
    let spacing-above = if prev-level > 0 { 0pt } else { above-leading-space(space: heading-4.above) }

    last-heading-level.update((level: 4, excess: heading-4.below - below-leading-space(heading-4.below)))

    set align(left)
    set text(size: font-size.小四, font: get-hei-font(info))
    if last-heading-level.get().excess != 0pt {
      v(last-heading-level.get().excess + above-leading-space())
    }
    block(
      width: 100%,
      above: spacing-above, // <--- 应用动态间距
      sticky: true,
      below: below-leading-space(heading-4.below),
    )[
      #counter(heading).display(it.numbering)#h(0.5em)#it.body
    ]
  }

  body
}

#let set-中文摘要-heading(body) = {
  set heading(supplement: supplement-中文摘要, numbering: none, outlined: false)
  body
}

#let set-英文摘要-heading(body) = {
  set heading(supplement: supplement-英文摘要, numbering: none, outlined: false)
  body
}

#let set-目录-heading(body) = {
  set heading(supplement: supplement-目录, numbering: none, outlined: false)
  body
}

#let set-图目录-heading(body) = {
  set heading(supplement: supplement-图目录, numbering: none, outlined: false)
  body
}

#let set-表目录-heading(body) = {
  set heading(supplement: supplement-表目录, numbering: none, outlined: false)
  body
}

#let set-正文-heading(body) = {
  set heading(supplement: supplement-正文, outlined: true)
  set heading(
    numbering: (..nums) => {
      let n = nums.pos().len()
      if n == 1 {
        numbering("第一章", ..nums)
      } else {
        numbering("1.1.1.1", ..nums)
      }
    },
  )
  body
}

#let set-致谢-heading(body) = {
  set heading(supplement: supplement-致谢, numbering: none, outlined: true)
  body
}

#let set-附录-heading(body) = {
  set heading(supplement: supplement-附录, outlined: true)
  set heading(
    numbering: (..nums) => {
      let n = nums.pos().len()
      if n == 1 {
        numbering("附录A", ..nums)
      } else {
        numbering("1.1.1", ..nums)
      }
    },
  )
  body
}

#let set-参考文献-heading(body) = {
  set heading(supplement: supplement-参考文献, numbering: none, outlined: true)
  body
}

#let set-攻读学位期间获取成果-heading(body) = {
  set heading(supplement: supplement-参考文献, numbering: none, outlined: true)
  body
}
