# yuhina

[English](README.md) | 繁體中文

臺灣繁體中文文件的共通排版基礎，供 [Typst](https://typst.app/) 檔案匯入。相對於其它中文排版套件，本專案之特色在於：預設——

1. 優先使用臺版 Windows （臺灣最普及的作業系統）內建的新細明體、標楷體、微軟正黑體等字型；在其他環境自動降級為開放授權字型。
2. 標題採臺灣文書處理常用的「壹、一、(一)」六層編號，交互參照輸出完整路徑，如「見壹、二、(三)」。

另提供行內樣式函式、作者與標題區塊，以及可個別套用的排版規則（頁面、段落、註腳、清單、圖說等）。

本套件的名稱 `yuhina` 得名於臺灣特有種[冠羽鳳眉](https://zh.wikipedia.org/zh-tw/褐头凤鹛)（Taiwan yuhina）。姊妹作 [bluemagpie](https://github.com/zhenhuang-tw/bluemagpie)（供上課筆記用）與 [flamegold](https://github.com/zhenhuang-tw/flamegold)（供法學寫作用）皆以本套件為基礎。

## 快速開始

```typ
#import "@preview/yuhina:0.2.0": *

#show: common-style.with(title: "文件標題", authors: "王小明")

#title-block("文件標題", authors: "王小明")

= 緒論 <intro>

本文的#keyword[重點]如下（@detail[見]）。

== 細節 <detail>

#inquote[行內引用以楷體呈現。]
```

完整範例見 [`examples/basic.typ`](examples/basic.typ)。

在 Windows 上編譯時建議加上 `--input USE_WIN=1`，Linux 上加上 `--input USE_LINUX=1`，以免出現大量缺字型的警告（見[編譯指令](#編譯指令)）：

```powershell
typst compile file.typ --input USE_WIN=1
```

### 撰寫時的注意事項

- 中文句子請勿在原始碼中換行。Typst 會把換行當成空白，排出「甲， 乙」。
- `@label` 之後緊接中文時，Typst 會把中文當成標籤名稱的一部分。請改寫為 `#ref(<label>)的`，或在 `@label` 後加補充文字，如 `@label[見]`。

## 環境需求

1. [Typst](https://github.com/typst/typst#installation) 0.15.1 以上。
2. 字型：預設優先使用 Windows／Office 內建的 Times New Roman、Arial、新細明體、標楷體、Microsoft JhengHei UI。缺少時會依[字型降級](#字型降級)改用其他字型。

首次編譯時，Typst 會自動下載本套件與其依賴的 [`@preview/cuti`](https://typst.app/universe/package/cuti)。

## 公開 API

以 `#import "@preview/yuhina:0.2.0": *` 匯入時，只會取得下列名稱。未列出的名稱（`src/` 內的輔助函式、降級字型清單等）屬內部實作，可能隨時變更，請勿依賴。

### 排版規則

`common-style` 依序套用下表所有規則。需要更細的控制時，可改為個別套用；每個函式都以 `#show: 函式` 或 `#show: 函式.with(...)` 套用，只影響其後的內容。

| 函式             | 作用                     | 參數（預設值）                                               |
| ---------------- | ------------------------ | ------------------------------------------------------------ |
| `document-style` | PDF 標題與作者           | `title: ""`、`authors: ()`                                   |
| `page-style`     | 紙張、邊距、頁尾置中頁碼 | `paper: "a4"`、`margin: (x: 3cm, y: 2.5cm)`                  |
| `text-style`     | 字型、語言、CJK 粗體     | `font: font-song`、`size: 12pt`                              |
| `par-style`      | 段落                     | `first-line-indent: 0em`、`leading: 1.1em`、`spacing: 1.6em` |
| `quote-style`    | 區塊引用                 | `font: font-kai`                                             |
| `list-style`     | 編號與項目清單           | 無                                                           |
| `figure-style`   | 圖說                     | `font: font-kai`                                             |
| `footnote-style` | 註腳                     | `font: font-song`、`label-font: font-hei`                    |
| `heading-style`  | 標題編號與外觀           | `font: font-hei`、`large: false`                             |
| `ref-style`      | 交互參照                 | `large: false`（須與 `heading-style` 一致）                  |

`common-style` 的參數：

| 參數      | 預設值  | 說明                                                                    |
| --------- | ------- | ----------------------------------------------------------------------- |
| `title`   | `""`    | PDF 中繼資料的標題（不會印在頁面上；頁面上的標題請用 `title-block`）     |
| `authors` | `()`    | PDF 中繼資料的作者；格式同 `title-block`                                |
| `large`   | `false` | 是否在最上層多加一層「Ch. 1」，供分章的長篇文件使用                     |
| `fonts`   | `(:)`   | 覆寫字型，見[覆寫字型](#覆寫字型)                                       |

### 其他名稱

| 名稱                                                           | 用途                                                                                         |
| -------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `font-song`、`font-hei`、`font-kai`、`font-yuan`、`font-fsong` | 字型清單：宋體、黑體、楷體、圓體、仿宋                                                       |
| `keyword`                                                      | 行內重點強調（粗體）                                                                         |
| `inquote`                                                      | 行內引用（預設楷體，可用 `font` 參數指定）                                                   |
| `hfn`                                                          | 標題內的註腳，參數同 `footnote`；目次中不輸出，見[標題內的註腳](#標題內的註腳)               |
| `title-block`                                                  | 置中的標題區塊：主標題、副標題、作者；參數 `title-thanks`、`subtitle`、`authors`、`font`、`weight` |
| `normalize-authors`                                            | 把字串、單一 dictionary 或陣列形式的作者統一轉為陣列，供自訂模板使用                         |
| `plain-links`                                                  | 移除其後內容的超連結樣式；請在目錄之後才套用，以免目錄失去頁內跳轉                           |

作者可以是字串，或含 `name` 與 `thanks` 的 dictionary（`thanks` 以註腳呈現），也可以是兩者混合的陣列：

```typ
#title-block(
  "文件標題",
  title-thanks: [本文為國立臺灣大學法律學系115學年度第1學期「弄春池生態專題研究」課程（授課教師：生工系共授）的學期報告初稿。],
  subtitle: "副標題",
  authors: ((name: "王小明", thanks: [國立臺灣大學法律學系碩士生，通訊作者。]), "李小華"),
)
```

### 標題編號

| 層級 | 編號     | `large: true` 時 |
| ---- | -------- | ---------------- |
| 1    | 壹、     | Ch. 1            |
| 2    | 一、     | 壹、             |
| 3    | (一)     | 一、             |
| 4    | 1.       | (一)             |
| 5    | (1)      | 1.               |
| 6    | ①        | (1)              |
| 7    | 無編號   | ①                |

第一層超過十時依序進位，如「拾壹、」「貳拾、」。交互參照時輸出完整路徑，如 `@label` →「壹、二、(三)」，`@label[見]` →「見壹、二、(三)」；指向圖表、文獻等其他對象的參照不受影響。

第一層標題置中，其餘層級靠左；無編號的標題（如目錄、參考文獻）亦同。標題下方的間距等於內文段距，因此標題緊接下一個標題時（如「壹、」之後直接是「一、」），間距與標題後接內文相同。段距以套用 `heading-style` 時的內文字級計算，個別套用時請放在 `text-style`、`par-style` 之後。

### 標題內的註腳

標題文字會原樣複製到目次，所以標題裡直接寫 `#footnote` 的話，目次會再產生一個註腳：頁底重複印出，其後的註號也全部往後錯號。標題裡的註腳請改用 `hfn`，參數與 `footnote` 相同，但在目次中不輸出：

```typst
= 緒論#hfn[本章部分內容曾發表於……]
```

`hfn` 靠 `heading-style` 判斷是否位於目次內（`common-style` 已包含），個別套用規則時請確認有套用 `heading-style`。目次的 `outline.entry` 另有自訂也沒有影響；但只有 `outline` 會被處理，若在頁首等處以 `query(heading)` 重印標題，請自行避免重複產生註腳。

## 字型降級

Linux 等非 Windows 環境通常沒有上述字型（本套件暫無支援 macOS 的規劃，故降級清單不含 Songti TC, PingFang TC 等 macOS 專有字型）。每組字型（`font-song`、`font-hei`、`font-kai`、`font-yuan`、`font-fsong`）都是一份依優先順序排列的清單，Typst 會逐字形挑選第一個已安裝且含有該字形的字型；找不到的字型會略過，但每個找不到的家族都會顯示一則 `unknown font family` 警告（不影響輸出；避免警告的方法見[編譯指令](#編譯指令)）。因此在缺字型的環境，會依下表順序降級：

| 用途               | 優先（Windows／Office）                    | 降級字型                                                                                                     |
| ------------------ | ------------------------------------------ | ------------------------------------------------------------------------------------------------------------ |
| 內文（宋體）       | Times New Roman、新細明體（PMingLiU）      | Libertinus Serif（Typst 內建）；Noto Serif CJK TC、Source Han Serif TC、Noto Serif TC                        |
| 標題（黑體）       | Arial、Microsoft JhengHei UI               | Libertinus Sans；Noto Sans CJK TC、Source Han Sans TC、Noto Sans TC                                          |
| 引用、圖說（楷體） | Times New Roman、標楷體（DFKai-SB）        | 拉丁同宋體；TW-MOE-Std-Kai（教育部標準楷書）、TW-Kai（全字庫正楷體）、LXGW WenKai TC；皆無時改用宋體降級字型 |
| 圓體、仿宋         | TaiwanPearl、Zhuque Fangsong（需自行安裝） | 圓體同黑體降級字型；仿宋同宋體降級字型                                                                       |

注意事項：

- 降級字型需自行安裝。建議安裝 Noto Serif／Sans CJK TC 與 [Libertinus](https://github.com/alerque/libertinus) 家族的 Libertinus Sans；拉丁宋體的降級字型 Libertinus Serif 由 Typst 內建，不必另外安裝。**請安裝「TC」（繁體中文）版本**：若只有 JP、SC 等其他地區版本，Typst 可能改用它們，同一個漢字的字形會與臺灣用字不同。
- 清單中的拉丁字型排在 CJK 字型之前，所以拉丁字母與數字由 Libertinus Serif（宋體）或 Libertinus Sans（黑體）呈現，漢字與全形標點由 CJK 字型呈現。未安裝 Libertinus Sans 時，黑體的拉丁字母與數字改由 CJK 黑體字型自帶的拉丁字形呈現。Libertinus Sans 與 Arial 的字寬不同，因此降級後的換行與頁數可能與 Windows 上的結果有差異。
- 粗體：`text-style` 以清單中第一個 CJK 字型判斷是否使用 [cuti](https://typst.app/universe/package/cuti) 偽粗體，而不是實際使用的字型。預設清單的第一個 CJK 字型是新細明體等，沒有粗體，因此降級到有真粗體的 Noto 等字型時，仍會再疊加偽粗體，粗體會略粗。需要精確控制時，請自訂字型清單（見[覆寫字型](#覆寫字型)），把要用的 CJK 字型排在第一個 CJK 位置。
- 降級字型清單依各平臺的常見家族名稱整理，並非每個平臺都逐一實測。若您的環境字型名稱不同，請自訂字型清單，或在 repo 開 issue。

### 編譯指令

Typst 沒有關閉 `unknown font family` 警告的設定，文件內也無法查詢已安裝字型，所以只能由使用者在編譯時告知環境（做法參考 [Typst 論壇的討論](https://forum.typst.app/t/is-it-possible-to-suppress-the-warning-about-noto-cjk-source-han-duality/2207)）。請依作業系統加上 `--input`：

```powershell
# Windows
typst c file.typ --input USE_WIN=1
typst w file.typ --input USE_WIN=1
```

```sh
# Linux
typst c file.typ --input USE_LINUX=1
typst w file.typ --input USE_LINUX=1
```

旗標的值可為 `1` 或 `true`。兩者皆不設定時，保留上表的完整清單（缺字型時會有警告）；同時設定會報錯。各模式實際使用的字型如下：

| 用途               | `USE_WIN=1`                                 | `USE_LINUX=1`                                       |
| ------------------ | ------------------------------------------- | --------------------------------------------------- |
| 內文（宋體）       | Times New Roman、新細明體、Libertinus Serif | Libertinus Serif、Noto Serif CJK TC                 |
| 標題（黑體）       | Arial、Microsoft JhengHei UI                | Libertinus Sans、Noto Sans CJK TC                   |
| 引用、圖說（楷體） | Times New Roman、標楷體、Libertinus Serif   | Libertinus Serif、TW-MOE-Std-Kai、Noto Serif CJK TC |
| 圓體、仿宋         | 首選字型（需自行安裝）加上同黑體、宋體      | 首選字型（需自行安裝）加上同黑體、宋體              |

Libertinus Serif 由 Typst 內建，不會產生警告，所以兩種模式都保留。這些設定對所有匯入 yuhina 的模板（如 flamegold、bluemagpie）一併生效。

注意：

- 不會自動偵測作業系統，須自己加上旗標。在 Windows 上用 `USE_LINUX`，或在 Linux 上用 `USE_WIN`，都會因缺字型而沒有可用的降級。本套件暫無支援 macOS 之規劃，未設定對應的旗標。
- `USE_LINUX=1` 要求您已安裝 Libertinus Sans、Noto Serif CJK TC、Noto Sans CJK TC 與 TW-MOE-Std-Kai（建議安裝「TC」版本，見上）；缺少的字型仍會警告，也不會再改用其他降級字型。若您安裝的是 Source Han 或 TW-Kai 等同類字型，請不要加旗標，或以 `common-style` 的 `fonts` 參數自訂清單。
- 兩種模式都少了字型層級的補字：例如新細明體缺字時，不會再改用 Noto 補字。Typst 另有不依清單的全域補字機制，惟本專案未驗證罕用字的結果，請自行確認。
- 圓體與仿宋的首選字型（TaiwanPearl、Zhuque Fangsong）本來就需要自行安裝，沒安裝而使用 `font-yuan`、`font-fsong` 時仍會警告。
- 以 `common-style` 的 `fonts` 參數或個別樣式函式的 `font` 參數自訂的清單不受影響。
- tinymist 等編輯器的即時預覽需另外在其設定中傳入同一個 `--input`，否則預覽仍會顯示警告。
- Typst web app 不在此處理；其警告可在介面中手動關閉。

### 選用字型：圓體與仿宋

`font-yuan`（圓體）與 `font-fsong`（仿宋）使用的字型不是系統內建的，需要自行取得；沒有安裝時，會依上表降級為黑體或宋體的降級字型。本套件不內含任何字型，字型的授權與本套件的 MIT 授權各自獨立。以下資訊整理自各專案頁面（2026 年 11 月），實際以專案頁面與隨附的授權文件為準。

| 字型                                                              | 清單中的名稱                          | 授權                                                                              | 取得方式                                                        | 注意                                                                                                                                     |
| ----------------------------------------------------------------- | ------------------------------------- | --------------------------------------------------------------------------------- | --------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| [台灣圓體 TaiwanPearl](https://github.com/max32002/TaiwanPearl)   | `TaiwanPearl`                         | SIL Open Font License 1.1，可免費商用                                             | 從專案頁下載 ZIP，或到 `ttf` 資料夾下載所需字型檔，再安裝到系統 | 字形改自思源黑體與小杉圓體；作者說明這不是專業字型檔，部分符號或罕用字可能缺漏。頁面只提到 Regular，沒有說明是否有粗體，粗體會套用偽粗體 |
| [朱雀仿宋 Zhuque Fangsong](https://github.com/TrionesType/zhuque) | `Zhuque Fangsong (technical preview)` | SIL Open Font License 1.1，可免費商用、複製與再散布，但不可單獨販售原始版或修改版 | 從專案頁的 Releases 取得（頁面另提供 AtomGit 鏡像）             | 頁面未說明字形是否符合臺灣標準，使用前請自行確認                                                                                         |

OFL 1.1 允許在文件中使用字型並散布產出的 PDF，但若要再散布字型檔本身，必須遵守授權條款，包括隨附授權文件與不得單獨販售。

**朱雀仿宋的家族名稱**：`font-fsong` 使用的 `Zhuque Fangsong (technical preview)` 是預覽版的家族名稱。上游專案頁說明正式版尚未發布；正式版若改用其他家族名稱，`font-fsong` 將找不到它而改用降級字型。本套件會在新版中更新清單；在那之前，若您已安裝正式版，請自訂清單：

```typ
#let my-fsong = ("正式版的家族名稱", ..font-fsong)
#text(font: my-fsong)[仿宋文字]
```

### 覆寫字型

`common-style` 的 `fonts` 參數可覆寫字型。鍵為 `song`（內文與註腳）、`hei`（標題與註腳編號）、`kai`（區塊引用與圖說），值為字型清單；沒列出的鍵維持預設。寫了其他鍵會直接報錯，以免打錯字而沒有生效。

```typ
// 完全自訂：只使用指定的字型
#show: common-style.with(
  fonts: (song: ("Libertinus Serif", "Noto Serif CJK TC")),
)

// 保留預設的降級順序，只在最前面加上自己的字型
#show: common-style.with(
  fonts: (hei: ("My Sans", ..font-hei)),
)
```

不經過 `common-style` 的 `title-block` 與 `inquote` 另以 `font` 參數指定，例如 `#title-block("標題", font: font-song)`、`#inquote(font: font-song)[文字]`。`title-block` 預設為黑體粗體，另有 `weight` 參數可調整粗細，例如楷體不加粗：`#title-block("標題", font: font-kai, weight: "regular")`。個別套用的樣式函式（`text-style`、`heading-style` 等）本來就有 `font` 參數。

自訂完整清單時，請把要用的 CJK 字型排在清單中第一個 CJK 位置，因為粗體判斷（見上）是看它。

## 版本

本套件採〈[語意化版本 2.0.0](https://semver.org/lang/zh-TW/)〉，公開 API 指[公開 API](#公開-api) 所列的名稱及其參數。

- 1.0.0 以前：破壞性變更（移除或更名公開名稱、修改參數或預設輸出）與向前相容的功能新增，都升次版號（如 0.1.0 → 0.2.0）；錯誤修正升修訂號（如 0.1.0 → 0.1.1）。
- 1.0.0 以後：破壞性變更升主版號，功能新增升次版號，錯誤修正升修訂號。

各版的變更見 [CHANGELOG](CHANGELOG.md)。

## 開發

### 安裝為 local package

修改本套件、尚未發布新版時，可安裝為本機套件。Typst 會在 `%APPDATA%\typst\packages\local\<名稱>\<版本>` 尋找本機套件；建立一個指向本 repo 的目錄連結（junction），修改 repo 後不必重新複製：

```powershell
$pkg = "$env:APPDATA\typst\packages\local\yuhina\0.2.0"
New-Item -ItemType Directory -Force (Split-Path $pkg) | Out-Null
New-Item -ItemType Junction -Path $pkg -Target (Resolve-Path .)
```

在本 repo 根目錄執行；建立 junction 不需要系統管理員權限。之後以 `#import "@local/yuhina:0.2.0": *` 匯入。路徑中含有版本號，升版後須另建新版本的 junction。

### 測試

測試使用 [tytanic](https://github.com/typst-community/tytanic)（0.4.1，內建 Typst 0.15.1）：

```powershell
tt run              # 執行所有測試
tt update footnote  # 確認輸出正確後，更新參考圖
```

公開名稱有增減時，請一併更新 `tests/api/test.typ`、本 README 與 CHANGELOG。

## 授權

本套件以 [MIT](LICENSE) 授權釋出。字型不包含在本套件中，其授權見[選用字型](#選用字型圓體與仿宋)。
