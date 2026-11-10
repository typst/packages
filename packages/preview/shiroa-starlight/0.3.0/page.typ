
#import "mod.typ": *

// ---

#div({
  header(class: "header", virt-slot("header"))
  nav.with(class: "sidebar")({
    div.with(id: "starlight__sidebar", class: "sidebar-pane")({
      div(class: "sidebar-content sl-flex", include "page-sidebar.typ")
    })
  })
  div(class: "main-frame", div.with(class: "lg:sl-flex")({
    {
      if has-toc {
        h.aside.with(
          class: "right-sidebar-container",
          data-has-toc: "",
        )({
          div.with(class: "right-sidebar")({
            include "page-right-sidebar.typ"
          })
        })
      }

      div(class: "main-pane", include "page-main.typ")
    }
  }))
})

#add-styles(
  ```css
  html:not([data-has-toc]) {
    --sl-mobile-toc-height: 0rem;
  }
  html:not([data-has-sidebar]) {
    --sl-content-width: 67.5rem;
  }
  /* Add scroll padding to ensure anchor headings aren't obscured by nav */
  html {
    /* Additional padding is needed to account for the mobile TOC */
    scroll-padding-top: calc(1.5rem + var(--sl-nav-height) + var(--sl-mobile-toc-height));
  }
  main {
    padding-bottom: 3vh;
  }
  @media (min-width: 50em) {
    [data-has-sidebar] {
      --sl-content-inline-start: var(--sl-sidebar-width);
    }
  }
  @media (min-width: 72em) {
    html {
      scroll-padding-top: calc(1.5rem + var(--sl-nav-height));
    }
  }

  @layer starlight.core {
    .page {
      flex-direction: column;
      min-height: 100vh;
    }

    .header {
      z-index: var(--sl-z-index-navbar);
      position: fixed;
      inset-inline-start: 0;
      inset-block-start: 0;
      width: 100%;
      height: var(--sl-nav-height);
      border-bottom: 1px solid var(--sl-color-hairline-shade);
      padding: var(--sl-nav-pad-y) var(--sl-nav-pad-x);
      padding-inline-end: var(--sl-nav-pad-x);
      background-color: var(--sl-color-bg-nav);
    }

    :global([data-has-sidebar]) .header {
      padding-inline-end: calc(
        var(--sl-nav-gap) + var(--sl-nav-pad-x) + var(--sl-menu-button-size)
      );
    }

    .sidebar-pane {
      visibility: var(--sl-sidebar-visibility, hidden);
      position: fixed;
      z-index: var(--sl-z-index-menu);
      inset-block: var(--sl-nav-height) 0;
      inset-inline-start: 0;
      width: 100%;
      background-color: var(--sl-color-black);
      overflow-y: auto;
    }

    [data-mobile-menu-expanded] .sidebar-pane {
      --sl-sidebar-visibility: visible;
    }

    .sidebar-content {
      height: 100%;
      min-height: max-content;
      padding: 1rem var(--sl-sidebar-pad-x) 0;
      flex-direction: column;
      gap: 1rem;
    }

    @media (min-width: 50rem) {
      .sidebar-content::after {
        content: '';
        padding-bottom: 1px;
      }
    }

    .main-frame {
      padding-top: calc(var(--sl-nav-height) + var(--sl-mobile-toc-height));
      padding-inline-start: var(--sl-content-inline-start);
    }

    @media (min-width: 50rem) {
      :global([data-has-sidebar]) .header {
        padding-inline-end: var(--sl-nav-pad-x);
      }
      .sidebar-pane {
        --sl-sidebar-visibility: visible;
        width: var(--sl-sidebar-width);
        background-color: var(--sl-color-bg-sidebar);
        border-inline-end: 1px solid var(--sl-color-hairline-shade);
      }
    }
  }
  ```,
)
