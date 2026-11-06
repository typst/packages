# Development

This package is developed in Ubuntu 24.04 (WSL) but the instructions should work for other operating systems as well.

## Configure environment

1. Install rustup and cargo by following the guides in https://www.rust-lang.org/tools/install

1. Install WASM target

    ```console
    rustup target add wasm32-unknown-unknown    
    ```

1. Install [just](https://github.com/casey/just) to run commands

    ```console
    cargo install just
    ```

1. Install [cwebp](https://developers.google.com/speed/webp/download) (libwebp).
    For Ubuntu, run

    ```console
    sudo apt install webp
    ```

    For other distros, search for for packages named webp, libwebp or libwebp-tools.

    For Windows, install with Scoop or Winget

    ```console
    scoop install webp
    ```

    ```console
    winget install libwebp    
    ```

1. Install development tools

    ```console
    just install-dev-deps
    ```

### Installing package locally

1. Install [showman](https://typst.app/universe/package/showman/)
1. Install package locally to `@preview` (run in root if needed)

    ```console
    showman package ./typst.toml -n preview -o -s
    ```

## Commands

Run tests:

```console
just test
```

Lint code:

```console
just lint
```

Format code:

```console
just format
```

Build Rust binary and copy WASM file:

```console
just build
```

Render all preview images

```console
just render
```

> [!IMPORTANT]
> Install package locally before running the render command
