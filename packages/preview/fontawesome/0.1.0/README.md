# typst-fontawesome

A Typst library for Font Awesome icons through the desktop fonts.

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

### Import the library

#### Using the typst packages

You can install the library using the typst packages:

`#import "@preview/fontawesome:0.1.0": *`

#### Manually install

Put the `lib.typ` file in your project directory, and import it:

`#import "lib.typ": *`

Here I recommend renaming the `lib.typ` file to `fontawesome.typ` to avoid name conflicts.

### Use the icons

You can use the `fa-icon` function to create an icon with its name:

`fa-icon("chess-queen")`

Or you can use the `fa-` prefix to create an icon with its name:

`fa-chess-queen()`

#### Full list of icons

You can find all icons on the [official website](https://fontawesome.com/search?o=r&m=free)

#### Different sets

By default, the library uses the free set. You can change it by passing the `fa-set` parameter to `fa-icon`:

`#fa-icon("github", fa-set: "Brands")`

Or you can change the default set by changing the `FA_SET` state.

`#fa-icon("github")` This cannot render the icon because the default set is `Free`.

`FA_SET.update("Brands")`

`#fa-icon("github")` This can render the icon because the default set is `Brands` now.

Reset the default set:

`FA_SET.update("Free")`

The `FA_VERSION` state can also be used to change the default font version. Its original value is `Font Awesome 6`.

#### Customization

The `fa-icon` function passes args to `text`, so you can customize the icon by passing parameters to it:

`#fa-icon("chess-queen", fill: blue)`

## Example

See the [`example.typ`](https://typst.app/project/rQwGUWt5p33vrsb_uNPR9F) file for a complete example.

## Contribution

Feel free to open an issue or a pull request if you find any problems or have any suggestions.

### Python helper

The `helper.py` script is used to download fonts and generate typst code. I aim only to use standard python libraries, so running it on any platform with python installed should be easy.

## License

This library is licensed under the MIT license. Feel free to use it in your project.
