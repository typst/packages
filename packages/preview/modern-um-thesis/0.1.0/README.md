# modern-um-thesis

## Typst Thesis Template for University of Macau

This repository provides a modern and easy-to-use thesis template for the University of Macau, built with [Typst](https://typst.app/). The template supports both Doctoral and Master's theses, offering a clean and professional layout that meets UM requirements.

---

## Why Typst?

Typst is a next-generation typesetting system designed for simplicity, speed, and flexibility. Compared to Microsoft Word and LaTeX:

- **User-Friendly**: Typst uses a clean, readable markup language that is easy to learn, even for beginners.
- **Live Preview**: See your changes instantly as you write, with no need for manual compilation.
- **Modern Features**: Built-in support for references, equations, figures, and more—without the complexity of LaTeX or the formatting headaches of Word.
- **Cross-Platform**: Works on Windows, macOS, Linux, and in the browser.

## Why This Template?

- **Official UM Style**: Follows the University of Macau's thesis formatting guidelines.
- **Supports Doctoral & Master Theses**: Easily switch between thesis types with a single option.
- **Multilingual**: Supports English, Chinese, and Portuguese.
- **Customizable**: Clean code and modular layouts make it easy to adapt for your needs.
- **Ready-to-Use**: Includes cover pages, declarations, table of contents, lists of figures/tables/algorithms, and more.

---

## Getting Started

### 1. Install Typst

You can use Typst either via the web app or by installing it locally:

- **Web App**: [https://typst.app/](https://typst.app/) (no installation required)
- **Local Installation:**
	- Download from [Typst Releases](https://github.com/typst/typst/releases)
	- Or install via package manager (e.g., `brew install typst` on macOS)
	- For Windows: Download the latest `.zip` or `.exe` from the releases page and add Typst to your PATH

For more details, see the `installation` section of the [official Typst Github Repo](https://github.com/typst/typst).

### 2. Download This Template

Clone the repository or download it as a ZIP file:

```sh
git clone https://github.com/ShabbyGayBar/modern-um-thesis.git
# or download and extract ZIP from GitHub
```

### 3. Setup & Usage

1. Open the project folder in Typst (web or local editor).
2. Edit the main Typst file (e.g., `template/main.typ`) and fill in your thesis information.
3. Select your thesis type (doctor/master) and language in the documentclass options.
4. Compile to PDF using Typst.

---

## Feedback & Contributions

Found a bug, have a suggestion, or want to contribute?

- Open an issue or pull request on [GitHub](https://github.com/ShabbyGayBar/modern-um-thesis)
- For template-specific questions, please include your Typst version and a minimal code example.

---

**Happy writing, and good luck with your thesis!**

---

## Roadmap

- [x] Support for Doctoral and Master's thesis layouts
- [x] Multilingual support (English, Chinese, Portuguese)
- [x] Modular layouts for cover, declaration, TOC, lists, appendix
- [x] Customizable metadata and info fields
- [x] Full documentation using `tidy`
- [ ] Uploading to Typst Universe as template
- [ ] Bachelor thesis support
- [ ] More flexible bibliography and citation styles
- [ ] More sample content and usage examples

Have a feature request? Please open an issue or discussion!

---

## Acknowledgement

This template draws inspiration from the [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis), the [modern-sjtu-thesis](https://github.com/tzhtaylor/modern-sjtu-thesis) repository, and the University of Macau's thesis guidelines. Special thanks to the [Typst](https://typst.app/) community and all contributors for their support and feedback.

--- 

## License

The university logo in the `src/assets` folder and the thesis guidelines in the `documentation/guidelines` folder are the property of the University of Macau.

The rest of the project is licensed under the [MIT License](LICENSE).
