# Obelisk

A high-precision Typst document template engineered for mathematical monographs, course notes, and technical publications. Inspired by the strict geometric discipline of Bauhaus and Russian Constructivism, **Obelisk** treats typography as an architectural problem — locking every element, heading, and block to a cohesive structural canvas.

---

## Key Philosophies

* **Bauhaus-Inspired Aesthetic:** Rejects decorative fluff in favor of heavy typography, active negative space, and dynamic layout vectors.

* **The Absolute Baseline Grid:** Every single line of text, heading, and block element automatically snaps to a rigid vertical rhythm.

* **Print & Publication Ready:** Engineered natively for physical printing. Features asymmetrical, alternating margins with a dedicated ledger column for sidenotes and technical markers.

* **Zero-Configuration Onboarding:** Despite the complex geometric arithmetic running under the hood, Obelisk requires no elaborate layout scaffolding or boilerplate setup. It compiles instantly out of the box with highly refined, production-ready defaults—allowing you to focus entirely on writing your mathematics without wrestling with document configuration.

---

## Core Features & Layout Architecture

1. **Built-in Theorem Environments:** pre-configured environments for mathematical exposition (Theorems, Lemmas, Corollaries, and Proofs). Define your own using the exposed `#make-environment`.

2. **Grid-Aligned Blocks (`#bblock`):** Standard block elements can easily throw off a baseline grid due to fractional padding or stroke widths. Obelisk exposes the _baseline block_ `bblock` component, which automatically calculates and pads structural boxes so that the following text snaps perfectly back onto the running baseline. By default, all block equations are wrapped in `#bblock`.

3. **Intentional Page Breaks (`#blank-page`):** When preparing documents for double-sided publication, forcing a section to start on an odd page can leave an empty facing page. The `blank-page` function inserts a clean break and prints an authoritative, technical layout marker. By default, all top level headings break to an odd page using `#black-page`.

4. **Customizable:** Customize page sizes and margins, baseline step sizes, fonts, and more. Obelisk comes out of the box with a carefully designed default configuration, allowing you to tweak the underlying structural metrics without breaking the core grid alignment arithmetic. _Customization is still in early stage; more options are coming in the future. See below for a guide to customization._

---

## Example

```typst
#import "@preview/obelisk:0.1.0": *

#show: init

= Obelisk Template

#definition[
  *Obelisk* is a note template inspired by Bauhaus aesthetics.
]

== Second Level Header

All texts are by default aligned to a baseline grid.

$ integral_0^(+oo) "e"^(-x^2) dif x=sqrt(pi)/2 $

Math blocks are also automatically aligned.

=== Third Level Header

The template includes several theorem environments by default. #sidenote[inline sidenotes can be added] Theorems can have titles and referenced.

#theorem[mean inequality][
  One of the mean inequalities is $n/(sum_(i=1)^n 1/x_i)<=root(n, product_(i=1)^n x_i).$
]<thm:mean-ineq>

Theorems can be referenced by numbering (@thm:mean-ineq) or by title (@thm:mean-ineq[!]).
```

---

## Customization Guide

Obelisk exposes its architectural engine through a centralized configuration dictionary. To apply your customizations, replace `show: init` with `show: init.with(<your configurations>)`.

### 1. Layout Configuration

```typst
(
  paper: (width, height),
  margin: (s, e, t, f),
  side: (half-gutter, margin),
  texts: (size, ascender, step),
)
```

* **`paper`**: Maps the absolute dimensions of the physical canvas.
    * `width` / `height`: Explicit length dimensions. Defaults to A4 size.


* **`margin`**: Uses logical binding scopes to handle alternating page layouts dynamically.
    * `s` / `e`: Spine (Inside) and Face (Outside) horizontal margins. The layout engine flips these on odd and even pages to maintain binding gutters.
    * `t` / `f`: Top and Foot (Bottom) vertical margins, defining the boundaries where the baseline grid activates and terminates.


* **`side`**: Manages the geometry of the margin ledger.
    * `half-gutter`: Half of the gutter between the body text and the side margin body. Equals the gutter between the body text and the vertical separating line.
    * `margin`: The outer margin for the sidenotes.


* **`texts`**: The core parameters of the vertical baseline grid.
    * `size`: The default font size for the document body text (configured to `12pt` by default).
    * `ascender`: The explicit vertical (ascender) height of the font.
    * `step`: The absolute grid increment (configured to `16pt` by default), or the default line height. All block vertical paddings, headings, and margins must be integer multiples of this value.

### 2. Font Configuration

```typst
fonts: (body, math, sans, mono)
```
By default, Obelisk uses **TeX Gyre Pagella (Math)** for body and math fonts, **Switzer** for sans and **IBM Plex Mono** for mono.

For font replacements, _we recommend_:

* For the sans font: use heavy, geometric, or unextended modern grotesques.
* For the mono font: use high-legibility coding typefaces.

### 3. Decoration Configuration

```typst
deco: (line-number)
```

* **`line-number`**: show line number or not. Default `true`.
