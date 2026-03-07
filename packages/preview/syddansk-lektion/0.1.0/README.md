# Syddansk Lektion

An unofficial [Touying](https://typst.app/universe/package/touying) port of
Southern Denmark University's slideshow template.

## Use

After importing the package with

```typst
#import "@preview/syddansk-lektion:0.1.0": *
```

you can apply it to your project by using the following `show` rule.

```typst
#show: sdu-theme.with(
  institution: "IMADA",
  website: "sdu.dk",
  hashtag: "#sdudk",
  // logo: image("my-logo.png", alt: "My custom logo"),
  date: datetime.today(),
  aspect-ratio: "16-9",
  colors: config-colors(
    neutral-lightest: white,
    neutral-darkest: black,
    primary-darkest: rgb("#789d4a"),
    primary-lightest: rgb("#aeb862"),
    secondary-lightest: rgb("#f2c75c"),
  )
)
```

All parameters passed above are optional, and coincide with the default values.
You can now create your [Touying
presentation](https://typst.app/universe/package/touying).

## Colours

Here are the background colours present in SDU's original templates:

- `#aeb862` (gimblet);
- `#ddcba4` (peanut);
- `#d05a57` (indian red);
- `#f2c75c` (cream can);
- `#e1bbb4` (pink skin).

## Functions

The usual Touying template functions `slide`, `title-slide`, `outline-slide`,
and `new-section-slide` are available.

## Advanced usage

Invocations of `sdu-theme` can be further customized by passing more
arguments:
- a number of nominal argument are functions rendering several parts of the
  template. These are `header` (expects content representing the institution),
  `header-right` (expects content representing the website as a first parameter,
  and content representing the hashtag as a second parameter), `footer` (expects
  content representing the logo), and `footer-right` (expects a date);
- the `subslide-preamble` named argument has type content, and renders the
  current slide title;
- all positional arguments but the last are optional Touying configurations to
  be merged together.
