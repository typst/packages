> **Note**
>
> This project is greatly inspired by and mainly edited based on [typst-fontawesome](https://github.com/duskmoon314/typst-fontawesome).

<h2 align="center">
  <img alt="use-tabler-icons" src="assets/banner.svg" title="use-tabler-icons banner">
</h2>

A Typst library for [Tabler Icons](https://github.com/tabler/tabler-icons), a set of over 5800 free MIT-licensed high-quality SVG icons.

## Usage
### Install Font
Install [the webfont for Tabler Icons](https://docs.tabler.io/icons/libraries/webfont) before using this library. Or, if you are using Typst web app, simply upload the font file to your project.

> **Note**
>
> Since Tabler Icons v3.36.0, filled icons have been separated into a different font file. If you want to use filled icons, make sure to install both the regular ` tabler-icons.ttf` and filled `tabler-icons-filled.ttf` font files.

### Import the Library
#### Using the Typst Packages
You can install the library using the typst packages:
```typst
#import "@preview/use-tabler-icons:0.23.0": *
```

#### Manually Install
Just copy all files under [`src`](https://github.com/zyf722/typst-tabler-icons/blob/main/src) to your project and rename them to avoid naming conflicts.

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

Refer to [`gallery.pdf`](https://github.com/zyf722/typst-tabler-icons/blob/main/gallery/gallery.pdf) and [Tabler Icons website](https://tabler.io/icons) for all available icons.

## License
[MIT](LICENSE)
