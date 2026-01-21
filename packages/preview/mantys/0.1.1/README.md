# Mantys (v0.1.1)

> **MAN**uals for **TY**p**S**t

Template for documenting [typst](https://github.com/typst/typst) packages and templates.

## Usage

Just import the package at the beginning of your manual:
```typst
#import "@preview/mantys:0.1.1": *
```

Mantys supports **Typst 0.11.0** and newer.

## Writing basics

A basic template for a manual could look like this:

```typst
#import "@local/mantys:0.1.1": *

#import "your-package.typ"

#show: mantys.with(
	name:		"your-package-name",
	title: 		[A title for the manual],
	subtitle: 	[A subtitle for the manual],
	info:		[A short descriptive text for the package.],
	authors:	"Your Name",
	url:		"https://github.com/repository/url",
	version:	"0.0.1",
	date:		"date-of-release",
	abstract: 	[
		A few paragraphs of text to describe the package.
	],

	example-imports: (your-package: your-package)
)

// end of preamble

# About
#lorem(50)

# Usage
#lorem(50)

# Available commands
#lorem(50)

```

Use `#command(name, ..args)[description]` to describe commands and `#argument(name, ...)[description]` for arguments:

```typst
#command("headline", arg[color], arg(size:1.8em), sarg[other-args], barg[body])[
	Renders a prominent headline using #doc("meta/heading").

	#argument("color", type:"color")[
    The color of the headline will be used as the background of a #doc("layout/block") element containing the headline.
  ]
  #argument("size", default:1.8em)[
    The text size for the headline.
  ]
  #argument("sarg", is-sink:true)[
    Other options will get passed directly to #doc("meta/heading").
  ]
  #argument("body", type:"content")[
    The text for the headline.
  ]

  The headline is shown as a prominent colored block to highlight important news articles in the newsletter:

  #example[```
  #headline(blue, size: 2em, level: 3)[
    #lorem(8)
  ]
  ```]
]
```

The result might look something like this:

![Example for a headline command with Mantys](docs/assets/headline-example.png)

For a full reference of available commands read [the manual](manual.pdf).

## Changelog

### Version 0.1.1

- Added template files for submission to _Typst Universe_.

### Verison 0.1.0

- Refactorings and some style changes
- Updated manual.
- Restructuring of package repository.

### Version 0.0.4

- Added integration with [tidy](https://github.com/Mc-Zen/tidy).
- Fixed issue with types in argument boxes.
- `#lambda` now uses `#dtype`

#### Breaking changes

- Adapted `scope` argument for `eval` in examples.
	- `#example()`, `#side-by-side()` and `#shortex()` now support the `scope` and `mode` argument.
	- The option `example-imports` was replaced by `examples-scope`.

### Version 0.0.3

- It is now possible to load a packages' `typst.toml` file directly into `#mantys`:
	```typst
	#show: mantys.with( ..toml("typst.toml") )
	```
- Added some dependencies:
	- [jneug/typst-tools4typst](https://github.com/jneug/typst-tools4typst) for some common utilities,
	- [jneug/typst-codelst](https://github.com/jneug/typst-codelst) for rendering examples and source code,
	- [Pablo-Gonzalez-Calderon/showybox-package](https://github.com/Pablo-Gonzalez-Calderon/showybox-package) for adding frames to different areas of a manual (like examples).
- Redesign of some elements:
	- Argument display in command descriptions,
	- Alert boxes.
- Added `#version(since:(), until:())` command to add version markers to commands.
- Styles moved to a separate `theme.typ` file to allow easy customization of colors and styles.
- Added `#func()`, `#lambda()` and `#symbol()` commands, to handle special cases for values.
- Fixes and code improvements.

### Version 0.0.2

- Some major updates to the core commands and styles.

### Version 0.0.1

- Initial release.
