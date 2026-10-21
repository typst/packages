// ============================================================
// font.typ — 字体方案
// ============================================================

// ========== 字体方案 ==========

/// 字体方案：每个条目为一个字体列表，Typst 按顺序依次 Fallback。
/// 按系统分类，config() 的 system 参数可选择不同方案，默认使用 Windows 字体方案。
#let font-set = (
  // Windows：使用系统自带字体
  // FangSong / NSimSun / SimHei / KaiTi / Times New Roman / Consolas / Arial
  windows: (
    仿宋: ("Times New Roman", "FangSong"),
    宋体: ("Times New Roman", "NSimSun"),
    黑体: ("Times New Roman", "SimHei"),
    楷体: ("Times New Roman", "KaiTi"),
    代码: ("Consolas", "NSimSun"),
    英文衬线: ("Times New Roman"),
    英文无衬线: ("Arial"),
  ),

  // macOS：使用系统自带字体
  // STFangsong / STSong / PingFang SC / STKaiti / Times New Roman / Menlo / Helvetica
  macos: (
    仿宋: ("Times New Roman", "STFangsong"),
    宋体: ("Times New Roman", "STSong"),
    黑体: ("Times New Roman", "PingFang SC"),
    楷体: ("Times New Roman", "STKaiti"),
    代码: ("Menlo", "STSong"),
    英文衬线: ("Times New Roman"),
    英文无衬线: ("Helvetica"),
  ),

  // Linux：纯开源字体，无商业字体依赖
  // FandolFang 字库不全，朱雀仿宋候补，注意他们的字体名
  // Typst 目前对可变字体支持有限，优先使用 Adobe 发行的思源字体
  linux: (
    仿宋: ("Liberation Serif", "FandolFang R", "Zhuque Fangsong (technical preview)"),
    宋体: ("Liberation Serif", "Source Han Serif", "Noto Serif CJK SC"),
    黑体: ("Liberation Serif", "Source Han Sans", "Noto Sans CJK SC"),
    楷体: ("Liberation Serif", "AR PL UKai"),
    代码: ("DejaVu Sans Mono", "Source Han Serif", "Noto Serif CJK SC"),
    英文衬线: ("Liberation Serif"),
    英文无衬线: ("Liberation Sans"),
  ),
)

/// 回退默认：未指定系统时使用 windows 字体方案
#let font = font-set.windows

// ========== 伪粗体策略 ==========

/// 字体伪粗体策略：
/// true -> 使用 cuti 伪粗体
/// false -> 使用字体自带真粗体
#let fakebold-rules = (
  windows:  (黑体: true, 宋体: true, 楷体: true, 仿宋: true),
  macos:    (黑体: false, 宋体: true, 楷体: true, 仿宋: true),
  linux:    (黑体: false, 宋体: false, 楷体: true, 仿宋: true),
)
