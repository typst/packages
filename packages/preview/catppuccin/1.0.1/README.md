<h3 align="center">
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/logos/exports/1544x1544_circle.png" width="100" alt="Logo"/><br/>
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
	Catppuccin for <a href="https://typst.app/">Typst</a>
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
</h3>

<p align="center">
	<a href="https://github.com/catppuccin/typst/stargazers"><img src="https://img.shields.io/github/stars/catppuccin/typst?colorA=363a4f&colorB=b7bdf8&style=for-the-badge"></a>
	<a href="https://github.com/catppuccin/typst/issues"><img src="https://img.shields.io/github/issues/catppuccin/typst?colorA=363a4f&colorB=f5a97f&style=for-the-badge"></a>
	<a href="https://github.com/catppuccin/typst/contributors"><img src="https://img.shields.io/github/contributors/catppuccin/typst?colorA=363a4f&colorB=a6da95&style=for-the-badge"></a>
</p>

<p align="center">
	<img src="https://raw.githubusercontent.com/catppuccin/typst/main/assets/previews/preview.webp"/>
</p>

## Previews

<details>
<summary>🌻 Latte</summary>
<img src="https://raw.githubusercontent.com/catppuccin/typst/main/assets/previews/latte.webp"/>
</details>
<details>
<summary>🪴 Frappé</summary>
<img src="https://raw.githubusercontent.com/catppuccin/typst/main/assets/previews/frappe.webp"/>
</details>
<details>
<summary>🌺 Macchiato</summary>
<img src="https://raw.githubusercontent.com/catppuccin/typst/main/assets/previews/macchiato.webp"/>
</details>
<details>
<summary>🌿 Mocha</summary>
<img src="https://raw.githubusercontent.com/catppuccin/typst/main/assets/previews/mocha.webp"/>
</details>

## Documentation

Two versions of the documentation are available!

- [Mocha](./manual/manual_mocha.pdf)
- [Latte](./manual/manual_latte.pdf)

Each document is styled using this package!

## Installation & Usage

### General Use

In your project, import the package (be sure to replace the version number with the correct one) with

```typst
#import "@preview/catppuccin:1.0.1": catppuccin, flavors
```

To format your document with a theme, use the following syntax towards the top of your document:

```typst
#show: catppuccin.with(flavors.mocha)
```

Replace `mocha` with the flavour of your choice! This can also be passed as a string literal `"mocha"`.

### Advanced Usage

For users who wish to further extend their documents, graphics, or packages, you can access each flavor's palette to directly use the colors in your own code.

```typst
#import "@preview/catppuccin:1.0.1": flavors, get-flavor

#let flavor = get-flavor("mocha")
// or: #let flavor = flavors.mocha
#let palette = flavor.colors

The current flavor is #flavor.name #flavor.emoji.

#let color-list = (
  palette.values().map(v => v.name + " (" + text(fill: v.rgb, v.hex) + ")")
)
Colors: #list(..color-list)
```

For more information, check out the section on the **Flavor Schema** in the manual.

## 💝 Thanks to

- [TimeTravelPenguin](https://github.com/TimeTravelPenguin)

&nbsp;

<p align="center">
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" />
</p>

<p align="center">
	Copyright &copy; 2021-present <a href="https://github.com/catppuccin" target="_blank">Catppuccin Org</a>
</p>

<p align="center">
	<a href="https://github.com/catppuccin/catppuccin/blob/main/LICENSE"><img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&logoColor=d9e0ee&colorA=363a4f&colorB=b7bdf8"/></a>
</p>
