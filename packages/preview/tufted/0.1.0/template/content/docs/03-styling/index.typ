#import "../index.typ": template, tufted
#show: template.with(title: "Styling")

= Styling

The visual appearance of the website is controlled by CSS.

== Default Stylesheets
The template accepts a `css` argument which takes an array of URLs or paths to stylesheets. By default, it loads three stylesheets:

```typst
#let tufted-web(
  // ...
  css: (
    "https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",
    "/assets/tufted.css",
    "/assets/custom.css",
  ),
  // ...
)
```

== Customizing Styles
To customize the look of your website, simply modify `assets/custom.css`. Since it is loaded last by default, your rules will override the others.

For example, to change link colors:

```css
a {
  color: #ff0000;
}
```

== Overriding Stylesheets
To override the default stylesheets, you can provide your own list of stylesheets in `config.typ`. For example, to use only a custom stylesheet:

```typst
#import "@preview/tufted:0.1.0"

#let template = tufted.tufted-web.with(
  css: ("/assets/style.css",),
)
```
