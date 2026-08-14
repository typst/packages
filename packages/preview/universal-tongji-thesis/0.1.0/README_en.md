# Tongji University Graduate Thesis Template

A Typst template for Tongji University thesis.

[中文](./README.md) [English](./README_en.md)

> [!WARNING]
> This template is under active development and may contain some formatting issues. It's suitable for users who want to try Typst features.
>
> This is a community template and **may not be endorsed by the university**. Please be prepared to migrate your content to Word or LaTeX at any time.

## About

[Typst](https://typst.app/) is a document typesetting system developed in Rust. You can write text documents following Typst syntax rules and compile them into PDF documents. Typst aims to achieve LaTeX-level typesetting quality with Markdown-level simplicity and compilation speed.

This template is a simple and easy-to-use Typst template for Tongji University thesis, planned to cover undergraduate, master's, and doctoral theses.

## Usage

### Local Editing (Recommended)

This method is suitable for most users.

- Install Typst

If you use the Scoop package manager, simply run:

```sh
scoop install typst
```

After installing Typst, run:

```sh
typst init @preview/universal-tongji-thesis:0.1.0
```

Typst will create a folder named `universal-tongji-thesis`. Navigate to this directory, modify `thesis.typ`, and run:

```sh
typst compile thesis.typ
```

> [!TIP]
> This template is under active development with frequent updates. Although it has been uploaded to Typst Universe, you can use Typst local packages to experience the latest version locally before it syncs to Typst Universe:
>
> - Ensure Cargo environment is configured
> - Install typship with `cargo install typship`
> - Run `typship install local` in the project root to deploy to the local `@local` namespace
> - Import with `#import "@local/universal-tongji-thesis:0.1.0"` at the template beginning
>   For more details, see [Typship](https://github.com/sjfhsjfh/typship).

### Online Editing

This template has been uploaded to Typst Universe. You can use Typst's official Web App for editing.

After logging into Typst Web App, click `Start from template`, select `universal-tongji-thesis` from the popup window, and create your project.

> [!NOTE]
>
> Typst Web App renders in the browser locally, so the real-time preview experience is almost identical to local editing.
>
> By default, fonts may not display correctly in Web App because it doesn't provide Chinese typography fonts like `SimSun` or `Times New Roman`. To solve this, search for these font files:
>
> - `TimesNewRoman.ttf` (including `Bold`, `Italic`, `Bold-Italic` versions)
> - `SimSun.ttf`
> - `SimHei.ttf`
> - `FangSong.ttf`
> - `Kaiti.ttf`
>
> Upload these files to the project root directory, or create a `fonts` folder for better organization. Typst Web App will automatically load these fonts.
>
> Since fonts need to be downloaded every time you open a project in Typst Web App, and Chinese fonts are large and slow to load, we recommend **local editing**.

## Features / Roadmap

- Templates
  - [x] Master's thesis
  - [x] Doctoral thesis
  - [ ] Bachelor's thesis

## Known Issues

### Typography

Although the font and size settings in this Typst template match the original Word template, there are still visual differences in paragraph layout due to character spacing, line spacing, and paragraph spacing.

### References

- The university's requirements for reference formatting differ from the standard `GB/T 7714-2015 numeric` format.

## Acknowledgments

- Thanks to [modern-ecnu-thesis](https://github.com/jtchen2k/modern-ecnu-thesis) for providing implementation ideas for some features of this template.
