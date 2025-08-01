# modern-ucas-thesis: UCAS Thesis Template (Typst)

<p align="center" style="color: #888; font-size: 0.95em; margin-top: -0.5em; margin-bottom: 0.5em;">
  <b>English</b> | <a href="../README.md">中文</a>
</p>

<div align="center">

![Project Status](https://img.shields.io/badge/status-beta-blue?style=flat-square)
![Last Commit](https://img.shields.io/github/last-commit/WayneXuCN/modern-ucas-thesis?style=flat-square)
![Issues](https://img.shields.io/github/issues/WayneXuCN/modern-ucas-thesis?style=flat-square)
![License](https://img.shields.io/github/license/WayneXuCN/modern-ucas-thesis?style=flat-square)

</div>

<details open>
<summary>🚧 <strong>Status: Beta, under active development. Feedback and contributions are welcome!</strong> 🚧</summary>

> - This template can be used for thesis writing, but many details are still being improved.
> - Please submit suggestions, report issues, or contribute via <a href="https://github.com/WayneXuCN/modern-ucas-thesis/issues">Issues</a> or <a href="https://github.com/WayneXuCN/modern-ucas-thesis/pulls">PRs</a>.
</details>

<blockquote style="border-left: 4px solid #f39c12; background: #fffbe6; padding: 0.8em 1em;">
<strong>⚠️ Disclaimer:</strong> This is a community-developed Typst thesis template for UCAS.<br>
It is <b>not</b> an official template. Please verify the latest requirements from your institution.<br>
<b>Use at your own risk. The author is not responsible for any issues arising from its use.</b>
</blockquote>

## 🚀 Features

- 🎨 **Standardized formatting**: Developed according to the "UCAS Graduate Thesis Writing Guidelines (2022)"
- 🔧 **Highly customizable**: Simple config, supports custom fonts, styles, and layouts
- 🛠️ **Easy to use**: Typst is as easy as Markdown, highly readable source code
- 🖥️ **Environment friendly**: Typst package management is on-demand, native support for CJK, works out-of-the-box in Web App / VS Code
- ✨ **Fast compilation**: Typst is Rust-based, incremental compilation and efficient caching, generates PDF in seconds
- 🧑‍💻 **Modern programming**: Typst supports variables, functions, package management, error checking, closures, functional programming, and mixed markup/script/math

## ⏩ Quick Start

#### 1. Get the template

```bash
# Method 1: Clone the repo
git clone https://github.com/WayneXuCN/modern-ucas-thesis.git
cd modern-ucas-thesis

# Method 2: Download latest version
wget https://github.com/WayneXuCN/modern-ucas-thesis/archive/refs/heads/main.zip
unzip main.zip
```

#### 2. Edit your thesis

Edit `template/thesis.typ` to start writing:

```typst
#import "../lib.typ": *

#show: documentclass.with(
  title: "Your Thesis Title",
  author: "Your Name",
  // other config ...
)

// Start writing your thesis content
```

#### 3. Compile

```bash
# Compile to PDF
typst compile template/thesis.typ

# Watch for changes and auto-compile
typst watch template/thesis.typ
```

## 📁 Project Structure

```text
modern-ucas-thesis/
├── template/           # Template files
│   ├── thesis.typ     # Main thesis file
│   ├── ref.bib        # Bibliography
│   └── images/        # Images
├── utils/             # Utility functions
├── pages/             # Page templates
├── layouts/           # Layout templates
├── lib.typ            # Main library
└── docs/              # Documentation
```

## 🛣️ Roadmap

### 🧰 Basic Features

<details>
<summary><b>📖 Basic Template Components</b></summary>

| Module             | Status      | Notes/Plans                        |
| ------------------ | ---------- | ---------------------------------- |
| Page size/margins  | ✅ Done     | Standard page setup                |
| Header/footer      | 🚧 WIP      | Style optimization                 |
| Chapter structure  | ✅ Done     | Standard chapters                  |
| Figure/table       | ✅ Done     | Support for figures and tables     |
| Font config        | ✅ Done     | Custom font groups                 |
| References         | 🚧 WIP      | Style optimization                 |
| Auto index         | 📋 Planned  | Auto index for figures/equations   |
| Footnotes/endnotes | 📋 Planned  | Footnote/endnote styles            |

</details>

<details>
<summary><b>🎨 Style & Typesetting</b></summary>

| Module             | Status      | Notes/Plans                        |
| ------------------ | ---------- | ---------------------------------- |
| Cover template     | ✅ Done     | Standard cover                     |
| Cover style        | 🚧 WIP      | Detail optimization                |
| TOC style          | 🚧 WIP      | TOC beautification                 |
| Heading style      | 🚧 WIP      | Style optimization                 |
| Figure/table style | 🚧 WIP      | Style optimization                 |
| PDF/A support      | 📋 Planned  | PDF/A output support               |

</details>

### 🎯 Degree Type Support

<details>
<summary><b>🎓 Undergraduate Template</b></summary>

| Component          | Status      | Notes                              |
| ------------------ | ---------- | ---------------------------------- |
| Font test page     | ✅ Done     | Font display test                  |
| Cover              | ✅ Done     | Standard undergraduate cover       |
| Statement page     | ✅ Done     | Integrity statement                |
| Chinese abstract   | ✅ Done     | Chinese abstract                   |
| English abstract   | ✅ Done     | English abstract                   |
| TOC page           | 🚧 WIP      | TOC style optimization             |
| List of figures    | 🚧 WIP      | List of figures                    |
| List of tables     | 🚧 WIP      | List of tables                     |
| Symbol list        | 📋 Planned  | Symbol explanation                 |
| Acknowledgements   | ✅ Done     | Acknowledgements page              |

</details>

<details>
<summary><b>🎓 Graduate Template</b></summary>

| Component          | Status      | Notes                              |
| ------------------ | ---------- | ---------------------------------- |
| Cover              | ✅ Done     | Standard graduate cover            |
| Statement page     | ✅ Done     | Academic statement                 |
| Abstract           | ✅ Done     | Chinese & English abstracts        |
| Header             | 🚧 WIP      | Header style optimization          |
| National Library cover | 📋 Planned | National Library cover template  |
| Publication license| 📋 Planned  | Publication license template        |

</details>

<details>
<summary><b>🎓 Postdoctoral Template</b></summary>

| Component          | Status      | Notes                              |
| ------------------ | ---------- | ---------------------------------- |
| Postdoc report     | 📋 Planned  | Complete postdoc template          |

</details>

### ⚙️ Advanced Features

<details>
<summary><b>🔧 Global Config</b></summary>

| Feature            | Status      | Notes                              |
| ------------------ | ---------- | ---------------------------------- |
| Documentclass config | ✅ Done   | `documentclass` config             |
| Blind review mode  | ✅ Done     | Hide personal info                 |
| Duplex mode        | ✅ Done     | Duplex printing support            |
| Custom fonts       | ✅ Done     | Font config system                 |
| Math font config   | ✅ Done     | User custom config                 |
| Per-chapter compile| 📋 Planned  | Compile chapters separately        |
| Enhanced anonymity | 📋 Planned  | Auto anonymization                 |
| Open source license page | 📋 Planned | License statement page         |

</details>

<details>
<summary><b>🔢 Numbering System</b></summary>

| Feature            | Status      | Notes                              |
| ------------------ | ---------- | ---------------------------------- |
| Preface Roman numerals | ✅ Done | Preface page numbering             |
| Appendix Roman numerals | ✅ Done | Appendix page numbering           |
| Table numbering    | ✅ Done     | `1.1` format                       |
| Equation numbering | ✅ Done     | `(1.1)` format                     |
| Auto chapter index | 📋 Planned  | Auto chapter index                 |

</details>

<details>
<summary><b>📚 Extended Features</b></summary>

| Feature            | Status      | Notes                              |
| ------------------ | ---------- | ---------------------------------- |
| Theorem environments | 📋 Planned| Theorem, proof, etc.               |
| Appendix template  | 📋 Planned  | Improved appendix template         |
| Type checking      | 📋 Planned  | Function parameter type checking    |
| Detailed docs      | 📋 Planned  | Improved documentation             |

</details>

<details>
<summary><b>📄 Other Files</b></summary>

| File type          | Status      | Notes                              |
| ------------------ | ---------- | ---------------------------------- |
| Undergraduate proposal | 📋 Planned | Undergraduate proposal template  |
| Graduate proposal  | 📋 Planned  | Graduate proposal template         |

</details>

**Legend**: ✅ Done | 🚧 WIP | 📋 Planned

## 🔧 Configuration

### Basic config

Edit the following in `template/thesis.typ`:

```typst
#show: documentclass.with(
  title: "Thesis Title",
  author: "Author Name",
  supervisor: "Supervisor Name",
  degree: "Degree Type",
  major: "Major Name",
  // more options ...
)
```

### Custom fonts

The template supports custom font configuration. See the `fonts/` directory for details.

### Images & resources

Put images in `template/images/` and use relative paths in your thesis.

## 🛠️ Development Guide

### template directory

- `thesis.typ`: Your thesis source file. You can rename or copy this file to maintain multiple versions.
- `ref.bib`: For bibliography.
- `images`: For images.

### Internal directories

- `utils`: Various custom helper functions used by the template, with no external dependencies and **do not render pages**.
- `pages`: Contains **independent pages** such as cover, statement, abstract, etc., i.e., functions that render standalone pages.
- `layouts`: Layout directory, contains functions for document layout applied to the `show` directive, spanning multiple pages, e.g., the `preface` function for Roman numeral page numbers.
  - Mainly divided into `doc` (document), `preface`, `mainmatter`, and `appendix`.
- `lib.typ`:
  - **Role 1**: Unified external interface, exposing internal utils functions.
  - **Role 2**: Uses **function closures** to configure global info via `documentclass`, then exposes layout/page functions with global config.

### Code formatting

This project uses `typstyle` for code formatting:

```bash
# Install typstyle
brew install typstyle  # macOS
cargo install typstyle # Other platforms

# Format code
make format           # Format all files
make format-check     # Check format
./format-typst.sh -a  # Use script to format
```

### Contributing

- Propose your ideas in Issues. For new features, add them to the roadmap!
- Implement parts of the roadmap and submit your PR.
- You are welcome to **migrate this template to your university's thesis template** and help build a better Typst community/ecosystem.

## 📝 Documentation

- [Formatting Tool Docs](FORMAT.md)
- [FAQ](FAQ.md)

## 🤝 Acknowledgements

- Thanks to [nju-lug](https://github.com/nju-lug) for [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis), which provided a solid foundation for this template.
- Thanks to [mohuangrui](https://github.com/mohuangrui) for [ucasthesis](https://github.com/mohuangrui/ucasthesis), which inspired this template.

## 📄 License

MIT License. See [../LICENSE](../LICENSE).

## 💬 Support & Feedback

If you have questions or suggestions:

- 🐛 [Report issues](https://github.com/WayneXuCN/modern-ucas-thesis/issues)
- 💡 [Start a discussion](https://github.com/WayneXuCN/modern-ucas-thesis/discussions)
- 🔧 [Contribute code](https://github.com/WayneXuCN/modern-ucas-thesis/pulls)

---

> Made with ❤️ and Typst
