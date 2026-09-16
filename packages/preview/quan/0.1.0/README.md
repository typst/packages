<p align="center">
  <strong>quan</strong><br>
  <em>圈 /quān/ — circled numbers for Typst, Unicode-first</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.1.0-blue" alt="Package version: 0.1.0">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License: MIT">
  <img src="https://img.shields.io/badge/typst-0.13.0+-orange" alt="Minimum Typst version: 0.13.0">
</p>

<p align="center">
  <a href="#english">English</a> | <a href="#中文">中文</a>
</p>

---

## English

A Typst package for circled numbers. It uses native Unicode circled glyphs (⓪–㊿) within the declared font coverage range, and automatically draws a circle around the number otherwise — so it works with any font, even those with partial or no circled-digit support.

### Features

- **Unicode glyphs first** — uses ⓪–㊿ (U+24EA–U+32BF) when the current font supports them, avoiding the inconsistency of drawn circles mixed with native glyphs
- **Automatic drawn-circle fallback** — renders any integer outside font coverage as a drawn circle, including numbers beyond 50
- **Font coverage declaration** — `quan-init` accepts range strings like `"1-20"` or `"1-5,7,9-11"` to declare exactly which glyphs your font provides
- **Per-range style rules** — `quan-style` lets you tune stroke, radius, inset, baseline, text size and letter-spacing per numeric range
- **SimSun-tuned defaults** — built-in rules handle single digits (0–9) and the varying visual width of digit pairs from 10 to 99 out of the box; easily overridden for other fonts

### Quick Start

```typst
#import "@preview/quan:0.1.0": quan, quan-init, quan-style

// Declare your font's circled-digit coverage (default: 1-10)
#quan-init(digits: "1-20")

Step #quan(1): install. Step #quan(2): configure. Step #quan(15): done.
```

If `quan-init` is not called, the default coverage is **1–10** (supported by most Chinese fonts). Numbers outside the declared range, or beyond 50, are drawn automatically.

### API Reference

#### `quan(n)` — core function

Outputs a circled number. Uses the Unicode circled glyph if `n` is within the coverage declared by `quan-init`; otherwise draws a circle.

| Parameter | Type | Description |
|---|---|---|
| `n` | `int` | The number to render. Must be an integer; non-integer input panics. Coverage and style rules determine the output. |

```typst
#quan(1)    // ① (Unicode, if in coverage)
#quan(25)   // drawn circle with "25"
#quan(100)  // drawn circle with "100"
```

---

#### `quan-init(digits: none)` — declare font coverage

Declares which circled-digit glyphs the current font provides. Numbers outside this range will be drawn.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `digits` | `str` or `none` | `none` (clears to empty) | Range string, e.g. `"1-20"` or `"1-5,7,9-11"`. |

```typst
#quan-init(digits: "1-20")       // font has ①–⑳
#quan-init(digits: "0-50")       // font has ⓪–㊿
#quan-init(digits: "1-5,7,9-11") // sparse coverage
```

> **Note** — if `quan-init` is never called, the default coverage is `1-10`.

---

#### `quan-style(..args)` — configure drawn-circle appearance

Named arguments update the global default style. Positional arguments are `(range-str, style-dict)` tuples for per-range overrides. Rules are matched in order; the first match wins.

| Field | Type | Default | Description |
|---|---|---|---|
| `stroke` | `length` | `0.0315em` | Circle stroke width. |
| `radius` | `ratio` | `50%` | Box corner radius (50% = circle). |
| `inset` | `dict` | `(x: 0em, y: 0.015em)` | Inner padding. Per-range rules override this. |
| `outset` | `dict` | `(y: 0.15em)` | Outer expansion. |
| `baseline` | `length` | `-0.06em` | Vertical alignment shift. |
| `size` | `length` | `0.825em` | Font size of the digit inside the circle. |
| `kern` | `length` | `-0.075em` | Letter-spacing (`tracking`) of the digit inside the circle. Negative values tighten multi-digit numbers. |

```typst
// Change stroke globally
#quan-style(stroke: 0.05em)

// Adjust size and kern for a specific range
#quan-style(("11-50", (size: 0.75em, kern: -0.1em)))

// Multiple overrides in one call
#quan-style(
  stroke: 0.04em,
  ("11-99", (size: 0.8em)),
  ("100-999", (size: 0.65em, kern: -0.2em)),
)
```

### SimSun Default Rules

The built-in style rules are tuned for **SimSun** (Windows 宋体) and cover 0–99. They adjust `inset` and `kern` based on the visual width of each digit:

| Group | Numbers | Logic |
|---|---|---|
| Single digit | 0–9 | one character; wider horizontal inset keeps the circle round |
| Both narrow | 11 | digits 1+1 |
| Narrow + medium | 12, 21 | digits 1+2, 2+1 |
| Narrow + wide | 10, 13–19, 31, 41, 51, 61, 71, 81, 91 | one digit is 1, the other is 0 or ≥ 3 |
| Wide + wide | 20–99 (units ≠ 1) | neither digit is 1 |

