
# Minimal-CV

Yet another John Doe CV.

<a href="thumbnail.png">
    <img src="thumbnail.png" alt="thumbnail" width="300" />
</a>

A Typst CV template with a focus on easy customizability.


## Usage

### From Typst app

Create a new project based on the template [minimal-cv](https://typst.app/universe/package/minimal-cv).

### Locally

The default font is ["Inria Sans"](https://fonts.google.com/specimen/Inria+Sans). Make sure it is installed on your system, or change it in [#Theme](#theme).

Copy the [template](https://raw.githubusercontent.com/lelimacon/typst-minimal-cv/main/template/cv.typ) to your Typst project.

### From a blank project

Import the library :

```typst
#import "@preview/minimal-cv:0.2.0": *
```

Show the root `cv` function :

```typst
#show: cv.with(
  theme: (),
)

= John Doe
== Developer, Developer, Developer

#grid(
  columns: (9fr, 42pt, 6fr),

  [LEFT COLUMN CONTENT],
  {}, // Empty space.
  [RIGHT COLUMN CONTENT],
)
```


## Structural functions

**Section**

```typst
#section(
  theme: (),
  [TITLE_CONTENT],
  [BODY_CONTENT],
)
```

**Entry**

```typst
#entry(
  theme: (),
  right: [FLOATING_CONTENT],

  [GUTTER_CONTENT],
  [TITLE_CONTENT],
  [BODY_CONTENT],
)
```


## Theme

Customize the theme in any of the above functions by specifying the `theme` parameter and overriding keys.

| Key | Type | Default
| --- | ---- | -------
| `spacing` | relative | `14pt`
| `gutter-width` | relative | `42pt`
| `font` | str | `"Inria Sans"`
| `font-size` | relative | `11pt`
| `accent-color` | color | `blue.darken(30%)`
| `body-color` | color | `rgb("222")`
| `gutter-body-color` | color | _inherit_
| `section-style` | "underlined" \| "outlined" \| "box" \| "bullet-point" | "bullet-point"


To edit the theme anywhere else, use the `theme` function :

```typst
#show: theme.with(
  spacing: none,
  gutter-width: none,
  font: none,
  font-size: none,
  accent-color: none,
  body-color: none,
  gutter-body-color: none,
  section-style: none,
)
```


## Widgets

**Progress bar**

```typst
#progress-bar(50%)
```

**Chronology**

Vertical bar with `start` and `end` points.
This functions is only supported in the `#section` gutter.

```typst
#chronology(start: "1980", end: "1999")
```


# Version history

### 0.2.0

- :sparkles: New wiget: Chronology
- :exclamation: Major theming changes
- :exclamation: Removed columns (aside) and titles handling
- Removed page configuration
- :bug: Changed progress bar implementation ([#1])

### 0.1.0

Initial version


[#1]: https://github.com/lelimacon/typst-minimal-cv/issues/1
