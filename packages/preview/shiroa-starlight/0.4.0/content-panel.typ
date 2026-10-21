
#import "mod.typ": *

// ---

#div.with(class: "content-panel")({
  div(class: "sl-container", virt-slot("body"))
})

#add-styles(
  ```css
  @layer starlight.core {
    .content-panel {
      padding: 1.5rem var(--sl-content-pad-x);
    }
    .content-panel + .content-panel {
      border-top: 1px solid var(--sl-color-hairline);
    }
    .sl-container.content-panel {
      max-width: var(--sl-content-width);
    }

    .sl-container.content-panel > :global(* + *) {
      margin-top: 1.5rem;
    }

    @media (min-width: 72rem) {
      .sl-container.content-panel {
        margin-inline: var(--sl-content-margin-inline, auto);
      }
    }
  }
  ```,
)