For other fonts, override with `quan-style()` as needed.

---

## 中文

用于排版带圈数字的 Typst 包。在声明的字体覆盖范围内使用原生 Unicode 带圈字形（⓪–㊿），超出范围时自动画圈——因此适用于任何字体，包括带圈字形支持不完整的字体。

### 功能特性

- **优先使用 Unicode 字形** — 在字体支持的范围内使用 ⓪–㊿，避免原生字形与画圈混排不一致
- **自动画圈兜底** — 对超出字体覆盖范围的整数（含大于 50 的数字）自动绘制带圈字形
- **声明字体覆盖范围** — `quan-init` 接受 `"1-20"` 或 `"1-5,7,9-11"` 等范围字符串，精确声明字体支持哪些带圈字形
- **按范围配置样式** — `quan-style` 支持按数字范围分别设置描边、圆角、内边距、基线偏移、字号、字间距
- **SimSun 开箱即用** — 内置规则针对宋体（SimSun）的字宽特点，覆盖 0–9 单位数及 10–99 数字对，其他字体可通过 `quan-style()` 覆盖

### 快速上手

```typst
#import "@preview/quan:0.1.0": quan, quan-init, quan-style

// 声明当前字体支持的带圈数字范围（默认：1-10）
#quan-init(digits: "1-20")

第 #quan(1) 步：安装。第 #quan(2) 步：配置。第 #quan(15) 步：完成。
```

若不调用 `quan-init`，默认覆盖范围为 **1–10**（大多数中文字体均支持）。超出声明范围或大于 50 的数字将自动画圈。

### API 参考

#### `quan(n)` — 核心函数

输出带圈数字。若 `n` 在 `quan-init` 声明的覆盖范围内，使用 Unicode 字形；否则自动画圈。

| 参数 | 类型 | 说明 |
|---|---|---|
| `n` | `int` | 要渲染的数字，必须为整数，非整数输入会 panic。 |

```typst
#quan(1)    // ①（Unicode 字形，若在覆盖范围内）
#quan(25)   // 画圈，内含 "25"
#quan(100)  // 画圈，内含 "100"
```

---

#### `quan-init(digits: none)` — 声明字体覆盖范围

声明当前字体支持哪些带圈数字字形。超出范围的数字将自动画圈。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `digits` | `str` 或 `none` | `none`（清空为空） | 范围字符串，如 `"1-20"` 或 `"1-5,7,9-11"`。 |

```typst
#quan-init(digits: "1-20")       // 字体支持 ①–⑳
#quan-init(digits: "0-50")       // 字体支持 ⓪–㊿
#quan-init(digits: "1-5,7,9-11") // 稀疏覆盖
```

> **注意** — 若从未调用 `quan-init`，默认覆盖范围为 `1-10`。

---

#### `quan-style(..args)` — 配置画圈样式

具名参数修改全局默认样式；位置参数为 `(范围字符串, 样式字典)` 元组，按范围覆盖。规则按顺序匹配，取第一个命中。

| 字段 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `stroke` | `length` | `0.0315em` | 圆圈描边粗细。 |
| `radius` | `ratio` | `50%` | 圆角半径（50% 即圆形）。 |
| `inset` | `dict` | `(x: 0em, y: 0.015em)` | 内边距，按范围规则可覆盖。 |
| `outset` | `dict` | `(y: 0.15em)` | 外扩距离。 |
| `baseline` | `length` | `-0.06em` | 垂直对齐偏移。 |
| `size` | `length` | `0.825em` | 圈内数字字号。 |
| `kern` | `length` | `-0.075em` | 圈内数字字间距（`tracking`），负值收紧多位数字。 |

```typst
// 全局修改描边
#quan-style(stroke: 0.05em)

// 按范围调整字号和字间距
#quan-style(("11-50", (size: 0.75em, kern: -0.1em)))

// 多条规则一次设置
#quan-style(
  stroke: 0.04em,
  ("11-99",  (size: 0.8em)),
  ("100-999", (size: 0.65em, kern: -0.2em)),
)
```

### SimSun 默认规则

内置样式规则针对 **SimSun（宋体）** 调校，覆盖 0–99，根据数字的视觉宽度分五组：

| 分组 | 数字范围 | 依据 |
|---|---|---|
| 单位数 | 0–9 | 单字符，较大水平内边距保持圆形视觉 |
| 双窄 | 11 | 两位均为 1 |
| 窄+中 | 12、21 | 1 与 2 的组合 |
| 窄+宽 | 10、13–19、31、41、51、61、71、81、91 | 一位为 1，另一位为 0 或 ≥ 3 |
| 宽+宽 | 20–99（个位非 1） | 两位均非 1 |

如需适配其他字体，通过 `quan-style()` 按需覆盖即可。

---

## License / 许可

MIT License — see [LICENSE](LICENSE) for details.
