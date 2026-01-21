# Changelog

## Unreleased

## 0.4.2

> [!TIP]
> For Typst v0.12.0 and later
> A new function is introduced `register-glossary`.
> Recommended usage is the following:
> ```diff
>  #import "@preview/glossarium:0.4.0": make-glossary, register-glossary, print-glossary, gls, glspl
>  #show: make-glossary
> + #let entry-list = (...)
> + #register-glossary(entry-list)
> ... // Your document body
>  #print-glossary(
> - (
> -   ...
> - )
> +  entry-list
>  )
> ```

> [!NOTE]
> Deprecate `location` argument in queries

> [!TIP]
> `short` is no longer **required**, but **semi-optional**.
> Accept `short` or `long` for an entry, but not neither.

## 0.4.1

- Resolved an issue causing Glossarium to crash when all entries had a defined, non-empty group.

## 0.4.0

- Support for plurals has been implemented, showcased in [examples/plural-example/main.typ](examples/plural-example). Contributed by [@St0wy](https://github.com/St0wy).
- The behavior of the gls and glspl functions has been altered regarding calls on undefined glossary keys. They now cause panics. Contributed by [@St0wy](https://github.com/St0wy).

## 0.3.0

- Introducing support for grouping terms in the glossary. Use the optional and case-sensitive key `group` to assign terms to specific groups. The appearanceof the glossary can be customized with the new parameter `enable-group-pagebreak`, allowing users to insert page breaks between groups for better organization. Contributed by [indicatelovelace](https://github.com/indicatelovelace).

## 0.2.6

### Added

- A new boolean parameter `disable-back-references` has been introduced. If set to true, it disable the back-references (the page number at the end of the description of each term). Please note that disabling back-references only disables the display of the page number, if you don't have any references to your glossary terms, they won't show up unless the parameter `show-all` has been set to true.

## 0.2.5

### Fixed

- Fixed a bug where there was 2 space after a reference. Contributed by [@drupol](https://github.com/drupol)

## 0.2.4

### Fixed

- Fixed a bug where the reference would a long ref even when "long" was set to false. Contributed by [@dscso](https://github.com/dscso)

### Changed

- The glossary appearance have been improved slightlyby. Contributed by [@JuliDi](https://github.com/JuliDi)

## Previous versions did not have a changelog entry