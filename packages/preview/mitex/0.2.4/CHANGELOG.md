# CHANGELOG

## 0.2.4

- Fix `\boxed` command.
- Support basic figure and tabular environments.
- Add escape symbols for plus, minus and percent.
- Fix `\left` and `\right`: size of lr use em.


## 0.2.3

- Support nesting math equation like `\text{$x$}`.
- Fix broken `\left` and `\right` commands. #143
- Correct the symbol mapping for `\varphi`, `phi`, `\epsilon` and `\varepsilon`.


## 0.2.2

### Text Mode

- Add `\(\)` and `\[\]` support.
- Add `\footnote` and `\cite`.

### Fixes

- Remove duplicate keys for error when a dict has duplicate keys in Typst 0.11.
- Fix bracket/paren group parsing.
- Remove extra spacing for ceiling symbols.


## 0.2.1

- Remove unnecessary zws.


## 0.2.0

- Add more symbols for equations.
- Basic macro support.
- Basic text mode support.


## 0.1.0

- LaTeX support for Typst, powered by Rust and WASM. We can now render LaTeX equations in real-time in Typst.