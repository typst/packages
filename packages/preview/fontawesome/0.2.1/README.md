# typst-fontawesome

A Typst library for Font Awesome icons through the desktop fonts.

p.s. The library is based on the Font Awesome 6 desktop fonts (v6.5.2)

## Usage

### Install the fonts

You can download the fonts from the official website: https://fontawesome.com/download

Or you can use the helper script to download the fonts and metadata:

`python helper.py -dd -v {version}`

Here `-dd` means to download and extract the zip file. You can use `-d` to only download the zip file.

After downloading the zip file, you can install the fonts depending on your OS.

#### Typst web app

You can simply upload the `otf` files to the web app and use them with this package.

#### Mac

You can double click the `otf` files to install them.

#### Windows

You can right-click the `otf` files and select `Install`.

### Import the library

#### Using the typst packages

You can install the library using the typst packages:

`#import "@preview/fontawesome:0.2.1": *`

#### Manually install

Copy all files start with `lib` to your project and import the library:

`#import "lib.typ": *`

There are three files:

- `lib.typ`: The main entrypoint of the library.
- `lib-impl.typ`: The implementation of `fa-icon`.
- `lib-gen.typ`: The generated icons.

I recommend renaming these files to avoid conflicts with other libraries.

### Use the icons

You can use the `fa-icon` function to create an icon with its name:

`#fa-icon("chess-queen")`

Or you can use the `fa-` prefix to create an icon with its name:

`#fa-chess-queen()` (This is equivalent to `#fa-icon().with("chess-queen")`)

You can also set `solid` to `true` to use the solid version of the icon:

`#fa-icon("chess-queen", solid: true)`

If the icon only has a solid version, you can omit the `solid` parameter because the library automatically sets `solid` to `true` for these icons. For instance, the generated function for these icons would be like `#fa-icon().with("arrow-trend-up", solid: true)`.

However, some icons (e.g. 0, 1, 2...) have a regular version that isn't mentioned in the metadata. In this case, you need to set `solid` to `false` to use the regular version.

Notice that `fa-icon` currently doesn't automatically set `solid` to `true` for icons that only have a solid version. Thus, you may not get the expected glyph if you don't set `solid` to `true` for these icons. I haven't decided whether to change this behavior yet.

#### Full list of icons

You can find all icons on the [official website](https://fontawesome.com/search?o=r&m=free)

#### Different sets

By default, the library uses two sets: `Free` and `Brands`.
That is, three font files are used:

- Font Awesome 6 Free (Also named as _Font Awesome 6 Free Regular_)
- Font Awesome 6 Free Solid
- Font Awesome 6 Brands

Due to some limitations of typst 0.11.0, the regular and solid versions are treated as different fonts.
In this library, `solid` is used to switch between the regular and solid versions.

To use `Pro` or other sets, you can pass the `font` parameter to the inner `text` function: \
`fa-icon("github", font: "Font Awesome 6 Pro Solid")`

But you need to install the fonts first and take care of `solid` yourself.

#### Customization

The `fa-icon` function passes args to `text`, so you can customize the icon by passing parameters to it:

`#fa-icon("chess-queen", fill: blue)`

## Example

See the [`example.typ`](https://typst.app/project/rQwGUWt5p33vrsb_uNPR9F) file for a complete example.

## Contribution

Feel free to open an issue or a pull request if you find any problems or have any suggestions.

### Python helper

The `helper.py` script is used to download fonts and generate typst code. I aim only to use standard python libraries, so running it on any platform with python installed should be easy.

### Repo structure

- `helper.py`: The helper script to download fonts and generate typst code.
- `lib.typ`: The main entrypoint of the library.
- `lib-impl.typ`: The implementation of `fa-icon`.
- `lib-gen.typ`: The generated functions of icons.
- `example.typ`: An example file to show how to use the library.
- `gallery.typ`: The generated gallery of icons. It is used in the example file.

## License

This library is licensed under the MIT license. Feel free to use it in your project.
