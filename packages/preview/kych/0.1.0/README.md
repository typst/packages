# The `kych` Package / `kych` 包
<div align="center">Version 0.1.0</div>

静态网站生成器

> **基于** [tufted](https://github.com/vsheg/tufted) (Copyright © 2025 Vsevolod Shegolev, MIT License) 修改而来。

## Template adaptation checklist / 模板适配检查清单

- [ ] remove/replace the example test case / 移除/替换示例测试用例
- [ ] (add your actual code, docs and tests) / （添加你实际的代码、文档和测试）
- [ ] remove this section from the README / 从 README 中移除此部分

## Getting Started / 快速开始

These instructions will get you a copy of the project up and running on the typst web app. Perhaps a short code example on importing the package and a very simple teaser usage.
以下说明将帮助你在 typst web app 中启动并运行该项目的副本。可以提供一个简短的代码示例来展示如何导入包以及一个非常简单的预览用法。

```typ
#import "@preview/kych:0.1.0": *

#show: my-show-rule.with()
#my-func()
```

## Usage / 使用方法

Initialize the template from the Typst package registry: / 初始化

```shell
typst init @preview/kych:0.1.1
```

To build the website, run: 编译

```shell
make html
```

## Local Testing Guide / 本地测试指南

跨域晨昏提供了完整的本地开发和测试工具链，允许你在不发布到 Typst Universe 的情况下修改源码并即时验证效果。

### 前置条件

- `typst` 0.14+
- `make` (GNU Make)
- `just` (可选，用于运行测试套件)
- `tt` (可选，Typst 测试运行器)

### 方式一：符号链接开发模式（推荐）

通过符号链接将本地开发版本挂载到 Typst 包缓存，修改源码后无需重新安装，模板立即可用。

**Step 1: 创建符号链接**

```shell
make link
```

该命令会根据操作系统自动选择对应的缓存路径：

| 操作系统 | 路径 |
|----------|------|
| macOS | `~/Library/Caches/typst/packages/preview/kych/{VERSION}` |
| Linux | `~/.cache/typst/packages/preview/kych/{VERSION}` |
| Windows | `%LOCALAPPDATA%\typst\packages\preview\kych\{VERSION}` |

版本号自动从 `typst.toml` 中的 `version` 字段提取。

**工作原理**：

```text
typst init 时，编译器在包缓存中查找:
  ~/Library/Caches/typst/packages/preview/kych/{VERSION}/

通过符号链接:
  该路径 → 项目根目录

结果:
  修改本地源码 → 无需重新安装 → 模板立即可用
```

**Step 2: 构建网站**

```shell
make html
```

此命令等价于先执行 `make link`，再调用 `template/Makefile` 将 `content/*.typ` 编译为 `_site/*.html`。编译参数如下：

```bash
typst compile --root .. --features html --format html content/index.typ _site/index.html
```

- `--root ..` — 设包根目录为 template/ 的父目录（使 `@preview/kych` 能被解析）
- `--features html` — 启用 HTML 导出（实验性功能）
- `--format html` — 输出 HTML 格式

**文件映射规则**：
- `content/` → `_site/`
- `*.typ` → `*.html`
- 以下划线 `_` 开头的文件/目录被排除（约定为私有文件）
- `assets/` 下的静态资源直接复制到 `_site/assets/`

**Step 3: 构建 PDF**

```shell
make pdf
```

同一份 `.typ` 源文件，不启用 HTML 特性，输出为标准 PDF 文档。

### 方式二：本地包安装

使用 `just` 将包安装到本地 Typst 缓存，模拟从注册表安装的行为。

```shell
# 安装为 @local 前缀（本地测试）
just install

# 安装为 @preview 前缀（发布前验证）
just install-preview
```

卸载：

```shell
just uninstall          # 卸载 @local
just uninstall-preview  # 卸载 @preview
```

安装原理：`scripts/package` 脚本先将项目打包为符合 Typst 包规范的结构，再复制到 `{data_dir}/typst/packages/{prefix}/kych/{VERSION}/` 目录。

### 运行测试套件

```shell
# 运行全部测试
just test

# 仅运行特定测试
just test tests/unit1

# 更新测试快照
just update
```

测试使用 `tt` (Typst Test Runner) 执行，测试用例位于 `tests/` 目录。

### 包质量检查

```shell
make check
```

使用 `typst-package-check` 工具验证包结构是否符合 Typst Universe 规范（检查 `typst.toml` 元数据、入口点配置、文件完整性等）。

### 完整 CI 流程

```shell
just ci
```

等价于依次执行 `just test`（测试） + `just doc`（生成文档），模拟 CI 环境的完整验证流程。

### 清理构建产物

```shell
make clean
```

删除 `template/_site/`、`template/_pdf/` 和 `.DS_Store` 文件。

### 打包发布

```shell
make build
```

生成 `kych-{VERSION}.zip` 归档文件，包含 `src/`、`template/`、`assets/`、`LICENSE`、`README.md` 和 `typst.toml`，可直接提交到 Typst Universe。
