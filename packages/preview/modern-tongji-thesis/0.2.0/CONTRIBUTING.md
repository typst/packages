# 贡献指南 | Contributing

## 仓库结构 | Repository Structure

- **源文件**：`lib.typ` 以及 `utils/`、`layouts/` 目录下的 `.typ` 模板文件。
- **文档文件**：`template/` 目录下的 `.typ` 文件（包括 `main.typ`），用于展示模板的使用方法。
- **配置文件**：规范开发与使用的文件（如 `.gitignore`、`typst.toml`、`.editorconfig`）。

## 如何贡献 | How to Contribute

### 寻求帮助 | Asking for Help

我们通过 [Discussions](https://github.com/TJ-CSCCG/TongjiThesis-typst/discussions) 提供技术支持。

**请勿通过即时通讯工具直接联系贡献者。**

### 反馈 Bug | Reporting a Bug

如确认存在 Bug，请通过 [Issue](https://github.com/TJ-CSCCG/TongjiThesis-typst/issues) 模板提交反馈。

### 提交 Pull Request

1. Fork 本仓库。
2. 将 Fork 后的仓库克隆到本地。
3. 创建一个新分支进行修改。
4. 提交更改到新分支。
5. 将分支推送到你的 Fork 仓库。
6. 从你的分支向本仓库发起 Pull Request。

### Pull Request 前的检查清单 | Before Your PR

如果你新增、移动或删除了 `init-files/` 目录下的文件，请更新 `.github/patches/package_release.diff` 并随 PR 一同提交。

> [!TIP]
> 可以使用 `git diff HEAD~1 HEAD > .github/patches/package_release.diff` 生成补丁文件。

> [!IMPORTANT]
> 我们使用 `git apply` 应用补丁生成 `package` 分支用于 Typst Universe 发布。请确保补丁可以被正确应用，否则可能无法合并你的分支。

## 项目历史 | Project History

| 日期    | 贡献者                                      | 贡献内容                                                                                                         |
| ------- | ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| 2024.06 | [FeO3](https://github.com/seashell11234455) | 项目起源，创建初始 Typst 模板                                                                                    |
| 2024.07 | [RizhongLin](https://github.com/RizhongLin) | 开始贡献，完善模板格式、增加 Typst 教程，持续维护更新                                                            |
| 2025.05 | —                                           | 全面对齐 LaTeX 模板：字体集系统、信息说明页、定理环境、附录、gb7714-bilingual 参考文献、双学科模式、CI/CD 工作流 |

我们非常感谢以上贡献者的付出。如果您觉得本项目对您的毕业设计或论文有所帮助，希望您可以在致谢部分提及。
