# Modern UiT Thesis Template

Port of the [uit-thesis](https://github.com/egraff/uit-thesis)-latex template to Typst.

[`thesis.typ`](template/thesis.typ) contains a full usage example, see [`thesis.pdf`](template/thesis.pdf) for a rendered pdf.

## Usage

Using the Typst Universe package/template:

```bash
typst init @preview/modern-uit-thesis:0.1.5
```

### Fonts

This template uses a number of different fonts:

- Open Sans (Noto Sans)
- JetBrains Mono (Fira Code)
- XCharter (Charter)

The above parenthesized fonts are fallback typefaces available by default in [the web app](https://typst.app).
If you'd like to use the main fonts instead, simply upload the `.ttf`s or `.otf`s to the web app and it will detect and apply them automatically.

XCharter is commonly packaged only for LaTeX, however to use it with typst, we need to fetch the archive from [CTAN](https://mirrors.ctan.org/fonts/xcharter.zip).
The required `.otf` font files are in the `opentype` directory of the archive.

If you're running typst locally, install the fonts in a directory of your choosing and specify it with `--font-path`.

> [!IMPORTANT]
> We use XCharter to access additional font features not available in Charter, such as smallcaps and oldstyle figures.
> If you instead use the fallback font Charter to compile your document, be aware that these are unavailable.

### Nix

If you're using the nix package manager, simply run the provided dev shell. It includes all dependencies needed to write and build the document locally, including the main fonts.

#### Publish

To publish a new release use `typship` as following:

```bash
nix run .#typship -- publish universe
```

Requires an access token with permission for your fork of the typst pacakages repo.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
