# Gakusyun Document Template
English [简体中文](README-zh.md)

A Typst document template designed specifically for Chinese typography, suitable for quick start recording and providing highly customizable parameter settings.

## Usage

Use this template with the following command:

```bash
typst init @preview/gakusyun-doc:1.0.0
```

Then open the generated project in Typst to start writing.

## Quick Start

### Basic Usage

The template is pre-configured with common settings. You only need to add the following content at the beginning of the document to start writing:

```
#import "@preview/gakusyun-doc:1.0.0": *
#show: docu.with(
  title: "Your Document Title",
  author: "Your Name",
)
```

## Parameter Explanation

- `title`: Title
- `subtitle`: Subtitle
- `author`: Author, supports using an array `("author1", "author2")` to set multiple authors

### Font Settings

- `cjk-font`: CJK font name
- `emph-cjk-font`: CJK emphasis font (italic, etc.), defaults to “楷体”
- `latin-font`: Latin font name
- `mono-font`: Monospace font name
- `default-size`: Default font size, supports CJK font sizes (small four, five, etc.)

### Page Settings

- `paper`: Paper size (a4, a5, letter, etc.)
- `column`: Number of columns in the main text (1 or 2)
- `margin`: Page margins

### Document Structure

- `title-page`: Whether to create an independent title page
- `blank-page`: Whether to add a blank page after the title page
- `show-index`: Whether to display the table of contents
- `index-page`: Whether the table of contents starts on a new page
- `column-of-index`: Number of columns in the table of contents

## English Typography

For English content, it is recommended to use the `#en()` function:

```
#en("This is English text with proper formatting.")
```

This ensures proper formatting of English content.

## Example Effect

![示例图片](thumbnail.png)

## License

This project is licensed under the [MIT](LICENSE) license.

## Contribution

Feel free to submit bug reports and feature suggestions. If you want to contribute code, please:

1. Fork this project
2. Create a feature branch
3. Commit your changes
4. Create a Pull Request
