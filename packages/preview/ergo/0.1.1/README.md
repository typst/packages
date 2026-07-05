# Ergo

**Ergo** is a [Typst](https://typst.app/) suite of environments for taking notes and doing problem sets, especially for Mathematics, Computer Science, and Physics.

> **Typst** is required to use this package (refer to Typst's installation page [here](https://github.com/typst/typst?tab=readme-ov-file#installation)).
> For the best Typst experience, we recommend the integrated language service [Tinymist](https://github.com/Myriad-Dreamin/tinymist).

## Usage

To get started, add the following to your `.typ` file:

```typ
#import "@preview/ergo:0.1.1": *

#show: ergo-init
```

### Example

<a href="gallery/bootstrap_tab_orbit.typ">
    <img src="gallery/bootstrap_tab_orbit.svg" width="100%">
</a>

```typ
#defn[Group][
  A *group* is an ordered pair $(G, star)$, where $G$ is a set and $star$ is a binary operation on $G$ satisfying
  1. _Associativity:_ $(a star b) star c = a star (b star c) forall a, b, c in G$
  2. _Identity:_ $exists e in G "such that" e star a = a star e = a forall a in G$
  3. _Invertibility:_ $forall a in G exists a^(-1) in G "such that" a star a^(-1) = a^(-1) star a = e$
]

#thm[Orbit-Stabilizer Theorem][
  Let $G$ be a group acting on a set $X$, with $x in X$.
  Then the map
  $
    G \/ G_x &-->              G dot x \
    a G_x    &arrow.r.bar.long a dot x
  $
  is well-defined and bijective, and therefore $|G dot x| = [G : G_x]$.
][
  Let $a, b in G$.
  Then
  $
    a G_x = b G_x
    &<==> b^(-1) a in  G_x \
    &<==> b^(-1) a dot x = x \
    &<==> a dot x  = b dot x.
  $
  Observe the map is well-defined by $(==>)$ and injective by $(<==)$.

  For surjectivity, note for any $a in G$, $a dot x$ is the image of $a G_x$.
]
```

### Gallery

**Real Analysis Notes using the `bootstrap` color scheme with `sidebar` header style**
<a href="gallery/bootstrap_sidebar_taylor.typ">
    <img src="gallery/bootstrap_sidebar_taylor.svg" width="100%">
</a>

#### Cryptography Problem Set using the `bw` color scheme with `tab` header style
<a href="gallery/bw_tab_crypto.typ">
    <img src="gallery/bw_tab_crypto.svg" width="100%">
</a>

#### Classical Mechanics Notes using the `gruvbox-dark` color scheme with `sidebar` header style (with [Physica](https://github.com/Leedehai/typst-physics))

<a href="gallery/gruvbox_sidebar_lagrangian.typ">
    <img src="gallery/gruvbox_sidebar_lagrangian.svg" width="100%">
</a>

#### Abstract Algebra Notes using the `bw` color scheme with `classic` header style (with [Fletcher](https://github.com/Jollywatt/typst-fletcher))

<a href="gallery/ayu_classic_galoisextensions.typ">
    <img src="gallery/ayu_classic_galoisextensions.svg" width="100%">
</a>

#### **Data Structures and Algorithms Notes using the `gruvbox-dark` color scheme with `classic` header style (with [CeTZ](https://github.com/cetz-package/cetz) and [Lovelace](https://github.com/andreasKroepelin/lovelace))**

<a href="gallery/gruvbox_classic_huffman.typ">
    <img src="gallery/gruvbox_classic_huffman.svg" width="100%">
</a>

Refer to `gallery/` for more examples.

### Environments

`Ergo` has three different types of environments: _proofs_, _statements_, and _problems_.

<table>
    <tr>
        <td><b>Type</b></td>
        <td><b>Arguments</b></td>
        <td><b>Environments</b></td>
    </tr>
    <tr>
        <td>Proof</td>
        <td>
            <ol>
                <li><code>name</code></li>
                <li><code>statement</code></li>
                <li><code>proof</code></li>
            </ol>
        </td>
        <td>
            <ul>
                <li><code>theorem</code> (<code>thm</code>)</li>
                <li><code>lemma</code> (<code>lem</code>)</li>
                <li><code>corollary</code> (<code>cor</code>)</li>
                <li><code>proposition</code> (<code>prop</code>)</li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>Statement</td>
        <td>
            <ol>
                <li><code>name</code></li>
                <li><code>statement</code></li>
            </ol>
        </td>
        <td>
            <ul>
                <li><code>definition</code> (<code>defn</code>)</li>
                <li><code>remark</code> (<code>rem</code>, <code>rmk</code>)</li>
                <li><code>notation</code> (<code>notn</code>)</li>
                <li><code>example</code> (<code>ex</code>)</li>
                <li><code>concept</code> (<code>conc</code>)</li>
                <li><code>computational-problem</code> (<code>comp-prob</code>)</li>
                <li><code>algorithm</code> (<code>algo</code>)</li>
                <li><code>runtime</code> </li>
                <li><code>note</code> </li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>Problem</td>
        <td>
            <ol>
                <li><code>name</code></li>
                <li><code>statement</code></li>
                <li><code>solution</code></li>
            </ol>
        </td>
        <td>
            <ul>
                <li><code>problem</code> (<code>prob</code>)</li>
                <li><code>exercise</code> (<code>excs</code>)</li>
            </ul>
        </td>
    </tr>
</table>

The arguments are all positional, but `name` is optional, meaning either of these work:

```typ
// no `name` given
#theorem[ statement ][ proof ]

// `name` given
#theorem[ name ][ statement ][ proof ]
```

If you wish to state a result without giving a proof, you can leave proof as an empty content block `[]`.

All of these environments (regardless of type) share a set of (optional) keyword arguments:

- `breakable` (default: `false`) — whether the current environment is breakable across multiple pages
- `width` (default: `100%`) — width of the current environment in its scope
- `height` (default: `auto`) — height of the current environment in its scope

Also, the `problem` environment includes an automatic counter if no title is passed in, which can be helpful when working on problem sets.

### Themes and Colors

To modify themes and colors, use the `ergo-init` function:

```typ
#import "@preview/ergo:0.1.1": *

#show: ergo-init.with(
    colors: "gruvbox-dark",
    headers: "sidebar",
    all-breakable: true,
    inline-qed: true,
    prob-nums: false,
)
```

The modifiable parameters are:

- `colors` (default: `"bootstrap"`) — colors of theme (refer to **Color Palettes** table for valid arguments)
- `headers` (default: `"tab"`) — header style of theme (refer to **Header Styles** table for valid arguments)
- `all-breakable` (default: `false`) — the default value for `breakable` environment parameter
- `inline-qed` (default: `false`) — whether the Q.E.D square is inline or right aligned in proof environments
- `prob-nums` (default: `true`) — should excercise/problems environments have a numbering system

<table>
    <caption><strong>Color Palettes (values for <code>colors</code>)</strong></caption>
    <tr>
        <td><code>bootstrap</code></td>
        <td>
            Color scheme adapted from the CSS framework <a href="https://getbootstrap.com/">Bootstrap</a>
            <!--
            <a href="src/color/bootstrap.json">
                <img src="gallery/docs/bootstrap_palette.svg" width="500px">
            </a>
            -->
        </td>
    </tr>
    </tr>
    <tr>
        <td><code>bw</code></td>
        <td>
            Black and white color scheme
            <!--
            <a href="src/color/bw.json">
                <img src="gallery/docs/bw_palette.svg" width="500px">
            </a>
            -->
        </td>
    </tr>
    <tr>
        <td><code>gruvbox-dark</code></td>
        <td>
            Adapted from the dark version of the <code>neovim</code> color scheme <a href="https://github.com/morhetz/gruvbox">gruvbox</a>
            <!--
            <a href="src/color/gruvbox-dark.json">
                <img src="gallery/docs/gruvbox_palette.svg" width="500px">
            </a>
            -->
        </td>
    </tr>
    <tr>
        <td><code>ayu-light</code></td>
        <td>
            Adapated from <a href="https://github.com/dempfi/ayu">ayu</a>
        </td>
    </tr>
</table>

<table>
    <caption><strong>Header Styles (values for <code>headers</code>)</strong></caption>
    <tr>
        <td><code>tab</code></td>
        <td>Default header style, rounded</td>
    </tr>
    </tr>
    <tr>
        <td><code>classic</code></td>
        <td>Original header style, rounded</td>
    </tr>
    <tr>
        <td><code>sidebar</code></td>
        <td>Less padding, not rounded</td>
    </tr>
</table>

This function should be called before any content is rendered to enforce consistency of the document content.

#### Extras

There are a few extra functions and macros that may be of interest:

- `correction(body)` — Content with red text, useful for correcting a previous assignment
- `bookmark(title, info)` — Add additional information with small box. Particularly useful for recording dates and times
- `equation-box(equation)` (`eqbox(equation)`) — Box an equation
- `ergo-title-selector` — A selector controlling the style of the headers in the blocks

## Local Installation (MacOS / Linux)

1. Clone this repository locally on your machine.
2. Run `setup.sh` from the **root of the project directory**.
  This script symlinks the project directory to the Typst local packages directory.
  Refer to the [Typst Packages](https://github.com/typst/packages) repository for more information.

```console
$ git clone https://github.com/EsotericSquishyy/ergo
$ cd ergo
$ chmod +x setup.sh
$ ./setup.sh
```

### Testing

Test whether the installation worked by running the following commands in an empty directory:

```console
$ cat <<EOF > test.typ
#import "@preview/ergo:0.1.1": *
#show: ergo-init
#defn[#lorem(5)][#lorem(50)]
EOF

$ typst compile test.typ
```

The installation is successful if the file compiled without errors and `test.pdf` looks like this:
<img src="gallery/docs/test_output.svg" width="100%">
