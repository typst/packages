# 字体文件

本模板**不再**通过此目录分发字体文件。请根据你的平台选择字体安装方式。

## 一键下载

```bash
./fonts/download-fonts.sh
```

以上脚本自动下载 Fandol、TeX Gyre Termes 和 HaranoAjiMincho 到当前目录。然后使用以下命令编译：

```bash
typst compile init-files/main.typ thesis.pdf --root . --font-path ./fonts
```

## 手动安装

如果无法使用脚本，请参照以下各字体下载说明。

### TeX Gyre Termes（Latin 衬线字体）

所有字体集均使用 TeX Gyre Termes 作为中英文混排时的 Latin 衬线字体。

| 平台            | 安装方式                                                                                                |
| --------------- | ------------------------------------------------------------------------------------------------------- |
| Linux           | `sudo apt install fonts-texgyre` 或从 [CTAN](https://mirrors.ctan.org/fonts/tex-gyre.zip) 下载          |
| macOS / Windows | 从 [CTAN](https://mirrors.ctan.org/fonts/tex-gyre.zip) 下载 OTF 文件（解压后的 `tex-gyre-termes` 目录） |
| Typst Web App   | 内置，无需上传                                                                                          |

### HaranoAjiMincho（带圈数字字体）

模板使用 HaranoAjiMincho 字体渲染带圈数字 ①–㊿（与 LaTeX 模板一致）。从 CTAN 下载：

```bash
wget https://mirrors.ctan.org/fonts/haranoaji.zip
unzip haranoaji.zip -d ~/.local/share/fonts/
fc-cache -fv
```

> 该字体随 TeX Live 安装。macOS 系统自带 Apple SD Gothic Neo 亦可覆盖。若均未安装，Typst 会通过 `fallback: true` 搜索系统字体。

### 默认字体集 `fandol`

#### CJK 字体下载

从 CTAN 下载：

```bash
wget https://mirrors.ctan.org/fonts/fandol.zip
unzip fandol.zip -d ~/.local/share/fonts/
fc-cache -fv
```

### 平台字体集（macOS / Windows）

无需额外下载，使用系统自带的 CJK 字体：

- **macOS**：在 `metadata.typ` 中设置 `fontset: "mac"`（Songti SC / Heiti SC / Kaiti SC）
- **Windows**：在 `metadata.typ` 中设置 `fontset: "windows"`（SimSun / SimHei / KaiTi / FangSong）

系统字体集也使用 TeX Gyre Termes 作为 Latin 衬线字体（Typst Web App 内置，本地需安装或下载）。

### 其他字体集

- `adobe` / `founder`：从 [cjk-fonts-for-ctex](https://github.com/TJ-CSCCG/cjk-fonts-for-ctex) 下载
- 详见 [README.md](../README.md#字体选择)
