
#import "mod.typ": *

#let social-icons(links) = {
  import "icons.typ": builtin-icon
  // ---

  for (href: href, label: link-label, icon: icon) in links {
    a.with(href: href, rel: "me", class: "sl-flex social-icon")({
      span(class: "sr-only", link-label)
      if type(icon) == str { builtin-icon(icon) } else { icon }
    })
  }

  add-styles.with(cond: links.len() > 0)(
    ```css
    @layer starlight.core {
      a.social-icon {
        color: var(--sl-color-text-accent);
        padding: 0.5em;
        margin: -0.5em;
      }
      a.social-icon:hover {
        opacity: 0.66;
      }
    }
    ```,
  )
}
