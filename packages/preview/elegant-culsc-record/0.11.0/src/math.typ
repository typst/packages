// math.typ

#import "fontset.typ": *

// 创建全局状态来存储字体配置
#let _text-fonts-state = state("text-fonts", none)
#let _math-fonts-state = state("math-fonts", none)

/// 移除公式编号函数
#let notag(eq) = {
  set math.equation(numbering: none)
  eq
}

/// 应用数学字体规则
#let apply-math-font-rules(doc, math-fonts) = context {

  set math.equation(numbering: n => [(#n)])

  show math.equation: set text(font: math-fonts.main)
  
  // 设置中文上下标为正文字体
  show math.equation: it => {
    show text: set text(font: math-fonts.text)
    it
  }

  // 空心体字符全局字体设置
  show: it => context {
    // 直接匹配 Unicode 字符（全局生效，包括数学环境）
    // 空心字母和数字的完整 Unicode 范围
    show regex("[\u{2102}\u{210D}\u{2115}\u{2119}\u{211A}\u{211D}\u{2124}\u{1D538}-\u{1D59F}\u{1D7D8}-\u{1D7E1}]"): set text(font: math-fonts.blackboard)
    it
  }

  // 积分号字体设置
  show sym.integral: it => context {
    text(font: math-fonts.integral, it)
  }
  
  show sym.integral.double: it => context {
    text(font: math-fonts.integral, it)
  }
  
  show sym.integral.triple: it => context {
    text(font: math-fonts.integral, it)
  }
  
  show sym.integral.cont: it => context {
    text(font: math-fonts.integral, it)
  }
  
  show sym.integral.surf: it => context {
    text(font: math-fonts.integral, it)
  }
  
  show sym.integral.vol: it => context {
    text(font: math-fonts.integral, it)
  }
  
  show sym.integral.ccw: it => context {
    text(font: math-fonts.integral, it)
  }
  
  show sym.integral.cw: it => context {
    text(font: math-fonts.integral, it)
  }
  
  doc
}

/// 应用数学符号样式规则
#let apply-math-symbol-rules(doc, text-fonts) = context {
  
  // 设置 ≥ 和 ≤ 一律使用倾斜版本
  show math.equation: it => {
    show sym.lt.eq: sym.lt.eq.slant
    show sym.gt.eq: sym.gt.eq.slant
    it
  }

  // 省略号默认居中
  show math.equation: it => {
    show math.dots: math.dots.c  // dots 默认行为改为居中
    show "…": math.dots.c        // 数学模式中的 … 映射到 dots.c
    show "……": math.dots.c       // 数学模式中的 …… 映射到 dots.c
    it
  }

  // 间隔点设置
  // 文本模式中用宋体（这里保持原有逻辑，之后在主文件中会被文本字体覆盖）
  show "·": text.with(font: text-fonts.serif)
  
  // 数学模式中回到默认
  show math.equation: it => {
    show "·": "·"
    it
  }
  
  doc
}

/// 应用特殊文本符号规则
#let apply-text-symbol-rules(doc, text-fonts) = context {
  
  // 摄氏度符号
  show "℃": text.with(font: text-fonts.en, size: 1.2em)

  // 省略号（文本模式）
  show "……": text.with(font: text-fonts.serif)
  
  // 间隔点（文本模式）
  show "·": text.with(font: text-fonts.serif)
  
  doc
}

/// 重定义命令
/// 设置英文斜体为正文字体
#let italic(x, text-fonts) = context {
  text(font: (text-fonts.en, text-fonts.serif), style: "italic", x)
}

/// 偏微分符号（正体）
#let partial = $upright(partial)$

#let diff = $upright(partial)$

/// 平行符号（使用宋体）
#let parallel(text-fonts) = context {
  text(font: text-fonts.serif, sym.parallel)
}

/// 空心体
#let bb(x) = context {
  let math-fonts = _math-fonts-state.get()
  text(font: math-fonts.blackboard, math.bb(x))
}

/// 花体
#let cal(x) = context {
  let math-fonts = _math-fonts-state.get()
  text(font: math-fonts.calligraphic, math.cal(x))
}

/// 有限增量符号 Δ（正体，使用 Unicode U+2206）
#let increment = $\u{2206}$

/// 实部（罗马体）
#let Re = math.op("Re")

/// 虚部（罗马体）
#let Im = math.op("Im")

/// nabla 算子用正粗体
#let nabla = math.bold(math.upright(sym.nabla))

/// 应用所有数学排版规则
#let gb-math-style(doc, text-fonts, math-fonts) = {
  _text-fonts-state.update(text-fonts)
  _math-fonts-state.update(math-fonts)
  let result = doc
  result = apply-math-font-rules(result, math-fonts)
  result = apply-math-symbol-rules(result, text-fonts)
  result = apply-text-symbol-rules(result, text-fonts)
  result
}
