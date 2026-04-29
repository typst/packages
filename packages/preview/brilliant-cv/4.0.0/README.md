<h1 align="center">
  <br>
  <img src="thumbnail.png" alt="Brilliant CV Preview" width="100%">
  <br>
  <br>
  Brilliant CV
  <br>
</h1>

<h4 align="center">A modern, modular, and feature-rich CV template for <a href="https://typst.app" target="_blank">Typst</a>.</h4>

<p align="center">
  <a href="https://typst.app/universe/package/brilliant-cv"><img alt="Typst Universe" src="https://img.shields.io/badge/Typst_Universe-brilliant--cv-blue?logo=typst&logoColor=white"></a>
  <a href="https://github.com/yunanwg/brilliant-CV/actions/workflows/test.yaml"><img alt="Test status" src="https://github.com/yunanwg/brilliant-CV/actions/workflows/test.yaml/badge.svg"></a>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/license-Apache_2.0-green.svg"></a>
  <a href="https://github.com/yunanwg/brilliant-CV/releases"><img alt="Latest release" src="https://img.shields.io/github/v/release/yunanwg/brilliant-CV?color=orange"></a>
</p>

> **v4 is a breaking change.** Coming from v3? See the [Migration Guide](https://yunanwg.github.io/brilliant-CV/migration/) for the v3 fields that now panic with a migration message (`language`, `non_latin_font`, `[lang.<code>]`, `inject_ai_prompt`, …) and their v4 replacements.

## ✨ Key Features

- **Profile-based variants** — Each `profile_<name>/` is a complete, self-contained CV. Switch with `--input profile=fr` at compile time. No language whitelist; any script (CJK, Arabic, Hebrew, …) is configurable via `[layout.fonts]`.
- **AI & ATS friendly** — Keyword injection helps your CV pass automated screening systems.
- **Pixel-perfect tested** — 40+ tests run inside a Linux Docker baseline; layout regressions can't slip past CI.

## Quick Start

```bash
typst init @preview/brilliant-cv
```

Edit `profile_en/metadata.toml` and the content modules in `profile_en/*.typ` — it's the most heavily annotated profile. To add a new variant, copy the directory and tweak the fields that differ.

```bash
typst compile cv.typ                    # default profile
typst compile cv.typ --input profile=fr # switch profile at compile time
```

Full guide, component gallery, recipes, and configuration reference → **[brilliant-CV Documentation](https://yunanwg.github.io/brilliant-CV/)**.

## Gallery

| Style | Preview |
|-------|---------|
| **Standard** | ![CV](https://github.com/mintyfrankie/mintyfrankie/assets/77310871/94f5fb5c-03d0-4912-b6d6-11ee7d27a9a3) |
| **French (Red)** | ![CV French](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/fed7b66c-728e-4213-aa58-aa26db3b1362) |
| **Chinese (Green)** | ![CV Chinese](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/cb9c16f5-8ad7-4256-92fe-089c108d07f5) |

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Sponsors

> If this template helps you land a job, consider [buying me a coffee](https://github.com/sponsors/yunanwg)! ☕️

<p align="center">
  <!-- sponsors --><a href="https://github.com/GeorgRasumov"><img src="https://github.com/GeorgRasumov.png" width="60px" alt="GeorgRasumov" style="border-radius: 50%;" /></a>&nbsp;&nbsp;<a href="https://github.com/chaoran-chen"><img src="https://github.com/chaoran-chen.png" width="60px" alt="chaoran-chen" style="border-radius: 50%;" /></a>&nbsp;&nbsp;<!-- sponsors -->
</p>

## License

[Apache 2.0](LICENSE).
