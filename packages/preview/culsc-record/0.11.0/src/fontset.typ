// fontset.typ

/// 文本字体集配置
#let text-fontsets = (
  windows: (
    sans: "SimHei",                    // 黑体
    serif: "SimSun",                   // 宋体
    en: "Times New Roman",             // 英文
  ),
  macos: (
    sans: "Heiti SC",                  // 黑体
    serif: "Songti SC",                // 宋体
    en: "Times New Roman",             // 英文
  ),
  web: (
    sans: "Noto Sans CJK SC",          // 黑体
    serif: "Noto Serif CJK SC",        // 宋体
    en: "TeX Gyre Termes",             // 英文
  ),
)

/// 数学字体集配置
#let math-fontsets = (
  recommend: (
    main: (
      "XITS Math",
      "TeX Gyre Termes Math",
      "STIX Two Math",
      "New Computer Modern Math",
    ),
    text: (
      "Times New Roman",
      "SimSun"
    ),
    blackboard: (
      "TeX Gyre Termes Math",
      "New Computer Modern Math",
      "XITS Math",
      "STIX Two Math",
    ),
    calligraphic: (
      "XITS Math",
      "New Computer Modern Math",
      "TeX Gyre Termes Math",
      "STIX Two Math",
    ),
    integral: (
      "Euler Math",
      "TeX Gyre Termes Math",
      "XITS Math",
      "STIX Two Math",
      "New Computer Modern Math",
    ),
  ),
  web: (
    main: (
      "TeX Gyre Termes Math",
      "STIX Two Math",
      "New Computer Modern Math",
    ),
    text: (
      "TeX Gyre Termes",
      "Noto Serif CJK SC"
    ),
    blackboard: (
      "TeX Gyre Termes Math",
      "New Computer Modern Math",
      "STIX Two Math",
    ),
    calligraphic: (
      "New Computer Modern Math",
      "TeX Gyre Termes Math",
      "STIX Two Math",
    ),
    integral: (
      "TeX Gyre Termes Math",
      "STIX Two Math",
      "New Computer Modern Math",
    ),
  ),
  windows: (
    main: (
      "Cambria Math",
    ),
    text: (
      "Times New Roman",
      "SimSun"
    ),
    blackboard: (
      "Cambria Math",
    ),
    calligraphic: (
      "Cambria Math",
    ),
    integral: (
      "Cambria Math",
    ),
  ),
  macos: (
    main: (
      "STIX Two Math",
    ),
    text: (
      "Times New Roman",
      "Songti SC",
    ),
    blackboard: (
      "STIX Two Math",
    ),
    calligraphic: (
      "STIX Two Math",
    ),
    integral: (
      "STIX Two Math",
    ),
  ),
)

/// 获取文本字体配置
#let get-text-fonts(fontset) = {
  if type(fontset) == dictionary {
    // 用户自定义字体集
    fontset
  } else if fontset in text-fontsets {
    // 预设字体集
    text-fontsets.at(fontset)
  } else {
    // 默认使用 web
    text-fontsets.web
  }
}

/// 获取数学字体配置
#let get-math-fonts(fontset) = {
  if type(fontset) == dictionary {
    // 用户自定义字体集
    fontset
  } else if fontset in math-fontsets {
    // 预设字体集
    math-fontsets.at(fontset)
  } else {
    // 默认使用 web
    math-fontsets.web
  }
}
