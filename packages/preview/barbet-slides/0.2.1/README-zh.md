# barbet-slides

以 [typslides](https://typst.app/universe/package/typslides) 為底、供臺灣法學院口頭報告使用的簡報套件：色票、線條圖示、適合法學論證的版面元件（卡片、判斷結果、流程方塊、時間軸、出處列），以及只供引註、不印清單的參考文獻。

名稱取自臺灣之特有種，五色鳥（_Psilopogon nuchalis_）。本專案最初設計來供個人使用，惟仍歡迎貢獻。

## 環境需求

- Typst 0.15.0 或以上。
- 字型 [Noto Sans TC](https://fonts.google.com/noto/specimen/Noto+Sans+TC)。Typst 套件無法附帶字型，請自行安裝，或以 `deck.with(font: "…")` 改用其他字型。
- 首次編譯時，Typst 會自動下載 `@preview/typslides:1.4.0`。

## 快速開始

以範本建立新簡報：

```sh
typst init @preview/barbet-slides:0.2.1 my-talk
```

或在既有檔案中匯入：

```typ
#import "@preview/barbet-slides:0.2.1": *

#show: deck.with()

#front-slide(title: [簡報標題], authors: [報告人])

#title-slide[壹、問題提出]

#slide(title: "爭點")[
  #card(title: [結論], icon: "court")[
    #yes[合憲] \
    #partly[部分違憲]
  ]
  #note(icon: "alert")[#case[111憲判2] 的射程不限於公開道歉。]
  #src(cite(<zhangsan2022>))
]

#hidden-bibliography(path("refs.bib"))
```

完整範例見 [`examples/minimal.typ`](examples/minimal.typ)；各函式的參數見 [README.md](README.md) 的 Reference 一節。

## 函式一覽

| 類別           | 名稱                                                                                                           |
| -------------- | -------------------------------------------------------------------------------------------------------------- |
| 設定           | `deck`（全域樣式）、`hidden-bibliography`                                                                      |
| 文字           | `hl`、`hd`、`case`、`mute`、`small`、`chip`／`achip`                                                           |
| 判斷結果       | `yes`、`no`、`maybe`、`partly`                                                                                 |
| 區塊           | `card`、`note`、`banner`、`excerpt`、`step`、`node`、`num-badge`、`rarr`／`darr`、`timeline`、`tl-node`、`src` |
| 圖示與色票     | `ic("名稱")`、`c`（`c.accent`、`c.bg`…）                                                                       |
| typslides 轉出 | `front-slide`、`title-slide`、`slide`、`focus-slide`、`pause`、`only`、`uncover` 等                            |

`deck` 可覆寫 `theme`、`font`、`font-size`、`back-color`、`link-style`（`"color"`、`"underline"` 或 `"both"`）、`progress-height`（進度條高度，預設 `3pt`）、`lang`、`region`、`ratio`。

## 注意

- **參考文獻路徑：** 套件內函式收到的路徑「字串」，會相對於套件資料夾解析，而非你的簡報檔。因此 `hidden-bibliography` 要傳 `path("…")`（相對於呼叫它的檔案）或 `read(..., encoding: none)` 讀入的位元組；傳字串會直接報錯。
- **`c` 會進入你的命名空間：** `import *` 後，簡報內請勿再自行定義 `c`。
- typslides 版本在 `lib.typ` 與 `src/deck.typ` 兩處釘選，升級時須一併修改。

## 本機開發（Windows）

```powershell
git clone https://github.com/zhenhuang-tw/barbet-slides.git
cd barbet-slides
.\install.ps1
```

腳本會讀取 `typst.toml` 的名稱與版本，在 `%APPDATA%\typst\packages\local\barbet-slides\<版本>` 建立指向本 repo 的目錄連接（junction）。因為是連接而非複製，repo 內的修改立即生效。可重複執行；遇到真實資料夾會中止而不刪除。

發佈到 Typst Universe 前，可把 repo 連到 `preview` 命名空間，測試 `@preview` 匯入與範本（本機資料目錄的套件優先於下載快取）：

```powershell
.\install.ps1 -PackageRoot "$env:APPDATA\typst\packages\preview"
typst init @preview/barbet-slides:0.2.1 test-deck
```

測試完請刪除該連接，以免日後蓋過 Universe 上的正式版本。

**版本不等於 commit：** junction 指向的是 repo 工作樹；只要不改 `typst.toml` 的版本，修改會直接影響所有使用該版本的簡報。有破壞性變更時請升版。

## 授權

Copyright (C) 2026 Zhen Huang.

本套件以 GNU 通用公共授權條款第 3 版或任何更新版本（[GPL-3.0-or-later](LICENSE)）授權。本套件匯入並轉出 [typslides](https://github.com/manjavacas/typslides)，而 typslides 本身以 GPL-3.0-or-later 授權；為與其相容，本套件採用相同授權。

例外：`template/` 內的檔案（`typst init` 會複製到新專案）改以 [MIT-0](LICENSE-MIT-0) 授權，以範本建立的簡報可自由使用與散布，無須署名。
