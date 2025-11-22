# Conjak

Conjak is a simple typst package for CJK number formatting. [Check the `docs.pdf` file in the releases](https://github.com/WenSimEHRP/conjak/releases/latest) for information about each function.

## Goals

This library provides basic CJK (Chinese, Japanese, and Korean) number and date formatting utilities.
It is designed with simplicity in mind, and with maximum compatibility with different CJK languages and regions. Features include:

- Formatting numbers with thousands separators.
  - including _Daxie_ used by Chinese.
- Formatting dates in various CJK date formats.
- Automatic handling of locals, based on the current text language and region (i.e., the `lang` and `region` fields of `text`)

I do not aim to cover all possible utilities related to CJK number formatting, but rather to provide a solid foundation for common use cases. If you have specific needs or suggestions, feel free to open an issue on the GitHub repository.

### Localization

**DISCLAIMER**: I am not a Japanese nor a Korean expert, so I have relied on existing resources (i.e. Wikipedia, LLM) to implement features for these languages. If you find any mistakes or have suggestions for improvements, please let me know.

Functions provided by this library can adapt to the current text language and region (hence their outputs are `content` but not `string` or `int`). See each function's documentation for details.

![Example](https://raw.githubusercontent.com/WenSimEHRP/conjak/master/example.svg)
