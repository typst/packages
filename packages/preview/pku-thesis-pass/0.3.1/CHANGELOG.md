# Changelog

## [0.3.1] — 2026-08-14

### 格式对齐 Word 2024 模板

- 页码字号 10.5pt → 9pt（小五），对齐 Word 2024 模板 ([4ff6f25])
- 表单元格字号 11pt → 10.5pt（五号），对齐 Word 2024 模板 ([508db89])
- 章标题段前段后改为 17pt / 16.5pt、2.41 倍间距，对齐 Word 2024 模板 ([1805f0a])
- 英文题目行距改为单倍（1.65em）([382398d])

### 标题与加粗

- 各级标题不再加粗（`weight: regular`），黑体不加粗，对齐指南 ([2b05f49])
- 新增 `format/utils/bold.typ` 统一加粗入口，按 `fakebold-rules` 决定真粗体或 cuti 描边 ([997d458])
- 修正 `fakebold-rules`：Windows 黑体、macOS 宋体/楷体无真粗体，改用描边 ([997d458])
- 全局加粗规则收窄为 `show strong`，`text(weight: bold)`（如 Arial 的 ABSTRACT）不再被误描边 ([997d458])
- 清理 style.typ 未消费的 fakebold / weight 死字段 ([997d458])
- 字体校验演示表改用 `text(weight: bold)`，绕过全局规则避免双重描边 ([dff26ef])

### 长表续表

- 长表跨页续页由右上角小字「续表」改为居中显示完整表题（表号前加「续」，如「续表 1.1 表名」），对齐《指南》；`booktab` 与 `as-booktab` 均支持 ([9fc7e33])

### 测试

- 测试重组为 unit / integration / spec 三类 ([f703a95])
- 补齐覆盖缺口（longtable / 参考文献 / PDF 元数据 / 公式），盲审验证 strings → pdftotext 修复假阴性 ([9edece8])

### 文档

- README 新增「一分钟快速体验」([54da6a5])

---

## [0.3.0] — 2026-08-09

### 架构重构

- config() 字典访问替代位置解构，消除顺序依赖 ([0fdc2d8])
- config.typ 拆分为 `config/cli.typ` + `config/resolve.typ` ([644ca7a])
- 页面闭包移入 `config/builder.typ`，config.typ 从 497 行瘦身到 186 行 ([31af70d])
- `_make-theorem` 工厂函数消除 8 个定理环境代码重复 ([485a48f])
- 模板文档代码示例全面同步 cfg.xxx 模式 ([be5013c])
- 标题元数据接口 `headings-meta.typ` 解耦 header/footer 对 headings 的依赖 ([996ef69])
- 导入依赖全面清理：11 个死 import + 3 个 `_` 前缀修正 + 3 个 `font.typ` 直接 import 移除 ([3dfc6a5], [08f7d90], [d9b34bf])
- `reset-chapter-counters()` 提取到 counter.typ，消除 heading-show-rule 14 行重复 ([08f7d90])

### SSOT 样式系统

- 新增 `format/utils/style.typ` 作为全模板样式单一事实来源 ([d0d2d79])
- 全部页面和布局模块迁移到 style.typ 引用 ([083708d])
- `build(font)` 工厂函数连接 font.typ → style.typ ([d2e0c4b])
- `weight` 字段统一由 style.typ 控制，消费者不再硬编码 `strong()` ([6169acb], [1b80e05])
- 清理死 fallback 模式，`s.` → `style.` 直接访问 ([9007cbf])
- 补齐 4 个全死 style.typ 条目（摘要标题、关键词、英文作者信息、版权声明）([5de3868])
- 标题对齐 `set align(center)` → `h-style.align` ([b067aba])
- 标题字体 `text()` 包裹替代 `set text()`，避免外层宋体覆盖 ([2e0b4db])
- 目录字体/行距回归修复 ([422c118])
- 全局 `show: show-cn-fakebold` 替代 `show strong: 黑体` ([d0d2d79])
- style.typ 死字段清理：删除 ~33 个未消费的 align/spacing-before-after/leading 字段 ([a2011b5])
- 补全遗漏条目 15+：强调/公式编号/脚注/目录/参考文献/成果列表/子图/三线表/代码样式/标题行距/版权段落行距 等 ([de678fe], [ec12c1d])
- 封面字段标签、年/月独立控制、页眉堆叠间距/下划线/编号间距全部归入 style.typ ([5de3868], [ec12c1d])
- `show-header` → `show-page-marks`，语义明确控制页眉+页码 ([fda0b1e])

