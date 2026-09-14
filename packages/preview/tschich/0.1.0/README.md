<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/tschich-logo-light.png">
    <source media="(prefers-color-scheme: light)" srcset="docs/tschich-logo-dark.png">
    <img src="docs/tschich-logo-dark.png" width="450" alt="tschich logo">
  </picture>
</div>

<div align="center">

[![Link to the package at Typst universe](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fswitchlex%2Ftschich%2Frefs%2Fheads%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v.&label=Typst%20Universe&labelColor=white&color=grey)](https://typst.app/universe/package/tschich)
[![Link to the manual (pdf) for detailed documentation](https://img.shields.io/badge/Manual-pdf-grey?labelColor=white)](docs/manual.pdf)
[![Link to the license (MIT)](https://img.shields.io/badge/License-MIT-grey?labelColor=white)](./LICENSE)

</div>

---

<div align="center">

tschich is a simple tool for  achieving perfect proportions on the page — no matter the paper's dimensions.

</div>

[![Showcase of the canons provided by tschich applied to an example text.](examples/showcase.png)](examples/example.typ)

---

## Using tschich

Setting up the margins for placing the type area on the page is all about proportion. It must always take the page's width (`a`) and height (`b`) into consideration. These measurements, (if not already known), can be displayed by using:

```typst
#tschich-help
```

Given the page's dimensions, the margins can be automatically set up by using:

```typst
#set page(margin: tschich(a, b))
```

This standard function reproduces a nine part division following van de Graaf's adaption of Villard's canon (as reconstructed by [Jan Tschichold](https://link.springer.com/chapter/10.1007/978-3-0348-7799-2_7)) — that is: the inner margin will be one ninth and the outer margin will be two ninths of the page's width. The same goes for the top and bottom margin in relation to the page's height.

## Advanced usage

Besides this, tschich does also provide a variable version of Villard's canon, an adaption of Tschichold's medieval ideal canon, a function for retrieving the type area's dimensions and a function for centering it on the page. To learn more, simply confer the [manual](docs/manual.pdf).
