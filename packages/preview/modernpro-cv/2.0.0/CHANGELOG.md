# Changelog

## [2.0.0] - 2026-07-30

Visual redesign. The configuration API stays backward compatible: every 1.x
parameter, dictionary key, and function alias still resolves. Documents rebuilt
on 2.0.0 will look different, which is the point of the release.

### Changed

- Rebuilt the visual system around a single serif family in two weights, a restrained 8.4-18pt size ladder, and four colours. Body text now defaults to 10pt for more comfortable academic reading. 1.x mixed PT Sans and PT Serif across titles, dates, institutions, and descriptions, which reads as noise at CV sizes.
- 视觉体系重建为单一衬线字族、两种字重、8.4-18pt 的克制字号阶与四个颜色；正文默认提升到 10pt，以改善学术材料的连续阅读。1.x 在标题、日期、机构、描述之间混用 PT Sans 与 PT Serif，在 CV 的小字号下形成视觉噪音。
- Fixed the header: the name and role lines physically overlapped, because Typst measures a line box down to the baseline and leaves descenders outside it. The identity block now extends its bottom edge.
- 修复页眉重叠：Typst 的行盒下沿默认止于基线，降部落在盒外，导致姓名与职称物理重叠。身份区块现在扩展下沿边界。
- Replaced the four-corner entry grid with a left content block and a right date rail. Location joins the institution line instead of occupying the bottom-right corner, so the right edge stays a single clean column.
- 将四角网格改为「左侧内容块 + 右侧日期轨」。地点并入机构行，不再占据右下角，右缘保持为单一整齐的列。
- Corrected the hierarchy inversion where a description rendered larger and darker than the institution line above it. Institution and description now share one size; weight and restrained colour establish the hierarchy without another italic layer.
- 修正层级倒置：此前描述文字比其上方的机构行更大更深。现在机构与描述同字号，并通过字重与克制的颜色建立层级，不再增加一层斜体。
- A smaller date beside a larger title now shares its baseline instead of aligning on cap-height, and the alignment survives a title that wraps.
- 标题旁的小号日期现在与标题共享基线，而非按字母高度顶对齐；标题折行时对齐依然成立。
- Page margins are 2.2cm left and right with a fixed 2cm top margin, matching modernpro-coverletter. Continuation settings no longer move the first-page masthead.
- 左右页边距统一为 2.2cm、顶部固定为 2cm，与 modernpro-coverletter 一致；开启续页页眉不再改变第一页的位置。
- Institution and degree metadata now use regular text, while locations move to the muted colour. This removes a full italic layer from dense pages.
- 机构与学位信息改用常规体，地点使用弱化颜色，减少密集页面中的整层斜体纹理。
- Single-column CVs enable a compact continuation header by default. Later pages show the candidate name, document label, and page count without duplicating the name in the footer.
- 单栏 CV 默认启用紧凑续页页眉；后续页面显示姓名、文档类型和页码，不再在页脚重复姓名。
- Reference entries put the name and role on separate lines so every block has the same line count and the columns stay aligned.
- 推荐人条目将姓名与职务分行，使每个区块行数一致、双列始终对齐。
- Opened the default entry rhythm further: section headings, entry titles, institution lines, descriptions, and following entries now have clearer visual separation while retaining the compact preset for one-page summaries.
- 进一步放松默认条目节奏：章节标题、条目标题、机构行、描述与下一条目之间具有更清晰的视觉分隔，同时保留适合一页式摘要的紧凑预设。
- Replaced public sample identities and bibliography records with explicitly fictional data, reserved domains, and placeholder identifiers.
- Expanded the README into a complete workflow covering layout selection, first edits, common recipes, accessibility, ATS guidance, and troubleshooting.
- Modernized the release workflow to validate the package version, compile both examples, build core and legacy archives, and publish with the repository-scoped GitHub token.

### Added

- A single `cv` entry point takes `profile`, `preset`, `accent`, and `columns`. A typical document now configures one key. `cv-single` and `cv-double` remain available.
- 新增统一入口 `cv`，接受 `profile`、`preset`、`accent`、`columns`。常规文档只需配置一个键。`cv-single` 与 `cv-double` 继续可用。
- `preset: "compact" | "default" | "relaxed"` replaces `layout: (density: ...)`, which still works.
- `preset: "compact" | "default" | "relaxed"` 取代 `layout: (density: ...)`，后者仍可使用。
- The starter template ships a `profile.typ` holding your identity once, so a CV, a cover letter, and a statement import the same dictionary.
- 起始模板附带 `profile.typ`，身份信息只维护一份，CV、求职信与研究陈述导入同一个字典。
- Added optional contact icons with a fixed alignment column while keeping the core template independent of icon libraries and preserving text-only defaults.
- 增加可选联系方式图标与固定对齐列；核心模板不依赖图标库，并继续保留纯文字默认方案。
- Introduced `section-block` and `render-sections` helpers for composing section content once and reordering it declaratively in templates and examples.
- 增加了 `section-block` 和 `render-sections` 助手，便于在编写内容中方便排序和组合。
