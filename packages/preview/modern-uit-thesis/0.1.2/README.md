# Modern UiT Thesis Template

Port of the [uit-thesis](https://github.com/egraff/uit-thesis)-latex template to Typst.

`thesis.typ` contains a full usage example, see `thesis.pdf` for a rendered pdf.

## Usage

Using the Typst Universe package/template:

```console
typst init @preview/modern-uit-thesis:0.1.2
```

### Fonts

This template uses a number of different fonts:

- Open Sans (Noto Sans)
- JetBrains Mono (Fira Code)
- Charis SIL (Charter)

The above parenthesized fonts are fallback typefaces available by default in [the web app](https://typst.app).
If you'd like to use the main fonts instead, simply upload the `.ttf`s to the web app and it will detect and apply them automatically.

If you're running typst locally, install the fonts in a directory of your choosing and specify it with `--font-path`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
