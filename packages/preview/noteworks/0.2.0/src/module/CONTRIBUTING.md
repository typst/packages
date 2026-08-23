# Contributing to Noteworthy Modules

This repository houses the standard library of modules for the Noteworthy framework. We welcome contributions of new modules or enhancements to existing ones.

## Module Development Philosophy

Noteworthy follows a modular architecture designed to separate **logic** from **styling**. Adhering to this philosophy is required for your module to be accepted.

### 1. Separation of Concerns

-   **Implementation Files** (`draw.typ`, `impl.typ`): These files contain the raw logic.
    -   They MAY accept a `theme` parameter.
    -   They **MUST NOT** hardcode theme values (e.g., specific hex codes like `#ff0000`).
    -   ALWAYS use default fallbacks: `theme.at("primary", default: black)`.
-   **Module Entry Point** (`mod.typ`): This is the public interface.
    -   It imports the `nw-theme` accessor from Core.
    -   It wraps implementation functions in `context` to inject the theme automatically.
    -   It exports only the user-facing wrappers.

### 2. File Structure

A standard module structure looks like this:

```text
my-module/
├── mod.typ      # The entry point (exports themed wrappers)
├── impl.typ     # The logic (pure functions)
├── draw.typ     # Drawing logic (if using CeTZ)
└── README.md    # Module-specific documentation
```

### 3. Creating a New Module

1.  **Draft Implementation**: Write your raw functions in `impl.typ`.
    ```typst
    // impl.typ
    #let raw-alert(body, theme: (:)) = {
       let color = theme.at("warning", default: yellow)
       block(fill: color, body)
    }
    ```
2.  **Create `mod.typ`**:
    ```typst
    // mod.typ
    #import "../../core/setup.typ": nw-theme
    #import "impl.typ": raw-alert

    // Export the themed wrapper (nw-theme() reads the document
    // configuration state, so the call needs a context)
    #let alert(body) = context raw-alert(body, theme: nw-theme())
    ```
3.  **Test**: Ensure it works with different themes active.

## Code of Conduct

Please maintain a respectful and welcoming environment for all contributors.

## Pull Requests

1. Fork this repository.
2. Create a feature branch.
3. Submit a PR with a description of your new module or fix.
