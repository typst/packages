
#import "mod.typ": *

// ---

#div.with(class: "lg:sl-hidden")({
  if has-toc {
    include "table-of-contents-mobile.typ"
  }
})
#div.with(class: "right-sidebar-panel sl-hidden lg:sl-block")({
  div.with(class: "sl-container page-sidebar")({
    if has-toc {
      // data-min-h={toc.minHeadingLevel} data-max-h={toc.maxHeadingLevel}
      h2(id: "starlight__on-this-page")[On this page]
      // <TableOfContentsList toc={toc.items} />
      include "table-of-contents.typ"
    }
  })
})

#add-styles(
  ```css
  @layer starlight.core {
    .sl-container.page-sidebar {
      width: calc(var(--sl-sidebar-width) - 2 * var(--sl-sidebar-pad-x));
    }
    .right-sidebar-panel {
      padding: 1rem var(--sl-sidebar-pad-x);
    }
    .right-sidebar-panel h2 {
      color: var(--sl-color-white);
      font-size: var(--sl-text-h5);
      font-weight: 600;
      line-height: var(--sl-line-height-headings);
      margin: 0;
      margin-bottom: 0.5rem;
    }
    @media (min-width: 72rem) {
      .sl-container.page-sidebar {
        max-width: calc(
          (
            (
                100vw - var(--sl-sidebar-width) - 2 * var(--sl-content-pad-x) - 2 *
                  var(--sl-sidebar-pad-x)
              ) * 0.25 /* MAGIC NUMBER 🥲 */
          )
        );
      }
    }
  }
  ```,
)
