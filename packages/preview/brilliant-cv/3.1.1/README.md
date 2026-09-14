<h1 align="center">
  <br>
  <img src="thumbnail.png" alt="Brilliant CV Preview" width="100%">
  <br>
  Brilliant CV
  <br>
</h1>

<h4 align="center">A modern, modular, and feature-rich CV template for <a href="https://typst.app" target="_blank">Typst</a>.</h4>

<p align="center">
  <a href="https://typst.app/universe/package/brilliant-cv">
    <img src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fyunanwg%2Fbrilliant-CV%2Fmaster%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239dad" alt="Typst Package">
  </a>
  <a href="https://github.com/yunanwg/brilliant-CV/blob/master/LICENSE">
    <img src="https://img.shields.io/github/license/yunanwg/brilliant-CV" alt="License">
  </a>
  <a href="https://github.com/yunanwg/brilliant-CV/stargazers">
    <img src="https://img.shields.io/github/stars/yunanwg/brilliant-CV" alt="Stars">
  </a>
</p>

<p align="center">
  <a href="https://yunanwg.github.io/brilliant-CV/docs.pdf">Documentation</a> •
  <a href="#-key-features">Key Features</a> •
  <a href="#-how-to-use">How To Use</a> •
  <a href="#%EF%B8%8F-configuration">Configuration</a> •
  <a href="#-gallery">Gallery</a> •
  <a href="MIGRATION.md">Migration Guide</a>
</p>

> [!IMPORTANT]
> **Upgrading from v2?** Please read the [**Migration Guide**](MIGRATION.md) before updating to avoid breaking changes!

> [!TIP]
> **Need detailed help?** Check out the full [**Documentation**](https://yunanwg.github.io/brilliant-CV/docs.pdf) for comprehensive guides, API references, and advanced configuration options.

## ✨ Key Features

- **🎨 Separation of Style & Content**: Write your CV entries in simple Typst files, and let the template handle the layout and styling.
- **🌍 Multilingual Support**: Seamless switch between languages (English, French, Chinese, etc.) with a single config change.
- **🤖 AI & ATS Friendly**: Unique "keyword injection" feature to help your CV pass automated screening systems.
- **🛠 Highly Customizable**: Tweak colors, fonts, and layout via a simple `metadata.toml` file.
- **📦 Zero-Setup**: Get started in seconds with the Typst CLI.

## 🚀 How to Use

### 1. Initialize the Project
Run the following command in your terminal to create a new CV project:

```bash
typst init @preview/brilliant-cv
```

### 2. Configure Your CV
Edit `template/metadata.toml` to set your personal details, language preference, and layout options.

### 3. Add Your Content
Fill in your experience and skills in the `modules_<lang>` directories.

### 4. Compile
Compile your CV to PDF:

```bash
typst compile cv.typ
```

You can also override the language set in `metadata.toml` via the CLI:

```bash
typst compile cv.typ --input language=fr
```

## ⚙️ Configuration

The `metadata.toml` file is the control center of your CV. Here's a quick overview (see the [**Documentation**](https://yunanwg.github.io/brilliant-CV/docs.pdf) for full details):

| Section | Description |
|---------|-------------|
| `[personal]` | Your name, contact info, and social links. |
| `[layout]` | Adjust margins, fonts, and section ordering. |
| `[inject]` | Enable/disable AI prompt and keyword injection. |
| `[lang]` | Define localized strings (headers, date formats). |

## 🖼 Gallery

| Style | Preview |
|-------|---------|
| **Standard** | ![CV](https://github.com/mintyfrankie/mintyfrankie/assets/77310871/94f5fb5c-03d0-4912-b6d6-11ee7d27a9a3) |
| **French (Red)** | ![CV French](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/fed7b66c-728e-4213-aa58-aa26db3b1362) |
| **Chinese (Green)** | ![CV Chinese](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/cb9c16f5-8ad7-4256-92fe-089c108d07f5) |

## 🤝 Contributing

Contributions are welcome! Please check out [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## ❤️ Sponsors

> If this template helps you land a job, consider [buying me a coffee](https://github.com/sponsors/yunanwg)! ☕️

<p align="center">
  <!-- sponsors --><a href="https://github.com/GeorgRasumov"><img src="https://github.com/GeorgRasumov.png" width="60px" alt="GeorgRasumov" style="border-radius: 50%;" /></a>&nbsp;&nbsp;<a href="https://github.com/chaoran-chen"><img src="https://github.com/chaoran-chen.png" width="60px" alt="chaoran-chen" style="border-radius: 50%;" /></a>&nbsp;&nbsp;<!-- sponsors -->
</p>

## 📄 License

This project is licensed under the [Apache 2.0 License](LICENSE).
