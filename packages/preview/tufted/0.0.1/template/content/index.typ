#import "../config.typ": *
#show: template

= `tufted`: A Simple Typst Website Template

This package allows you to build a simple website with *pure* Typst. No dependencies required.

#margin-note({
  image("imgs/tufted-duck-female-with-duckling.webp")
  image("imgs/tufted-duck-male.webp")
})

#margin-note[
  The tufted duck (_Aythya fuligula_) is a medium-sized diving duck native to Eurasia. Known for its diving ability, it can plunge to great depths to forage for food.
]

== Copy template

```shell
typst init @preview/tufted:0.0.1
```

The template has 4 main components:

- `config.typ` --- Core layout configuration.
- `content/` --- Stores all website content.
- `assets/` --- Stores shared static assets, e.g., global CSS.
- `Makefile` --- Used to build the website.

Pages are independently built with `make`. After you run

```shell
make html
```

the HTML will be generated in the `_site/` folder.

== Global configuration

Customize your template in the `config.typ` file, which stores the core layout configuration. Import all definitions from the package, as they will be passed to child pages (this is intended).

```typst
#import "@preview/tufted:0.0.1": *

#let template = tufted-web.with(
  header-links: (
    "/": "Home",
    "/posts/": "Posts",
    "/about/": "About",
  ),
)
```

== Hierarchy and Inheritance

The website is hierarchical. The root imports from `../config.typ`, while child pages import from their parent's `../index.typ` file, enabling inheritance—no need to import from grandparents.

All `**/index.typ` files inside `content/` become pages accessible via their folder path (e.g., `content/posts/index.typ` → `example.com/posts`). Link to pages using `#link("relative/path/")[Click me]`.

You can modify definitions at any level, and child pages will inherit the changes. For example, to change the page title, import all definitions from a parent and modify the `template`:

```typst
#import "../index.typ": *
#show: template.with(title: "New title")
```

== Deploy

The full website code is in the `_site` folder. You can deploy it, for example, via GitHub Actions. Check #link("https://github.com/vsheg/tufted")[the repo] at `/.github/workflows/deploy.yml` to see how.