### 字体方案

- 字体方案三文件同步（font.typ / README / quickstart）([a03e2fb])
- Linux 黑体移除 WenQuanYi 依赖 ([a03e2fb])
- 新增 `英文衬线`、`英文无衬线` 字体条目，统一从 font.typ 出口 ([d2e0c4b])
- Linux 代码字体改用 DejaVu Sans Mono ([df69148])
- 字体校验表通过 system-state 实时渲染当前方案 ([d3adc0a], [b42ab28])
- Linux 方案纯开源：移除 Times New Roman/Arial，全用 Liberation 替代 ([be02ed8])
- macOS 英文无衬线加入 Helvetica fallback ([28c5ee5])
- 字体感知伪粗体策略：有真粗体走原生 bold，无粗体用 cuti 描边（`fakebold-rules`）([d79954e])
- 取消 `default` 跨平台方案，改为三套精确控制（`windows`/`macos`/`linux`），`system` 参数默认 `windows` ([1e79e54], [2373cba])

### 新增功能

- 书脊页（`spine-page`）([32369c0])
- 公式列表（`list-of-equations`）([1e353c2])
- 成果页（`achievement-page`）([7d9c041])
- 符号对照表（`notation-page`）([1c33f8b])
- 定理环境 9 种（`_make-theorem` 工厂）([9ca80a1], [485a48f])
- 子图（`subfigure`）([2565aee])
- 公式块（`eq-block`）([1e353c2])
- CJK 字数统计（`word-count-cjk` / `total-words` / `total-characters`）([a35bb41])
- LaTeX 引用兼容（`use-latexref`）([a420895])
- PDF 元数据自动设置（标题/作者，盲审模式隐藏作者）([3286585])
- 长表跨页自动续表（重复表头 + "续表"标注）([f87cd7d])

### 模板指南

- FAQ 从 8 条扩展到 12 条 ([b16447c])
- 新增公式三种方案对比 FAQ（`math.equation` / `figure(kind:)` / `eq-block`）([09d434e])
- 新增模块导入参考表（20 个导出模块清单）([b90f4d2])

### 修复

- 表单元格字号 10.5pt → 11pt（对齐 Word 标准）([083708d])
- 页码字号 9pt → 10.5pt（五号 = 10.5pt）([083708d])
- 中文摘要行距校准为 10.5pt ([27fca23])
- `notion` → `notation` 笔误 ([8382c27])

### 测试

- 测试框架建立：6 个单元测试（number/util/style/cli/size/font）+ 组件测试 ([39858e4], [04e4437])
- 6 个集成测试（minimal/linux/full/blind/heading/refs）([39858e4], [04e4437])
- CI 盲审验证：`strings \| grep` 检测作者名泄漏 ([39858e4])
- `just publish` test gate：测试不过不允许发布 ([f4d9e89])
- 测试 PDF 含 "All tests passed" 标题，不再空白 ([58fa97d])
- CI `test` → `build` → `deploy` 顺序优化 ([d759dea])

### 工具链

- `scripts/release.py` — 发布/开发模式导入切换 ([bd089ad])
- `scripts/bump.py` — 文档版本号自动同步 ([67fbfc5])
- `scripts/publish.py` — 发布文件收集到 `release/<version>/` ([66b611b])
- `.justfile` — 7 个 recipe（pdf/png/json/preview/dev/bump/publish）([53b90c6])
- `.github/workflows/ci-deploy-test.yml` — 4 变体编译 + GitHub Pages 部署 ([6ab4178])
- CI 字体安装脚本共用去重，微软字体 → Liberation ([c24acc1], [dbeaaeb])

### 代码质量

- 第三方依赖集中管理（`format/imports.typ`）([15913fa])
- 组件/布局/页面目录化重组 ([a6cf1d5], [2dc7586], [873dc96])
- utils 子模块拆分（font/size/style/supplement/counter/number）([98f2aeb])
- `_figure-show-rule` / `_ref-show-rule` → `figure-show-rule` / `ref-show-rule`，去 `_` 前缀 ([08f7d90])
- `header-text` 变量遮蔽修正 → `custom-header` ([08f7d90])

---

## [0.2.0] — 2026-08-04

### DI 模式

- `config()` 返回闭包字典，用户可自由编排论文流程 ([07c6ca])
- 跨平台字体方案 + `--input system` 切换
- 字体校验表实时渲染（`system-state` 驱动）

### 模板指南

