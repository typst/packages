/// Common utility functions for the hypraw package.

/// Checks if the current compilation target is HTML.
#let is-html-target() = {
  dictionary(std).keys().contains("html") and std.target() == "html"
}

/// Constructs a space-separated CSS class string, filtering out `none` values.
#let class-list(..cls) = cls.pos().filter(it => it != none).join(" ")
