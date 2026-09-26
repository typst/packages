<h1 align="center">
  <br>
  <img src="thumbnail.png" alt="Preview of a Brilliant CV resume" width="100%">
  <br>
  <br>
  Brilliant CV
  <br>
</h1>

<h4 align="center">A modern, modular, and feature-rich CV template for <a href="https://typst.app" target="_blank">Typst</a>.</h4>

<p align="center">
  <a href="https://typst.app/universe/package/brilliant-cv"><img alt="Typst Universe" src="https://img.shields.io/badge/Typst_Universe-brilliant--cv-blue?logo=typst&logoColor=white"></a>
  <a href="https://github.com/yunanwg/brilliant-CV/actions/workflows/test.yaml"><img alt="Test status" src="https://github.com/yunanwg/brilliant-CV/actions/workflows/test.yaml/badge.svg"></a>
  <a href="LICENSE"><img alt="Apache 2.0 license badge" src="https://img.shields.io/badge/license-Apache_2.0-green.svg"></a>
  <a href="https://github.com/yunanwg/brilliant-CV/releases"><img alt="Latest release" src="https://img.shields.io/github/v/release/yunanwg/brilliant-CV?color=orange"></a>
</p>

> **v4 is a breaking change.** Coming from v3? See the [Migration Guide](https://yunanwg.github.io/brilliant-CV/migration/) for the v3 fields that now panic with a migration message (`language`, `non_latin_font`, `[lang.<code>]`, `inject_ai_prompt`, …) and their v4 replacements.

## ✨ Key Features

- **One profile, one complete CV — bind it to anything** — Each `profile_<name>/` is a self-contained variant you can target at a specific job, audience, or language, switched with `--input profile=<name>` at compile time. Profiles are fully decoupled from language: any script (CJK, Arabic, Hebrew, …) works via `[layout.fonts]`.
- **Compose from modular content** — Build each CV from reusable blocks (experience, education, projects, publications, skills), and keep as many tailored variants as you need — a long academic version, a one-page industry cut, one per application — from the same building blocks.
- **Polished by default** — Clean, modern typography with Font Awesome icons and a matching cover letter, for a professional result without fighting the layout.

## Quick Start

```bash
typst init @preview/brilliant-cv   # scaffolds a project directory with the template
cd brilliant-cv
```

Using Typst Web? Upload the Font Awesome 7 Free desktop OTF files (Regular,
Solid, and Brands) to your project so the contact icons render correctly.

Edit `profile_en/metadata.toml` and the content modules in `profile_en/*.typ` — it's the most heavily annotated profile. To add a new variant, copy the directory and tweak the fields that differ.

```bash
typst compile cv.typ                    # default profile
typst compile cv.typ --input profile=fr # switch profile at compile time
```

> **Optional:** embed a hidden, ATS-friendly keyword layer for automated screeners — opt-in and off by default. Read the notes in `profile_en/metadata.toml` before enabling, and keep keywords truthful.

Full guide, component gallery, recipes, and configuration reference → **[brilliant-CV Documentation](https://yunanwg.github.io/brilliant-CV/)**.

## Gallery

The same design across scripts — one profile per language, all from the same building blocks:

| English | Français | 中文 |
|:---:|:---:|:---:|
| ![English CV preview](https://raw.githubusercontent.com/yunanwg/brilliant-CV/main/docs/previews/cv-en.png) | ![French CV preview](https://raw.githubusercontent.com/yunanwg/brilliant-CV/main/docs/previews/cv-fr.png) | ![Chinese CV preview](https://raw.githubusercontent.com/yunanwg/brilliant-CV/main/docs/previews/cv-zh.png) |

_Previews are generated in CI from the live template (`just previews`) — see [`scripts/render_previews.sh`](scripts/render_previews.sh)._

## Contributing

Contributions are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) to get started.

## Sponsors

> If this template helps you land a job, consider [buying me a coffee](https://github.com/sponsors/yunanwg)! ☕️

<p align="center">
  <!-- sponsors --><a href="https://github.com/GeorgRasumov"><img src="https://github.com/GeorgRasumov.png" width="60px" alt="GitHub profile picture for sponsor GeorgRasumov" style="border-radius: 50%;" /></a>&nbsp;&nbsp;<a href="https://github.com/chaoran-chen"><img src="https://github.com/chaoran-chen.png" width="60px" alt="GitHub profile picture for sponsor chaoran-chen" style="border-radius: 50%;" /></a>&nbsp;&nbsp;<!-- sponsors -->
</p>

## License

[Apache 2.0](LICENSE).
