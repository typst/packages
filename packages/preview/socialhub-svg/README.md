# [Social Media References based on Scalable Vector Graphics (SVG) Icons for Typst](https://github.com/Bi0T1N/typst-socialhub-svg)
The `socialhub-svg` package is designed to help you create your curriculum vitae (CV). It allows you to easily reference your social media profiles with the typical icon of the service plus a link to your profile.

## Features
- Support for popular social media, developer and career platforms
- Uniform design for all entries
- Based on publicly available SVG symbols
- Easy to use
- Allows the customization of the look (extra args are passed to [`text`](https://typst.app/docs/reference/text/text/))

## Usage
### Using Typst's package manager
You can install the library using the [typst packages](https://github.com/typst/packages):
```typst
#import "@preview/socialhub-svg:1.0.0": *
```

### Install manually
Put the `socialhub-svg.typ` file in your project directory and import it:
```typst
#import "socialhub-svg.typ": *
```

### Minimal Example
```typst
// #import "@preview/socialhub-svg:1.0.0": github-info, gitlab-info
#import "socialhub-svg.typ": github-info, gitlab-info

This project was created by #github-info("Bi0T1N"). You can also find me on #gitlab-info("GitLab", rgb("#811052"), url: "https://gitlab.com/Bi0T1N").
```

### Examples
See the [`examples.typ`](examples/examples.typ) file for a complete example. The [generated PDF files](examples/) are also available for preview.

## Contribution
Feel free to open an issue or a pull request if you find any problems or have any suggestions.

## License
This library is licensed under the MIT license. Feel free to use it in your project.
