// ============================================================
// const.typ — 常量基础定义
// 本文件定义模板所需的静态数据：字体方案、字号表、引用记号
// ============================================================

// ========== 字体方案 ==========
// 每个条目为一个字体列表，Typst 按顺序依次 Fallback。
// 按系统分类，config() 的 system 参数可选择不同方案。

#let font-set = (
  // 跨平台通用（优先 Windows 字体，次选 Noto/Source Han，无 macOS 独占字体）
  default: (
    仿宋: ("Times New Roman", "FangSong", "STFangsong"),
    宋体: ("Times New Roman", "SimSun", "STSong", "Noto Serif CJK SC", "Source Han Serif"),
    黑体: ("Times New Roman", "SimHei", "STHeiti", "Noto Sans CJK SC", "Source Han Sans"),
    楷体: ("Times New Roman", "KaiTi", "STKaiti", "AR PL UKai"),
    代码: ("Consolas", "Courier New", "SimSun", "STSong", "Noto Serif CJK SC", "Source Han Serif"),
  ),
  // macOS：Apple 自带字体，精简不留冗余 fallback
  mac: (
    仿宋: ("Times New Roman", "STFangsong"),
    宋体: ("Times New Roman", "STSong"),
    黑体: ("Arial", "PingFang SC", "STHeiti"),
    楷体: ("Times New Roman", "STKaiti"),
    代码: ("Menlo", "Courier New", "STSong"),
  ),
  // Windows：优先 SimSun / SimHei
  windows: (
    仿宋: ("Times New Roman", "FangSong"),
    宋体: ("Times New Roman", "SimSun"),
    黑体: ("Times New Roman", "SimHei"),
    楷体: ("Times New Roman", "KaiTi"),
    代码: ("Consolas", "SimSun"),
  ),
  // Linux：优先 Noto / Source Han，仅含 Linux 常见字体
  linux: (
    仿宋: ("Times New Roman", "FangSong", "STFangsong"),
    宋体: ("Times New Roman", "Noto Serif CJK SC", "Source Han Serif", "SimSun"),
    黑体: ("Times New Roman", "SimHei", "Noto Sans CJK SC", "Source Han Sans"),
    楷体: ("Times New Roman", "KaiTi", "STKaiti", "AR PL UKai"),
    代码: ("Consolas", "Courier New", "Noto Serif CJK SC", "Source Han Serif", "SimSun"),
  ),
)

/// 向前兼容：未设置 system 时使用 default 方案
#let font = font-set.default

// ========== 字号设置 ==========
// 中文传统字号命名（初号–小七）+ 标题/图表专用条目。
// 正文默认 12pt（小四），表文 10.5pt（五号）。

#let size = (
  初号: 42pt,
  小初: 36pt,
  一号: 26pt,
  小一: 24pt,
  二号: 22pt,
  小二: 18pt,
  三号: 16pt,
  小三: 15pt,
  四号: 14pt,
  小四: 12pt,
  五号: 10.5pt,
  小五: 9pt,
  六号: 7.5pt,
  小六: 6.5pt,
  七号: 5.5pt,
  小七: 5pt,
  一级标题: 16pt,
  二级标题: 14pt,
  三级标题: 13pt,
  图题: 11pt,
  表题: 11pt,
  表文: 10.5pt,
  正文: 12pt,
  脚注: 9pt,
  页眉: 10.5pt,
  页码: 9pt,
  代码: 10.5pt,
  代码块标题: 11pt,
  英文摘要标题: 16pt,
  参考文献正文: 10.5pt,
)

// ========== 引用记号默认值 ==========
// 用户可通过 config() 的 supplements 参数自定义各标签前缀。

#let supplement = (
  图: "图",
  表: "表",
  代码: "代码",
  公式: "式",
  节: "节",
  图表: "图表",
  插图列表: "插图",
  表格列表: "表格",
  代码列表: "代码",
)
