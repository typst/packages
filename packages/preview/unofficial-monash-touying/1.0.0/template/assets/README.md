# Assets

Put images for your presentation here.

The default title graphic (`title-graphic: auto`) is a logo-free background
derived from the Quarto Monash presentation template, which is distributed
under the CC0 1.0 Universal public domain dedication. A copy is in
`monash-presentation/background/`. To use your own graphic instead:

```typst
#show: monash-theme.with(
  title-graphic: image("assets/my-background.png", width: 100%, height: 100%, fit: "cover"),
  ...
)
```

Use `title-graphic: none` for a plain cover drawn with shapes. Monash names,
logos, crests, and wordmarks are not bundled; pass your own logo with
`logo: image("assets/logo.svg")` if you have the right to use it.
