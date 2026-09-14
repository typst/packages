<h1 align="center">
  <br>
  <img src="thumbnail.png" alt="Brilliant CV Preview" width="100%">
  <br>
  <br>
  Brilliant CV
  <br>
</h1>

<h4 align="center">A modern, modular, and feature-rich CV template for <a href="https://typst.app" target="_blank">Typst</a>.</h4>


<br>

## ⭐ New: Brilliant CV Supercharged

<img width="1590" height="1184" alt="CleanShot 2026-01-19 at 17 43 56@2x" src="https://github.com/user-attachments/assets/f4694506-07c3-475f-8d6a-cf8f7e366f89" />

**Take your job search to the next level.**

Manage your applications with Claude Code and Notion, proudly powered by Brilliant CV.

[**Learn more about Brilliant CV Supercharged**](https://gum.co/u/wwpyqbut).

<br>

## ✨ Key Features

- **🎨 Separation of Style & Content**: Write your CV entries in simple Typst files, and let the template handle the layout and styling.
- **🌍 Multilingual Support**: Seamlessly switch between languages (English, French, Chinese, etc.) with a single config change.
- **🤖 AI & ATS Friendly**: Unique "keyword injection" feature to help your CV pass automated screening systems.
- **🛠 Highly Customizable**: Tweak colors, fonts, and layout via a simple `metadata.toml` file.
- **📦 Zero-Setup**: Get started in seconds with the Typst CLI.

<br>

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
