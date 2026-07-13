# ruffini

Typeset **synthetic division (Ruffini's rule)** in [Typst](https://typst.app) — the
classic three-row division box and the stacked factorization staircase.

Unlike a sign or variation table, this **computes**: you pass the coefficients and
the root, and it does the arithmetic *and* draws it — the products row, the running
sums, the boxed remainder. No more hand-building tables and quietly dropping the
middle row. No dependencies (native `table`).

<p align="center">
  <img src="https://raw.githubusercontent.com/13Stokes31/ruffini/main/gallery/g1.png" width="45%" alt="Single division, three-row tableau">
  <img src="https://raw.githubusercontent.com/13Stokes31/ruffini/main/gallery/g2.png" width="45%" alt="Full factorization staircase">
</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/13Stokes31/ruffini/main/gallery/g3.png" width="45%" alt="Leading coefficient not one">
  <img src="https://raw.githubusercontent.com/13Stokes31/ruffini/main/gallery/g4.png" width="45%" alt="Spanish labels">
</p>

## Usage

```typ
#import "@preview/ruffini:0.1.0": ruffini, ruffini-factor

// Divide x³ − 2x² + 1 by (x − 2):
#ruffini((1, -2, 0, 1), 2)
// → three-row tableau; Quotient: C(x) = x²   Remainder: R = 1

// Factor x³ − 6x² + 11x − 6 using its roots 1, 2, 3:
#ruffini-factor((1, -6, 11, -6), (1, 2, 3))
// → stacked staircase; Factorization: P(x) = (x − 1)(x − 2)(x − 3)
```

**Coefficients** go highest degree first and **must include zeros** for missing
terms: `x³ − 2x² + 1` → `(1, -2, 0, 1)`.

**Divisor convention:** `root` is the `a` in `(x − a)`. To divide by `(x + 3)`,
pass `root: -3`.

### Fractions

Arithmetic is **exact** (rational), not floating-point, and fractions render as
fractions. You can write them two ways:

- **As a plain number** — works for ordinary fractions, whose value the package
  recovers exactly (even repeating decimals like `1/3`):

  ```typ
  #ruffini((2, -1, -1), 1/2)      // root 1/2   → shows ½
  #ruffini((1, 0, -3), 1/3)       // root 1/3   → shows ⅓, exact
  #ruffini((0.25, 0.5, -1), 0.5)  // decimals too → ¼, ½
  ```

- **As a string** (in quotes) — **always exact, no matter how unusual** the
  fraction. Both for `root` and inside `coefficients`:

  ```typ
  #ruffini(("1/2", "1/4", "-1/4"), "1/2")   // fractional coefficients + root
  ```

> ⚠️ **Use quotes for unusual fractions.** A bare number goes through Typst's
> floating-point first, so a fraction with a **large denominator** cannot be
> recovered — the package then **stops with a clear error** telling you to quote
> it (it never guesses a wrong fraction). Rule of thumb: **ordinary fractions
> (`1/2`, `2/3`, `5/6`, `1/12`…) work as bare numbers; anything exotic
> (`7/99991`, `355/113`…) must be a string** (`"7/99991"`). When in doubt, quote
> it — the string form is always exact.
>
> ```typ
> #ruffini((1, 0, -3), 1/99991)      // ✗ error: pass it as a string, e.g. "1/3"
> #ruffini((1, 0, -3), "1/99991")    // ✓ exact
> ```

**Variable.** The rendered labels use `x` by default; pass `variable: "t"` (or any
letter) to write `C(t)`, `P(z)`, `(t − 2)`, …

## `ruffini(coefficients, root, ...)`

One division `P(x) ÷ (x − root)`, rendered as the three-row tableau
(coefficients · products · results) with the remainder boxed.

| Parameter             | Default      | Meaning |
|-----------------------|--------------|---------|
| `coefficients`        | *(required)* | Array, highest degree first, zeros included. Numbers, or string fractions for unusual ones (see [Fractions](#fractions)). |
| `root`                | *(required)* | The `a` in `(x − a)`. A number (`-3`, `1/2`), or a string for unusual fractions (`"7/99991"`). |
| `lang`                | `"en"`       | Language of the rendered words: `"en"` or `"es"`. |
| `variable`            | `"x"`        | The polynomial's variable in the rendered labels. |
| `color`               | blue         | Accent color of the L-rule and the remainder box. |
| `show-result`         | `true`       | Append the *Quotient / Remainder* line. |
| `highlight-remainder` | `true`       | Draw the box around the remainder cell. |
| `trail`               | `false`      | Overlay teaching arrows (see below). |

### Explaining the algorithm (`trail`)

`trail: true` overlays the arrows that show *how* synthetic division works —
**bring the first coefficient down**, **multiply by the root** (the `×a`
diagonals), **add the column** (the `+` signs) — so it doubles as a lecture
figure. Drawn natively (no CeTZ). Best with integer coefficients.

<p align="center">
  <img src="https://raw.githubusercontent.com/13Stokes31/ruffini/main/gallery/g5.png" width="60%" alt="Teaching trail: bring down, multiply by the root, add the column">
</p>

```typ
#ruffini((1, -2, 0, 1), 2, trail: true)
```

## `ruffini-factor(coefficients, roots, ...)`

Applies several `roots` in turn — each quotient becomes the next dividend — and
draws the stacked staircase. If every division is exact, it appends the
factorization; otherwise it says so.

| Parameter     | Default      | Meaning |
|---------------|--------------|---------|
| `coefficients`| *(required)* | Array, highest degree first, zeros included. |
| `roots`       | *(required)* | The successive values `a` to divide by, in order. Ints or string fractions. |
| `lang`        | `"en"`       | `"en"` or `"es"`. |
| `variable`    | `"x"`        | The polynomial's variable in the rendered labels. |
| `color`       | blue         | Accent color of the rules. |
| `show-result` | `true`       | Append the *Factorization* line. |
| `highlight-remainder` | `true` | Box each division's remainder cell. |

The factorization keeps the leading coefficient correct and, when an irreducible
factor of degree ≥ 2 remains, shows it in parentheses — e.g.
`P(x) = (x − 1)(x + 1)(3x + 2)` or `P(x) = (x − 2)(x² + x + 1)`.

## What it handles

| Case | Behavior |
|---|---|
| Exact division | Remainder `0`, boxed; quotient shown. |
| **Nonzero remainder** | Boxed remainder; `R = …` in the result line. |
| Missing terms | Handled via the explicit zero coefficients you pass. |
| **Fractional root / coefficients** | Exact rational arithmetic; rendered as fractions. Bare numbers for ordinary fractions, strings for unusual ones. |
| Leading coefficient ≠ 1 | Preserved through the staircase and in the factorization. |
| **Irreducible quotient** | `ruffini-factor` stops and shows `(…)` for the remaining factor. |
| Supplied value is not a root | `ruffini-factor` reports "not an exact division". |

## Localization

Rendered words default to English. Pass `lang: "es"` for Spanish
(Cociente / Resto / Factorización). Adding a language is copying one block in the
`_i18n` dictionary in `lib.typ` and translating four words — contributions welcome.

## Compatibility

- Typst `>= 0.14.0`
- No dependencies.

## Known limitations

See [`ROADMAP.md`](https://github.com/13Stokes31/ruffini/blob/main/ROADMAP.md). In short: it does not *find* the roots for you
(you supply them — that is a root-finding problem, not a layout one), and it
divides only by linear binomials `(x − a)`, which is what Ruffini's rule is for.

## License

[MIT](LICENSE).
