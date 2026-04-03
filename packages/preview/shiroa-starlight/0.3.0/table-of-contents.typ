
#import "mod.typ": *

// ---

#ul.with(class: "toc")(context {
  if query(heading).len() == 0 {
    return
  }

  let outline-counter = counter("html-outline")
  outline-counter.update(0)
  show outline.entry: it => div(class: "outline-item", style: "--depth: " + str(it.level - 1), {
    outline-counter.step(level: it.level)
    // #sym.section#context outline-counter.display("1.")
    static-heading-link(it.element, body: it.element.body)
  })
  div(class: "outline", outline(title: none))
})


#add-styles(
  ```css
  @layer starlight.core {
    .toc a {
      display: block;
      font-size: var(--sl-text-xs);
      text-decoration: none;
      color: var(--sl-color-gray-3);
      overflow-wrap: anywhere;
    }
    .toc a:hover {
      color: var(--sl-color-white);
    }
    ul.toc {
      padding: 0;
      list-style: none;
    }
    .toc a {
      --pad-inline: 0.5rem;
      display: block;
      border-radius: 0.25rem;
      padding-block: 0.25rem;
      padding-inline: calc(1rem * var(--depth) + var(--pad-inline)) var(--pad-inline);
      line-height: 1.25;
    }
    .toc a[aria-current='true'] {
      color: var(--sl-color-text-accent);
    }
    .toc .isMobile a {
      --pad-inline: 1rem;
      display: flex;
      justify-content: space-between;
      gap: var(--pad-inline);
      border-top: 1px solid var(--sl-color-gray-6);
      border-radius: 0;
      padding-block: 0.5rem;
      color: var(--sl-color-text);
      font-size: var(--sl-text-sm);
      text-decoration: none;
      outline-offset: var(--sl-outline-offset-inside);
    }
    .toc .isMobile:first-child > li:first-child > a {
      border-top: 0;
    }
    .toc .isMobile a[aria-current='true'],
    .toc .isMobile a[aria-current='true']:hover,
    .toc .isMobile a[aria-current='true']:focus {
      color: var(--sl-color-white);
      background-color: unset;
    }
    .toc .isMobile a[aria-current='true']::after {
      content: '';
      width: 1rem;
      background-color: var(--sl-color-text-accent);
      /* Check mark SVG icon */
      -webkit-mask-image: url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHZpZXdCb3g9JzAgMCAxNCAxNCc+PHBhdGggZD0nTTEwLjkxNCA0LjIwNmEuNTgzLjU4MyAwIDAgMC0uODI4IDBMNS43NCA4LjU1NyAzLjkxNCA2LjcyNmEuNTk2LjU5NiAwIDAgMC0uODI4Ljg1N2wyLjI0IDIuMjRhLjU4My41ODMgMCAwIDAgLjgyOCAwbDQuNzYtNC43NmEuNTgzLjU4MyAwIDAgMCAwLS44NTdaJy8+PC9zdmc+Cg==');
      mask-image: url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHZpZXdCb3g9JzAgMCAxNCAxNCc+PHBhdGggZD0nTTEwLjkxNCA0LjIwNmEuNTgzLjU4MyAwIDAgMC0uODI4IDBMNS43NCA4LjU1NyAzLjkxNCA2LjcyNmEuNTk2LjU5NiAwIDAgMC0uODI4Ljg1N2wyLjI0IDIuMjRhLjU4My41ODMgMCAwIDAgLjgyOCAwbDQuNzYtNC43NmEuNTgzLjU4MyAwIDAgMCAwLS44NTdaJy8+PC9zdmc+Cg==');
      -webkit-mask-repeat: no-repeat;
      mask-repeat: no-repeat;
      flex-shrink: 0;
    }
  }
  ```,
)
