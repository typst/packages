#import "../index.typ": template, tufted
#show: template.with(title: "Configuration")

= Website Structure

The template has 4 main components:

- `config.typ` --- Core layout configuration.
- `content/` --- Stores all website content.
- `assets/` --- Stores shared static assets, e.g., global CSS.
- `Makefile` --- Used to build the website.

== API

Currently, three functions are implemented:

- `tufted-web` — main template
- `margin-note` — place content in margin notes (limited support)
- `full-width` — place content in full-width containers (limited support)


== Main Configuration

In `config.typ`, you define own template by customizing the `tufted-web` template from the package. Here you customaize the top navigation links and the website title:

```typst
#import "@preview/tufted:0.1.0"

#let template = tufted.tufted-web.with(
  header-links: (
    "/": "Home",
    "/docs/": "Docs",
    "/blog/": "Blog",
    "/cv/": "CV",
    "/about/": "About",
  ),
  title: "Tufted",
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
