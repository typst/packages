// src/fonts.typ
// 字型清單與 CJK 粗體判斷。公開名稱只有 font-song 等五組字型清單，
// 其餘（旗標、降級清單、粗體判斷）為內部實作，由 lib.typ 決定是否匯出。

// Fake bold for Chinese fonts
#import "@preview/cuti:0.4.0": cn-fakebold

// ============================================================
// § 字體定義（方便未來抽換特定字型）
// ============================================================
// 字型堆疊的順序即優先順序：先列 Windows／Office 字型（維持原本外觀），
// 再依序接上拉丁與 CJK 的降級字型。Typst 會逐字形挑選第一個含有該字形的
// 已安裝字型，找不到的字型家族會略過，所以缺字型時只會改用後面的字型；
// 但每個找不到的家族都會產生一則 `unknown font family` 警告，且文件內無法查詢已安裝字型。
// 因此由使用者以 `--input` 告知編譯環境，只保留該環境會有的字型，以免出現大量警告
// （做法參考 https://forum.typst.app/t/2207）：
//   typst c file.typ --input USE_WIN=1     Windows：只用 Windows／Office 字型
//   typst c file.typ --input USE_LINUX=1   Linux：只用 Libertinus 與 Noto／TW-MOE-Std-Kai
//   兩者皆不設定：保留完整清單（原本行為，缺字型時有警告）
// 各堆疊內「拉丁字型在前、CJK 字型在後」，避免 CJK 字型自帶的拉丁字形蓋過較合適的拉丁字型。
//
// 降級字型 / Fallback fonts
//   拉丁 / Latin: 統一使用 Libertinus 家族 / the Libertinus family throughout
//     襯線 serif: Libertinus Serif（Typst 內建，所有環境皆可用 / bundled with Typst, always available）
//     無襯線 sans: Libertinus Sans（Typst 未內建，需自行安裝 / not bundled, install it separately）
//   CJK 宋/Song: Noto Serif CJK TC、Source Han Serif TC、Noto Serif TC
//   CJK 黑/Hei:  Noto Sans CJK TC、Source Han Sans TC、Noto Sans TC
//   CJK 楷/Kai:  TW-MOE-Std-Kai（教育部標準楷書）、TW-Kai（全字庫正楷體）、LXGW WenKai TC；皆無時改用宋體降級字型
// USE_LINUX=1 時，每種 CJK 字型只留一個：Noto Serif CJK TC、Noto Sans CJK TC、TW-MOE-Std-Kai，須自行安裝
// 編譯環境旗標（見上）。
#let use-win = lower(sys.inputs.at("USE_WIN", default: "0")) in ("1", "true")
#let use-linux = lower(sys.inputs.at("USE_LINUX", default: "0")) in ("1", "true")
#assert(not (use-win and use-linux), message: "yuhina: USE_WIN 與 USE_LINUX 不可同時設定")

// Windows／Office 字型：Linux 模式不列
#let win-latin-serif = if use-linux { () } else { ("Times New Roman",) }
#let win-latin-sans = if use-linux { () } else { ("Arial",) }
#let win-cjk-song = if use-linux { () } else { ("PMingLiU",) }
#let win-cjk-hei = if use-linux { () } else { ("Microsoft JhengHei UI",) }
#let win-cjk-kai = if use-linux { () } else { ("DFKai-SB",) }

// 降級字型：Windows 模式不列，Linux 模式每種只留一個。
// Libertinus Serif 由 Typst 內建，不會產生警告，所以各模式都保留。
#let fallback-latin-serif = ("Libertinus Serif",)
#let fallback-latin-sans = if use-win { () } else { ("Libertinus Sans",) }
#let fallback-cjk-serif = if use-win { () } else if use-linux { ("Noto Serif CJK TC",) } else {
  ("Noto Serif CJK TC", "Source Han Serif TC", "Noto Serif TC")
}
#let fallback-cjk-sans = if use-win { () } else if use-linux { ("Noto Sans CJK TC",) } else {
  ("Noto Sans CJK TC", "Source Han Sans TC", "Noto Sans TC")
}
#let fallback-cjk-kai = if use-win { () } else if use-linux { ("TW-MOE-Std-Kai",) } else {
  ("TW-MOE-Std-Kai", "TW-Kai", "LXGW WenKai TC")
}

#let font-song = (..win-latin-serif, ..win-cjk-song, ..fallback-latin-serif, ..fallback-cjk-serif)
#let font-hei = (..win-latin-sans, ..win-cjk-hei, ..fallback-latin-sans, ..fallback-cjk-sans)
#let font-kai = (..win-latin-serif, ..win-cjk-kai, ..fallback-latin-serif, ..fallback-cjk-kai, ..fallback-cjk-serif)
#let font-yuan = ("TaiwanPearl", ..win-latin-sans, ..win-cjk-hei, ..fallback-latin-sans, ..fallback-cjk-sans) // Source: https://github.com/max32002/TaiwanPearl
// 朱雀仿宋目前只有預覽版，家族名稱帶有「(technical preview)」。上游說明正式版尚未發布；
// 正式版若改名，須更新下列名稱（並視為行為變更記入 CHANGELOG）。
// 維護時請定期查看 https://github.com/TrionesType/zhuque/releases
#let font-fsong = (
  "Zhuque Fangsong (technical preview)",
  ..win-latin-serif,
  ..win-cjk-song,
  ..fallback-latin-serif,
  ..fallback-cjk-serif,
) // Source: https://github.com/TrionesType/zhuque

// Latin-only fonts, skipped when finding the font that sets CJK glyphs
#let latin-only-fonts = (("Times New Roman", "Arial") + fallback-latin-serif + fallback-latin-sans).map(lower)

// CJK fonts that ship a real bold face; fake bold is skipped for them
// (the check looks at the first CJK family in the font list, not at the font actually used)
#let cjk-real-bold-fonts = (
  "microsoft jhenghei",
  "microsoft jhenghei ui",
  "noto sans cjk tc",
  "noto serif cjk tc",
  "noto sans tc",
  "noto serif tc",
  "source han sans tc",
  "source han serif tc",
)

// Apply fake bold only when the CJK font lacks a real bold face; otherwise use the real one
#let show-cn-fakebold-smart(body) = {
  show text.where(weight: "bold").or(strong): it => context {
    let fams = text.font.map(f => lower(if type(f) == dictionary { f.name } else { f }))
    let cjk-font = fams.find(f => f not in latin-only-fonts)
    if cjk-font in cjk-real-bold-fonts { it } else { cn-fakebold(it) }
  }
  body
}
