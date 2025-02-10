> **Note**
>
> This project is greatly inspired by and mainly edited based on [typst-fontawesome](https://github.com/duskmoon314/typst-fontawesome).

<h2 align="center">
  <img alt="use-tabler-icons" src="assets/splash.svg">
</h2>

A Typst library for [Tabler Icons](https://github.com/tabler/tabler-icons), a set of over 5700 free MIT-licensed high-quality SVG icons.

## Usage
### Install Font
Download [latest release of tabler-icons](https://github.com/tabler/tabler-icons/releases) and install `webfont/fonts/tabler-icons.ttf`. Or, if you are using Typst web app, simply upload the font file to your project.

### Import the Library
#### Using the Typst Packages
You can install the library using the typst packages:
```typst
#import "@preview/use-tabler-icons:0.6.0": *
```

#### Manually Install
Just copy all files under [`src`](https://github.com/zyf722/typst-tabler-icons/tree/main/src) to your project and rename them to avoid naming conflicts.

Then, import `lib.typ` to use the library:
```typst
#import "lib.typ": *
```

### Use the Icons
You can use the `tabler-icon` function to create an icon with its name:
```typst
#tabler-icon("calendar")
```

Or you can directly use the `ti-` prefix :
```typst
#ti-calendar()
```

As these icons are actually text with custom font, you can pass any text attributes to the function:
```typst
#tabler-icon("calendar", fill: blue)
```

Refer to [`gallery.pdf`](https://github.com/zyf722/typst-tabler-icons/tree/main/gallery/gallery.pdf) and [Tabler Icons website](https://tabler.io/icons) for all available icons.

## Contributing
[Pull Requests](https://github.com/zyf722/typst-tabler-icons/pulls) are welcome!

It is strongly recommended to follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification when writing commit messages and creating pull requests.

### Github Actions Workflow
This package uses a daily run [Github Actions workflow](https://github.com/zyf722/typst-tabler-icons/tree/main/.github/workflows/build.yml) to keep the library up-to-date with the latest version of Tabler Icons, which internally runs [`scripts/generate.mjs`](https://github.com/zyf722/typst-tabler-icons/tree/main/scripts/generate.mjs) to generate Typst source code of the library and gallery.

## License
[MIT](https://github.com/zyf722/typst-tabler-icons/tree/main/LICENSE)
