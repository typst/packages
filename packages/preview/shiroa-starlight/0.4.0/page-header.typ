
#import "mod.typ": *

#let right-group-item(body, class: none) = div(class: if class != none { class + " " } + "right-group sl-flex", body)

// ---

#div.with(class: "header")({
  div(class: "title-wrapper sl-flex", virt-slot("site-title"))
  div(class: "sl-flex", virt-slot("sl:search"))
  div(class: "sl-flex", virt-slot("sl:right-group"))
})

#add-styles(
  ```css
  @layer starlight.core {
    .header {
      display: flex;
      gap: var(--sl-nav-gap);
      justify-content: space-between;
      align-items: center;
      height: 100%;
    }

    .title-wrapper {
      /* Prevent long titles overflowing and covering the search and menu buttons on narrow viewports. */
      overflow: clip;
      /* Avoid clipping focus ring around link inside title wrapper. */
      padding: 0.25rem;
      margin: -0.25rem;
      min-width: 0;
    }

    .right-group,
    .social-icons {
      align-items: center;
    }
    .social-icons {
      gap: 1rem;
    }
    .right-group +
    .right-group::before {
      content: '';
      margin: 0 0.7rem;
      height: 2rem;
      border-inline-end: 1px solid var(--sl-color-gray-5);
    }

    @media (min-width: 50rem) {
      :global(:root[data-has-sidebar]) {
        --__sidebar-pad: calc(2 * var(--sl-nav-pad-x));
      }
      :global(:root:not([data-has-toc])) {
        --__toc-width: 0rem;
      }
      .header {
        --__sidebar-width: max(0rem, var(--sl-content-inline-start, 0rem) - var(--sl-nav-pad-x));
        --__main-column-fr: calc(
          (
              100% + var(--__sidebar-pad, 0rem) - var(--__toc-width, var(--sl-sidebar-width)) -
                (2 * var(--__toc-width, var(--sl-nav-pad-x))) - var(--sl-content-inline-start, 0rem) -
                var(--sl-content-width)
            ) / 2
        );
        display: grid;
        grid-template-columns:
        /* 1 (site title): runs up until the main content column’s left edge or the width of the title, whichever is the largest  */
          minmax(
            calc(var(--__sidebar-width) + max(0rem, var(--__main-column-fr) - var(--sl-nav-gap))),
            auto
          )
          /* 2 (search box): all free space that is available. */
          1fr
          /* 3 (right items): use the space that these need. */
          auto;
        align-content: center;
      }
    }
  }
  ```,
)

