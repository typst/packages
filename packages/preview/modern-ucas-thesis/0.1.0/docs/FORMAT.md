# 代码格式化工具

本项目提供了两种方式来格式化 Typst 代码：Makefile 和 Shell 脚本。

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

# 格式化所有 .typ 文件
make format

# 仅格式化主要文件 (lib.typ, template/thesis.typ)
make format-main

# 检查代码格式但不修改文件
make format-check

# 格式化指定文件
make format-file FILE=lib.typ

# 列出所有将被格式化的文件
make list-files

# 清理生成的文件
make clean

# 显示项目统计信息
make stats
```

### 使用示例

```bash
# 格式化所有文件
make format

# 检查所有文件的格式
make format-check

# 仅格式化主要文件
make format-main

# 格式化特定文件
make format-file FILE=pages/abstract.typ
```

## 方法2：使用 Shell 脚本

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
# 检查所有文件的格式
make format-check
# 或
./format-typst.sh -c -a

# 如果有文件需要格式化，运行：
make format
# 或
./format-typst.sh -a
```

### CI/CD 集成

在 GitHub Actions 或其他 CI 系统中，你可以添加格式检查：

```yaml
- name: Check Typst format
  run: |
    brew install typstyle
    make format-check
```

## 编辑器配置

项目包含 `.editorconfig` 文件，确保你的编辑器支持 EditorConfig 以获得一致的代码风格。

## 注意事项

1. **备份重要文件**：首次使用格式化工具时，建议先备份重要文件
2. **渐进式格式化**：对于大型项目，可以先格式化主要文件，然后逐步格式化其他文件
3. **版本控制**：格式化后记得提交更改到版本控制系统
4. **团队协作**：确保团队成员都使用相同的格式化工具和配置

## 故障排除

### typstyle 未找到

```bash
# 检查 typstyle 是否在 PATH 中
which typstyle

# 使用 Homebrew 安装
brew install typstyle

# 或使用 Cargo 安装
cargo install typstyle
```

### 权限问题

```bash
# 确保脚本有执行权限
chmod +x format-typst.sh
```

### 格式化失败

如果某个文件格式化失败，检查：

1. 文件是否有语法错误
2. 文件是否被其他程序锁定
3. 是否有足够的磁盘空间
