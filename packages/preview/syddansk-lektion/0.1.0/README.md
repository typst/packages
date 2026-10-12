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

## Known issues

When available, the template will use the Liberation Sans font family, a free
alternative to Arial. The latter is only used if Liberation Sans is not
available, or if a codepoint is not found for it. Hence, it is perfectly fine to
only have one of the two font families on your system. However, Typst will
still issue a warning (see [issue
\#6010](https://github.com/typst/typst/issues/6010)), which you can safely
ignore.

## Licensing

The licence mentioned in the `typst.toml` manifest file covers the whole
project, except for `logo.png`. The latter is released under the [redistribution
terms](https://designguide.sdu.dk/brandguide_en/#logo:~:text=The%20SDU%20logo%20may%20be%20redistributed%20as%20part%20of%20larger%20works%2C%20such%20as%20document%20or%20presentation%20templates%2C%20if%20they%20comply%20with%20SDU%E2%80%99s%20visual%20identity%20guidelines%20and%20include%20a%20reference%20to%20these%20guidelines)
of the copyright holder, Southern Denmark University.
