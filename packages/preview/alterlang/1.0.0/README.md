# Alterlang

**Alterlang** is a [Typst](typst.app) package that provides translations of mathematical operators into different languages.

Currently, the only supported language is Spanish. However, contributions are welcome to expand support to other languages.

If you would like to see support for a specific language, you may either open an issue with the relevant translations or submit a pull request with the implementation.

## Usage

To use Alterlang in your Typst project, follow these steps:

1. Import the desired language module from the Alterlang package:

   `#import "@preview/alterlang:1.0.0": <lang>`

   Replace `<lang>` with the ISO code of the language you wish to use (e.g., `es` for Spanish).

2. Import the translated operators you want to use:

   `#import <lang>: *`

   Alternatively, you may import only specific operators by listing them explicitly:

   `#import <lang>: sen, lim`

### Example

To use the Spanish translations for `sin` and `lim`:

`#import "@preview/alterlang:1.0.0": es`

`#import es: sen, lim`

This will allow you to use `sen` and `lím` in your mathematical expressions, consistent with Spanish notation.

## Contributing

Translations are maintained in individual files named using the ISO 639-1 language code (e.g., `es.typ` for Spanish). Each file contains the corresponding translations of mathematical operators.

### Guidelines for Contributing

1. Create a new file named `<lang>.typ`, where `<lang>` is the ISO 639-1 code of your target language.
2. Follow the structure of the existing `es.typ` file to ensure consistency.
3. Submit a pull request with your changes.

Ensure your translations are accurate and reflect the mathematical terminology used in the respective language.

## License

This project is open-source and distributed under the terms of the MIT License.
