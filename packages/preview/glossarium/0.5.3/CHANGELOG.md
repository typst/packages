# Changelog

## 0.5.3

> [!IMPORTANT]
> `glossarium@0.5.3` is compatible with Typst>=0.13.0.

> [!WARNING]
> `glossarium` internals have changed to use `figure.body` instead
> of `figure.caption`. If you have custom show rules, please change accordingly.

## 0.5.2

> [!TIP]
> A new option `use-key-as-short` has been added and is enabled by default
> on `register-glossary`. This option allows writing new entries without
> specifying the `short` field. The `key` field will be used as the `short`
> field. If you want to disable this behavior, you can set the option to `false`.
> ```typ
> #entry-list = (
>   (
>     key: "key",
>   ),
> )
> #register-glossary(entry-list, use-key-as-short: true)
> @key
> ```

> [!TIP]
> Glossarium will now panic if you haven't called `make-glossary` before
> `print-glossary`.

> [!TIP]
> Glossarium now panics if you try to register an entries with
> unknown fields.

> [!IMPORTANT]
> Fix layout divergence when glossary descriptions are nested.

> [!NOTE]
> - Fix an issue where backreferences were queried on the whole document,
>   instead of before `print-glossary`.
> - Fix a regression for versions of Typst before v0.12.0 where `it.body` was
>   returned instead of `it.caption` for `make-glossary`.

## 0.5.1

> [!TIP]
> New group options have been added: `print-glossary(groups: array<str>)` to
> display only the specified groups.
> ```typ
> #print-glossary(
>   // ...
>   groups: ("Group A", "Group B", "") // "" is the default group
> )
> ```
> and `print-glossary(group-heading-level: int)` to set the heading level for
> groups regardless of the previous heading level.
> ```typ
> #print-glossary(
>   // ...
>   group-heading-level: 3
> )
> ```

> [!TIP]
> A new parameter `print-glossary(minimum-ref: int)` has been added to filter
> entries with a minimum number of references.
> ```typ
> #print-glossary(
>   // ...
>   minimum-ref: 2
> )
> ```

> [!TIP]
> New counting functions have been added: `count-all-refs` and `there-are-refs`
> in addition to `count-refs`.
> ```typ
> #context count-all-refs()
> #context if there-are-refs() [
>   = Glossary
> ]
> ```

> [!NOTE]
> - Fix terms references for long-only terms.
> - Fix missing commas in fast start

> [!NOTE]
> Add missing changelog!


## 0.5.0

> [!WARNING]
> Starting from Typst v0.12.0 and later, only a single level of indirection
> in the description is supported. This means that the description of an entry
> cannot contain another glossary reference with more than once. See the example
> at
> [`references-in-description`](https://github.com/typst-community/glossarium/blob/master/tests/non-regression/references-in-description.typ)

> [!NOTE]
> Fix `figure.caption` alignement for glossary entries.

> [!NOTE]
> Allow terms to have either `short` or `long` or both.

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

> [!TIP]
> An interface for user customization has been provided through parameters in
> `print-glossary`. See the documentation in
> [`advanced-docs`](https://github.com/typst-community/glossarium/blob/master/advanced-docs/main.pdf)
> for more details.

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
