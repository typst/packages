# Assets

Place presentation-specific assets here.

The template includes a small vendored subset of the Quarto Monash presentation
assets under `monash-presentation/`. The bundled title background is a
logo-free variant; the original embedded Monash crest and wordmark are not
distributed in this starter template.
The Quarto Monash presentation project is distributed under the CC0 1.0
Universal public domain dedication. Monash names, logos, crests, wordmarks, and
marks remain associated with Monash University and should be used according to
relevant brand guidance.

The starter deck passes the title background image to the theme:

```typst
#let monash-titlegraphic = image(
  "assets/monash-presentation/background/bg-02.png",
  width: 100%,
  height: 100%,
  fit: "cover",
)

#show: monash-theme.with(titlegraphic: monash-titlegraphic, ...)
```