- 扩展为 5 章 + 附录文档（ch01–ch05 + appendix-about）
- 新增 8 条 FAQ
- README 功能特性与配置表格

### 新增

- 学位类型选择框（学术学位 / 专业学位）支持
- 封面校徽与校名字标占位框

---

## [0.1.0] — 2026-07-31

### 初始发布

- 北京大学学位论文 Typst 模板（博士 / 硕士）
- 封面（正常 + 盲审）、版权声明、中英文摘要、目录
- 正文（中英文标题、段落）、参考文献、附录
- 致谢、原创性声明与授权说明
- GB/T 7714 参考文献（2015 / 2025 标准）
- 三线表（`booktab` / `as-booktab`）
- 代码高亮与斑马条纹（codly）
- 中文章节编号（chinesenumbering）
- 盲审模式自动隐藏个人信息
- 命令行参数支持（`blind` / `preview` / `always-start-odd`）
- 跨平台字体 fallback 链
- 模板指南（快速开始 + 基本功能）

[0.3.1]: https://github.com/chuxinyuan/pku-thesis-pass/compare/v0.3.0...main
[0.3.0]: https://github.com/chuxinyuan/pku-thesis-pass/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/chuxinyuan/pku-thesis-pass/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/chuxinyuan/pku-thesis-pass/releases/tag/v0.1.0
[31af70d]: https://github.com/chuxinyuan/pku-thesis-pass/commit/31af70d
[644ca7a]: https://github.com/chuxinyuan/pku-thesis-pass/commit/644ca7a
[485a48f]: https://github.com/chuxinyuan/pku-thesis-pass/commit/485a48f
[be5013c]: https://github.com/chuxinyuan/pku-thesis-pass/commit/be5013c
[0fdc2d8]: https://github.com/chuxinyuan/pku-thesis-pass/commit/0fdc2d8
[5de3868]: https://github.com/chuxinyuan/pku-thesis-pass/commit/5de3868
[b067aba]: https://github.com/chuxinyuan/pku-thesis-pass/commit/b067aba
[422c118]: https://github.com/chuxinyuan/pku-thesis-pass/commit/422c118
[2e0b4db]: https://github.com/chuxinyuan/pku-thesis-pass/commit/2e0b4db
[6169acb]: https://github.com/chuxinyuan/pku-thesis-pass/commit/6169acb
[1b80e05]: https://github.com/chuxinyuan/pku-thesis-pass/commit/1b80e05
[9007cbf]: https://github.com/chuxinyuan/pku-thesis-pass/commit/9007cbf
[083708d]: https://github.com/chuxinyuan/pku-thesis-pass/commit/083708d
[27fca23]: https://github.com/chuxinyuan/pku-thesis-pass/commit/27fca23
[d2e0c4b]: https://github.com/chuxinyuan/pku-thesis-pass/commit/d2e0c4b
[d0d2d79]: https://github.com/chuxinyuan/pku-thesis-pass/commit/d0d2d79
[a03e2fb]: https://github.com/chuxinyuan/pku-thesis-pass/commit/a03e2fb
[d3adc0a]: https://github.com/chuxinyuan/pku-thesis-pass/commit/d3adc0a
[b42ab28]: https://github.com/chuxinyuan/pku-thesis-pass/commit/b42ab28
[df69148]: https://github.com/chuxinyuan/pku-thesis-pass/commit/df69148
[32369c0]: https://github.com/chuxinyuan/pku-thesis-pass/commit/32369c0
[1e353c2]: https://github.com/chuxinyuan/pku-thesis-pass/commit/1e353c2
[7d9c041]: https://github.com/chuxinyuan/pku-thesis-pass/commit/7d9c041
[1c33f8b]: https://github.com/chuxinyuan/pku-thesis-pass/commit/1c33f8b
[9ca80a1]: https://github.com/chuxinyuan/pku-thesis-pass/commit/9ca80a1
[2565aee]: https://github.com/chuxinyuan/pku-thesis-pass/commit/2565aee
[a35bb41]: https://github.com/chuxinyuan/pku-thesis-pass/commit/a35bb41
[a420895]: https://github.com/chuxinyuan/pku-thesis-pass/commit/a420895
[f87cd7d]: https://github.com/chuxinyuan/pku-thesis-pass/commit/f87cd7d
[b16447c]: https://github.com/chuxinyuan/pku-thesis-pass/commit/b16447c
[09d434e]: https://github.com/chuxinyuan/pku-thesis-pass/commit/09d434e
[b90f4d2]: https://github.com/chuxinyuan/pku-thesis-pass/commit/b90f4d2
[8382c27]: https://github.com/chuxinyuan/pku-thesis-pass/commit/8382c27
[bd089ad]: https://github.com/chuxinyuan/pku-thesis-pass/commit/bd089ad
[67fbfc5]: https://github.com/chuxinyuan/pku-thesis-pass/commit/67fbfc5
[66b611b]: https://github.com/chuxinyuan/pku-thesis-pass/commit/66b611b
[53b90c6]: https://github.com/chuxinyuan/pku-thesis-pass/commit/53b90c6
[6ab4178]: https://github.com/chuxinyuan/pku-thesis-pass/commit/6ab4178
[15913fa]: https://github.com/chuxinyuan/pku-thesis-pass/commit/15913fa
[a6cf1d5]: https://github.com/chuxinyuan/pku-thesis-pass/commit/a6cf1d5
[2dc7586]: https://github.com/chuxinyuan/pku-thesis-pass/commit/2dc7586
[873dc96]: https://github.com/chuxinyuan/pku-thesis-pass/commit/873dc96
[98f2aeb]: https://github.com/chuxinyuan/pku-thesis-pass/commit/98f2aeb
[996ef69]: https://github.com/chuxinyuan/pku-thesis-pass/commit/996ef69
[3dfc6a5]: https://github.com/chuxinyuan/pku-thesis-pass/commit/3dfc6a5
[08f7d90]: https://github.com/chuxinyuan/pku-thesis-pass/commit/08f7d90
[d9b34bf]: https://github.com/chuxinyuan/pku-thesis-pass/commit/d9b34bf
[a2011b5]: https://github.com/chuxinyuan/pku-thesis-pass/commit/a2011b5
[de678fe]: https://github.com/chuxinyuan/pku-thesis-pass/commit/de678fe
[ec12c1d]: https://github.com/chuxinyuan/pku-thesis-pass/commit/ec12c1d
[fda0b1e]: https://github.com/chuxinyuan/pku-thesis-pass/commit/fda0b1e
[be02ed8]: https://github.com/chuxinyuan/pku-thesis-pass/commit/be02ed8
[28c5ee5]: https://github.com/chuxinyuan/pku-thesis-pass/commit/28c5ee5
[39858e4]: https://github.com/chuxinyuan/pku-thesis-pass/commit/39858e4
[04e4437]: https://github.com/chuxinyuan/pku-thesis-pass/commit/04e4437
[f4d9e89]: https://github.com/chuxinyuan/pku-thesis-pass/commit/f4d9e89
[58fa97d]: https://github.com/chuxinyuan/pku-thesis-pass/commit/58fa97d
[d759dea]: https://github.com/chuxinyuan/pku-thesis-pass/commit/d759dea
[c24acc1]: https://github.com/chuxinyuan/pku-thesis-pass/commit/c24acc1
[dbeaaeb]: https://github.com/chuxinyuan/pku-thesis-pass/commit/dbeaaeb
[d79954e]: https://github.com/chuxinyuan/pku-thesis-pass/commit/d79954e
[1e79e54]: https://github.com/chuxinyuan/pku-thesis-pass/commit/1e79e54
[2373cba]: https://github.com/chuxinyuan/pku-thesis-pass/commit/2373cba
[3286585]: https://github.com/chuxinyuan/pku-thesis-pass/commit/3286585
[4ff6f25]: https://github.com/chuxinyuan/pku-thesis-pass/commit/4ff6f25
[508db89]: https://github.com/chuxinyuan/pku-thesis-pass/commit/508db89
[1805f0a]: https://github.com/chuxinyuan/pku-thesis-pass/commit/1805f0a
[382398d]: https://github.com/chuxinyuan/pku-thesis-pass/commit/382398d
[2b05f49]: https://github.com/chuxinyuan/pku-thesis-pass/commit/2b05f49
[997d458]: https://github.com/chuxinyuan/pku-thesis-pass/commit/997d458
[dff26ef]: https://github.com/chuxinyuan/pku-thesis-pass/commit/dff26ef
[9fc7e33]: https://github.com/chuxinyuan/pku-thesis-pass/commit/9fc7e33
[f703a95]: https://github.com/chuxinyuan/pku-thesis-pass/commit/f703a95
[9edece8]: https://github.com/chuxinyuan/pku-thesis-pass/commit/9edece8
[54da6a5]: https://github.com/chuxinyuan/pku-thesis-pass/commit/54da6a5
