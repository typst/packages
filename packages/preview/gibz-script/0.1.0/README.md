## GIBZ Template Package

A template package providing reusable components for teaching and learning material at [GIBZ](https://www.gibz.ch).  
It comes with a configurable document setup (`gibz-conf`) and a collection of styled components such as tasks, hints, supplementary material, and more.

---

## Features

- 📄 **Configurable document layout** with title page, table of contents, and headers/footers.
- 🎨 **Consistent styling** through a `base_box` and `icon_box` system.
- ✏️ **Task component** with badges for time, social form, results recording, and evaluation.
- 💡 **Hint**, ❓ **Question**, 🎬 **Video**, 📖 **Supplementary Material** boxes.
- 🔳 **Black code box** for highlighting code snippets.
- 🌍 **Built-in i18n** (currently German and English).
- 🧩 Exposed via a **flat prefixed API** (`gibz-task`, `gibz-hint`, …) and an optional `GIBZ` namespace.

---

## Quick Start

Create a new project from this template in the Typst CLI:

```sh
typst init @preview/gibz-script:0.1.0
```

Or in the [Typst web app](https://typst.app):  
**New → From Template → GIBZ**.

---

## Usage

### Import the flat API (recommended)

```typst
#import "@preview/gibz-script:0.1.0": gibz-conf, gibz-task, gibz-supplementary

#show: gibz-script(
  moduleNumber: 114,
  moduleTitle: "Codierungs-, Kompressions- und Verschlüsselungsverfahren einsetzen",
  documentTitle: "Skript",
  language: "de",
  doc: {
    #gibz-hint("Dieses Skript wurde mit Typst geschrieben :-)")
    #gibz-supplementary([Cheat Sheet])
  }
)
```

### Or use the namespaced API

```typst
#import "@preview/gibz-script:0.1.0": GIBZ

#show: GIBZ.script(
  moduleNumber: 114,
  moduleTitle: "Codierungs-, Kompressions- und Verschlüsselungsverfahren einsetzen",
  documentTitle: "Skript",
  language: "de",
  doc: {
    #GIBZ.hint("Dieses Skript wurde mit Typst geschrieben :-)")
    #GIBZ.supplementary([Cheat Sheet])
  }
)
```

---

## API Reference

### Configuration

- `gibz-conf(moduleNumber, moduleTitle, documentTitle, language, doc)`  
  Wraps your document with title page, table of contents, headers/footers, and base styles.

### Components

- `gibz-task(...)` – exercise/task box with time, social form, recording, evaluation.
- `gibz-hint(content)` – hint box with 💡 icon.
- `gibz-question(question, task: none)` – question box with ❓ icon, optional task description.
- `gibz-video(url, title, description: none)` – video reference with 🎬 icon.
- `gibz-supplementary(body, title: none)` – supplementary material box with 📖 icon.
- `gibz-black_code_box(body, codly-opts: (:), box-opts: (:))` – code box with dark background.

### Utilities

- `gibz-base_box(body, style: (:))` – low-level styled container.
- `gibz-icon_box(icon, content, style: (:))` – container with icon + content layout.
- `gibz-colors.blue` – standard accent color.
- `gibz-t(key, lang: none)` – translation lookup (DE/EN).

---

## Localization

The package supports German (`de`) and English (`en`) for static labels (e.g., _Exercise_, _Supplementary Material_, _Table of Contents_).  
The language is set via `gibz-conf(language: "de" | "en")`.

---

## License

This package is licensed under the [MIT-0 License](LICENSE), allowing reuse with minimal restrictions.

---

## Contributing

Issues and pull requests are welcome!  
The source is maintained on [GitLab](https://gitlab.com/GIBZ/public/typst-template), with mirrored contributions published to [Typst Universe](https://github.com/typst/packages).
