# [English](README.md) | [中文说明](README.zh.md)
# 西南财经大学Typst Touying 模板

Typst 版的 [SWUFE Beamer 模板](https://www.overleaf.com/latex/templates/swufe-beamer-theme/hysqbvdbpnsm)。

参考 [Touying Slide Theme for Beihang University](https://github.com/Coekjan/touying-buaa)进行制作。

## 快速开始（官方包）

通过 Typst 官方包管理器安装并初始化项目：

```console
$ typst init @preview/touying-simpl-swufe
Successfully created new project from @preview/touying-simpl-swufe:<latest>
To start writing, run:
> cd touying-simpl-swufe
> typst watch main.typ
```

## 安装与配置（GitHub 源）

### 方法一：直接复制文件

将 [`lib.typ`](lib.typ) 复制到你的项目根目录，然后在 Typst 文件顶部导入：

```typst
#import "/lib.typ": *
```

### 方法二：本地包安装

从 GitHub 克隆并作为本地包安装，便于在多个项目中复用（可参考 [Typst 文档](https://github.com/typst/packages/blob/main/README.md)）：

```bash
git clone https://github.com/leichaol/packages.git {data-dir}/typst/packages/local/touying-simpl-swufe/0.1.0
```

其中 `{data-dir}` 为：

- Linux：`$XDG_DATA_HOME` 或 `~/.local/share`
- macOS：`~/Library/Application Support`
- Windows：`%APPDATA%`，即 `C:/Users/<username>/AppData/Roaming`

然后在文档中导入：

```typst
#import "@local/touying-simpl-swufe:0.1.0": *
```

## 示例

![模板截图](thumbnail.webp)

更多示例见 [`examples`](examples) 目录。

### 编译示例

在本地编译示例：

```console
$ typst compile ./examples/main.typ --root .
```

将生成 `./examples/main.pdf`。

## 版权声明

本主题的 Logo 来自 [swufe-logo](https://github.com/ChenZhongPu/swufe-logo)，作者为 [ChenZhongPu](https://github.com/ChenZhongPu)。感谢作者提供 Logo 资源。

这些 Logo 为西南财经大学所有，其在此处的使用仅用于学术排版，不代表学校的官方许可或背书。

模板作者不拥有这些 Logo 的版权，也不主张任何相关权利。

如需官方使用或再分发 Logo，请直接联系西南财经大学。

## 许可证

采用 [MIT License](LICENSE) 授权。
