# modern-nudt-slides

An unofficial, community-maintained NUDT-style slide theme for research talks and group meetings, built with Touying.

## Use

Create a project from the template with Typst CLI:

```sh
typst init @preview/modern-nudt-slides:0.1.0
cd modern-nudt-slides
typst compile main.typ main.pdf
```

The generated `main.typ` is a short literature-report example about *Attention Is All You Need*. Edit its cover fields and replace the sample sections with your own content.

## Contents

- `template/main.typ`: editable presentation and example content.
- `theme.typ`: Touying theme implementation.
- `images/`: theme logo and background assets.

## License and assets

The Typst source code is licensed under the MIT License; see [LICENSE](LICENSE). The theme is based on [Touying Simpl NUDT](https://typst.app/universe/package/touying-simpl-nudt).

The `modern-` prefix distinguishes this community-maintained design from the canonical package name. This is an unofficial template and is not published on behalf of NUDT.

The files `images/logo.png` and `images/nudt-vi-nudtbg.png` are National University of Defense Technology visual identity assets. They are not covered by the MIT License and may only be used or redistributed in accordance with the university's branding and intellectual-property policies. University policy permits their distribution in this academic template.
