# The `numeris-scribere` Package
<div align="center">Version 0.1.3</div>

Literal naming of numbers in multiple languages. Using the great [`n2words`](https://github.com/forzagreen/n2words) package.

## Supported Languages

| Code | Language   | Code    | Language         |
| ---- | ---------- | ------- | ---------------- |
| `ar` | Arabic     | `az`    | Azerbaijani      |
| `cz` | Czech      | `de`    | German           |
| `dk` | Danish     | `en`    | English          |
| `es` | Spanish    | `fa`    | Farsi/Persian    |
| `fr` | French     | `fr-BE` | French (Belgium) |
| `he` | Hebrew     | `hr`    | Croatian         |
| `hu` | Hungarian  | `id`    | Indonesian       |
| `it` | Italian    | `ja`    | Japanese         |
| `ko` | Korean     | `lt`    | Lithuanian       |
| `lv` | Latvian    | `nl`    | Dutch            |
| `no` | Norwegian  | `pl`    | Polish           |
| `pt` | Portuguese | `ro`    | Romanian         |
| `ru` | Russian    | `sr`    | Serbian          |
| `sv` | Swedish    | `tr`    | Turkish          |
| `uk` | Ukrainian  | `vi`    | Vietnamese       |
| `zh` | Chinese    | `hi`    | Hindi            |
| `bn` | Bengali    | `ta`    | Tamil            |
| `te` | Telugu     | `th`    | Thai             |
| `sw` | Swahili    | `ms`    | Malay            |

## Getting Started

```typ
#import "@preview/numeris-scribere:0.1.3": *

#let myNumber = 3254

- #spell-number(myNumber, lang: "de")
- #spell-number(myNumber, lang: "en")
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-dark.svg">
  <img alt="The number 3254 spelled in English and German" src="./thumbnail-light.svg">
</picture>


## Usage

```typ
#import "@preview/numeris-scribere:0.1.3": *

#let myNumber = 3254

- #spell-number(myNumber, lang: "de")
- #spell-number(myNumber, lang: "en")
- #spell-number(myNumber, lang: "es")
- #spell-number(myNumber, lang: "ar")
- #spell-number(myNumber, lang: "ja")
```

## Thanks to

- https://github.com/forzagreen/n2words for the actual logic
- https://github.com/lublak/typst-ctxjs-package for bringing javascript to typst
- typst for being awesome
- the https://github.com/typst-community/typst-package-template template
- https://github.com/Raphael-CV/frogst for giving me the inspiration to do this
