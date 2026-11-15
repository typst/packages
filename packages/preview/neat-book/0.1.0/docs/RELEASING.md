# 发布 Neat Book 到 Typst Universe

当前版本：0.1.0。源码仓库：[xiong-ZH-zq/neat-book](https://github.com/xiong-ZH-zq/neat-book)。
Universe 的 `@preview` 导入在提交 PR 被合并并完成打包之后生效。

## 提交前的元数据

1. 确认 `neat-book` 在 Universe 和待审 PR 中可用；如需改名，同时更改 manifest、全部版本化导入和脚本中的测试字符串。
2. 署名为 `xzqbear <@xiong-ZH-zq>`，LICENSE 中保留 `xzqbear`。
3. manifest 已配置真实源码仓库 `https://github.com/xiong-ZH-zq/neat-book`。
4. 确认版权年份和 MIT 许可符合作者意愿。

## 验证与打包

```sh
make test
make thumbnail
python3 scripts/package.py
```

将生成：

- `build/neat-book.pdf`：完整示例书。
- `thumbnail.png`：模板初始化后封面的 PNG，150 PPI，长边大于 1080 px。
- `dist/packages/preview/neat-book/0.1.0/`：可复制到官方包仓库的目录。
- `dist/neat-book-0.1.0.tar.gz`：不包含依赖源代码和构建产物的包归档。

提交目录显式包含 `lib.typ`、`src/`、`template/`、`typst.toml`、`README.md`、`LICENSE`、
`THIRD_PARTY_NOTICES.md`、`docs/`、`thumbnail.png`。其中 `docs/` 由 manifest 排除在编译器下载包之外，
但仍提交到 Universe 仓库，以保证 README 的相对文档链接有效。
模板主入口及所有章节均使用 `@preview/neat-book:0.1.0` 导入；初始化得到的项目可独立编译。
字体通过系统或项目安装，不捆绑大型字体文件。

2026-10-20 已运行官方 `package-check` 0.7.0 实现的社区预编译版本，离线和完整网络检查均退出 0，
没有警告或错误。工具来源、验证范围和字体检查结果见 [发布检查记录](PUBLISHING_AUDIT.md)。
正式提交前仍应根据 [官方安装方法](https://github.com/typst/package-check) 安装并重新运行：

```sh
cargo install --git https://github.com/typst/package-check.git
cd dist/packages/preview/neat-book/0.1.0
typst-package-check check
```

若检查器需要本地包仓库，使用其官方文档中在 `typst/packages/packages` 下运行
`typst-package-check check @preview/neat-book:0.1.0` 的方式。
默认字体已经逐项匹配 Typst 官方网页字体索引，且包含所需字重；默认配置无需上传字体。
发布前可在实际网页项目中再预览一次；自定义字体需单独核对。

## 提交

按 [官方提交指南](https://github.com/typst/packages/tree/main/docs) fork `typst/packages`，
把上述目录放到 `packages/preview/neat-book/0.1.0/`，提交 PR。
PR 中说明原创设计、ElegantBook 的视觉参考、依赖、最低编译器版本与字体要求。
仓库中的 `make package` 仅准备本地文件，不执行上传。

更新版本时同步 `typst.toml`、`template/**/*.typ`、README、测试和变更日志中的版本号。
已发布版本应保持不变，修正通过新版本提交。
