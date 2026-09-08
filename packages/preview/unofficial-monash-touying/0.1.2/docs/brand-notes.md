# Monash-Inspired Design Notes

This package is an unofficial community template. It should not present itself as
an official Monash University asset.

## Visual Direction

- Use Monash blue as the dominant academic identity colour.
- Do not use Monash red in the default presentation theme.
- Keep slides clean, spacious, and left-to-right readable.
- Follow the `quarto-monash/presentation` Typst template as the primary visual
  reference.
- Use the full-width blue title bar and Quarto-style footer progress treatment
  for content slides.
- Do not bundle Monash logo, crest, or wordmark assets in the default starter
  deck.

## Current Package Interpretation

The template currently uses:

- `#1969AA` as the primary blue, matching the Quarto Monash Typst template.
- `#C14B14` as the Quarto Monash orange accent for progress and list markers.
- neutral greys for body/footer contrast.
- no bundled Monash logo, crest, or wordmark in the starter deck; users can
  provide their own logo asset through the theme configuration when they have
  appropriate rights.
- a vendored logo-free Quarto Monash background PNG under
  `template/assets/monash-presentation/`.
- a title slide using the logo-free `background/bg-02.png`.
- full-width Monash blue title bars on content slides.
- a footer baseline, orange progress bar, and small grey slide number.

The template vendors only the logo-free Quarto Monash presentation background
needed by the starter deck. If future versions add more background variants,
document the source repository, remove embedded Monash marks unless explicit
redistribution rights are available, and keep paths under `template/assets/`.

## Logo SVG Notes

The official Monash website exposes an SVG path for `monash-logo-mono.svg`, but
direct automated download may be blocked. Wikimedia Commons mirrors a
`Monash University logo.svg` file sourced from that official URL and marks it as
simple geometry/public domain while also warning that it may be trademarked.

The starter template does not vendor a Monash logo, crest, or wordmark. Users
who have appropriate rights can provide their own logo asset and pass:

```typst
#show: monash-theme.with(
  logo: image("assets/your-logo.svg", height: 1.25em),
  ...
)
```

The Quarto Monash background PNG is derived from
`quarto-monash/presentation/_extensions/presentation/_images/` for visual
alignment with that template. The embedded Monash crest and wordmark have been
removed from the bundled starter background. The upstream Quarto Monash
presentation template is distributed under the CC0 1.0 Universal public domain
dedication.

## References

- Monash Malaysia brand guide PDF: <https://www.monash.edu.my/__data/assets/pdf_file/0009/519165/monash-brandguide-2015.pdf>
- Monash core logo guidelines PDF: <https://www.monash.edu/__data/assets/pdf_file/0010/1656523/3.-CoreElements_Our-Logo.pdf>
- Monash overview and motto: <https://www.monash.edu/about/who>
- Monash Learning and Teaching Building: <https://www.monash.edu/learning-teaching/inclusive-education/learning-spaces/ltb>
- Quarto Monash presentation template: <https://github.com/quarto-monash/presentation>
- Quarto Monash CC0 1.0 license: <https://github.com/quarto-monash/presentation?tab=CC0-1.0-1-ov-file>
- Wikimedia Commons mirror page: <https://commons.wikimedia.org/wiki/File:Monash_University_logo.svg>
- Wikimedia Commons SVG file: <https://upload.wikimedia.org/wikipedia/commons/7/7c/Monash_University_logo.svg>
