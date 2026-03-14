# 代码格式化与检查工具

本项目提供了三种方式来格式化 Typst 代码：Makefile、Shell 脚本和 Lint 检查。

## 前置要求

确保已安装 `typstyle`：

```bash
# 方法1: 使用 Homebrew 安装（推荐）
brew install typstyle

# 方法2: 使用 Cargo 安装
cargo install typstyle

# 方法3: 从 GitHub 下载预编译版本
# https://github.com/Enter-tainer/typstyle/releases
```

## 方法1：使用 Makefile

### 可用命令

```bash
# 显示帮助信息
make help

# ========== 格式化命令 ==========
# 格式化所有 .typ 文件
make format

# 仅格式化主要文件 (lib.typ, template/thesis.typ)
make format-main

# 检查代码格式但不修改文件
make format-check

# 格式化指定文件
make format-file FILE=pages/abstract.typ

# ========== Lint 检查命令 ==========
# 快速包检查（推荐日常使用）
make lint-quick

# 完整包检查（需要安装 package-check）
make lint

# 安装 package-check 工具
make lint-install

# ========== 其他命令 ==========
# 列出所有将被格式化的文件
make list-files

# 清理生成的文件
make clean

# 显示项目统计信息
make stats
```

## 方法2：Lint 检查

除了代码格式化，还提供了包结构检查功能，用于验证 `typst.toml` 配置和包结构是否符合规范。

### 快速检查（推荐）

无需安装额外依赖，适合日常开发使用：

```bash
make lint-quick
```

这会检查：

- ✅ `typst.toml` 文件是否存在
- ✅ 必要的字段（name, version, entrypoint）是否完整
- ✅ 入口文件是否存在

### 完整检查

使用官方 `typst/package-check` 工具进行完整检查（包括依赖验证、兼容性检查等）：

```bash
# 首次安装检查工具
make lint-install

# 运行完整检查
make lint
```

**注意**：完整检查需要本地有完整的 Typst Universe package index。

### Lint 检查示例输出

```bash
$ make lint-quick
运行快速包检查...
检查 typst.toml...
✅ typst.toml 存在
检查必要字段...
✅ 基本字段完整
检查入口文件...
✅ 入口文件存在

✅ 快速检查通过！
```

## 方法3：使用 Shell 脚本（格式化）

如果更喜欢使用 Shell 脚本，可以使用 `format-typst.sh`：

### 基本用法

```bash
# 显示帮助信息
./format-typst.sh --help

# 格式化所有 .typ 文件
./format-typst.sh --all

# 仅格式化主要文件
./format-typst.sh --main

# 检查所有文件的格式（不修改）
./format-typst.sh --check --all

# 格式化指定文件
./format-typst.sh lib.typ pages/abstract.typ

# 格式化指定目录下的所有文件
./format-typst.sh pages/*.typ

# 显示详细输出
./format-typst.sh --verbose --all
```

### 选项说明

- `-h, --help`: 显示帮助信息
- `-c, --check`: 仅检查格式，不修改文件
- `-a, --all`: 格式化所有 .typ 文件
- `-m, --main`: 仅格式化主要文件
- `-v, --verbose`: 显示详细输出

### Shell 脚本示例

```bash
# 检查所有文件是否需要格式化
./format-typst.sh -c -a

# 格式化所有文件（详细输出）
./format-typst.sh -v -a

# 格式化主要文件
./format-typst.sh -m

# 格式化特定的几个文件
./format-typst.sh lib.typ template/thesis.typ pages/abstract.typ
```

## 推荐工作流程

### 开发时

```bash
# 在编写代码时，定期格式化你正在修改的文件
./format-typst.sh pages/chapter1.typ

# 或者使用 make
make format-file FILE=pages/chapter1.typ
```

### 提交前

```bash
# 1. 检查代码格式
make format-check
# 或
./format-typst.sh -c -a

# 2. 检查包结构（推荐在提交前运行）
make lint-quick

# 3. 如果有文件需要格式化，运行：
make format
# 或
./format-typst.sh -a
```

## 编辑器配置

项目包含 `.editorconfig` 文件，确保你的编辑器支持 EditorConfig 以获得一致的代码风格。
