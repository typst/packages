# Postercise

*Postercise* allows users to easily create academic research posters with different themes using [Typst](https://typst.app).

![GitHub](https://img.shields.io/github/license/dangh3014/postercise)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/dangh3014/postercise)
![GitHub Repo stars](https://img.shields.io/github/stars/dangh3014/postercise)


## Getting started

You can get **Postercise** from the official package repository by entering the following.
```typ
#import "@preview/postercise:0.1.0": *
```

Another option is to use **Postercise** as a local module by downloading the package files into your project folder.

Next you will need to import a theme, set up the page and font, and call the `show` command.
```typ
#import themes.basic: *

#set page(width: 24in, height: 18in)
#set text(size: 24pt)

#show: theme
```

To add content to the poster, use the `poster-content` command.

```typ
#poster-content()[
  // Content goes here
]
```

There are a few options for types of content that should be added inside the `poster-content`. The body of the poster can be typed as normal, or two box styles are provided to headings and/or highlight content in special ways.

```typ
#normal-box[]
#focus-box[]
```

Basic information like title and authors is placed as options using the `poster-header` script.

```typ
#poster-header(
  title: [Title],
  authors: [Author],
)
```


Finally, additional content can be added to the footer with the `poster-footer` script.
```typ
#poster-footer[]
```

Again, as a reminder, all of these scripts should be called from inside of the `poster-content` block.

Using these commands, it is easy to produce posters like the following:
![Examples](https://github.com/dangh3014/postercise/blob/main/examples/postercise-examples.png)

## More details
### `themes`
Currently, 3 themes are available. Use one of these `import` commands to load that theme.
```typ
#import themes.basic: *
#import themes.better: *
#import themes.boxes: *
```

### `show: theme.with()`
Theme options allow you to adjust the color scheme, as well as the color and size of the content in the header. The defaults are shown below. (The 'better.typ' theme defaults to different titletext color and size.)
```typ
#show: theme.with(
  primary-color: rgb(28,55,103), // Dark blue
  background-color: white,
  accent-color: rgb(243,163,30), // Yellow
  titletext-color: white,
  titletext-size: 2em,
)
```

### `poster-content()[]`
The only option for the main content is the number of columns. This defaults to 3 for most themes. For the "better.typ" theme, there is 1 column and content is placed in the leftmost column below `poster-header`.
```typ
#poster-content(col: 3)[
  // Content goes here
]
```

### `normal-box()[]` and `focus-box()[]`
By default, these boxes use the no fill and the accent-color fill, respectively. However, they do accept color as an option, and will add a primary-color stroke around the box if a color is given. For the "better.typ" theme, use `focus-box` to place content in the center column.
```typ
#normal-box(color: none)[
  // Content
]

#focus-box(color: none)[
  // Content
]
```


### `poster-header()`
Available options for the poster header for most themes are shown below. Note that logos should be explicitly labeled as images. Logos are not currently displayed in the header in the "better.typ" theme.
```typ
#poster-header(
  title: [Title],
  subtitle: [Subtitle],
  author: [Author],
  affiliation: [Affiliation],
  logo-1: image("placeholder.png")
  logo-2: image("placeholder.png") 
)
```

### `poster-footer[]`
This command does not currently have any extra options. The content is typically placed at the bottom of the poster, but it is placed in the rightmost column for the "better.typ" theme.
```typ
#poster-footer[
  // Content
]
```

## Known Issues
- The bibliography does not work properly and must be done manually
- Figure captions do not number correctly and must be done manually

## Planned Features/Themes
- Themes that use color gradients and background images
- Add QR code generation

