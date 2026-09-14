## Usage

To get started, add the following to your `.typ` file:

```typ
#import "@preview/ergo:0.2.0": *

#show: ergo-init
```

### Example

<a href="gallery/examples-typ/bootstrap-tab1-orbit.typ">
    <img src="gallery/examples-svg/bootstrap-tab1-orbit.svg" width="100%">
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

#### Real Analysis Notes using the `bootstrap` color scheme with the `sidebar1` style
<a href="gallery/examples-typ/bootstrap-sidebar1-taylor.typ">
    <img src="gallery/examples-svg/bootstrap-sidebar1-taylor.svg" width="100%">
</a>

#### Cryptography Problem Set using the `primer-light` color scheme with the `tab2` style
<a href="gallery/examples-typ/primerlight-tab2-crypto.typ">
    <img src="gallery/examples-svg/primerlight-tab2-crypto.svg" width="100%">
</a>

#### Classical Mechanics Notes using the `woodland` color scheme with the `sidebar1` style (with [Physica](https://github.com/Leedehai/typst-physics))

<a href="gallery/examples-typ/woodland-sidebar1-lagrangian.typ">
    <img src="gallery/examples-svg/woodland-sidebar1-lagrangian.svg" width="100%">
</a>

#### Abstract Algebra Notes using the `terracotta` color scheme with the `basic` style (with [Fletcher](https://github.com/Jollywatt/typst-fletcher))

<a href="gallery/examples-typ/terracotta-basic-galoisextensions.typ">
    <img src="gallery/examples-svg/terracotta-basic-galoisextensions.svg" width="100%">
</a>

#### **Data Structures and Algorithms Notes using the `dracula` color scheme with the `classic` style (with [CeTZ](https://github.com/cetz-package/cetz) and [Lovelace](https://github.com/andreasKroepelin/lovelace))**

<a href="gallery/examples-typ/dracula-classic-huffman.typ">
    <img src="gallery/examples-svg/dracula-classic-huffman.svg" width="100%">
</a>

Refer to `gallery/` for more examples.

### Environments

`Ergo` has two different types of environments: _solutions_ and _statements_.

<table>
    <tr>
        <td><b>Type</b></td>
        <td><b>Arguments</b></td>
        <td><b>Environments</b></td>
    </tr>
    <tr>
        <td>Solution</td>
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
                <li><code>problem</code> (<code>prob</code>)</li>
                <li><code>exercise</code> (<code>excs</code>)</li>
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
</table>

The arguments are all positional, but `name` is optional, meaning either of these work:

```typ
// no `name` given
#theorem[ statement ][ proof ]

// `name` given
#theorem[ name ][ statement ][ proof ]
```

If you wish to state a result without giving a proof, you can leave proof as an empty content block `[]`.

All of these environments (regardless of type) share a set of (optional) keyword arguments, including `width` (default: `100%`) and `height` (default: `auto`), along with several other settings listed below.

Also, the `problem` environment includes an automatic counter if no title is passed in, which can be helpful when working on homework assignments.

> If these environments aren't enough, `ergo-solution` and `ergo-statement` are used to define all of these presets in `src/presets.typ`, and are exposed functions, so you can define your own presets.
>
> Note that you will have to define colors for these new environments, which is detailed below in the **Custom Color Schemes** section.

### Themes and Colors

A list of environment settings to customize your environments exists globally (resp. locally) which can be accessed by passing in keyword arguments to `ergo-init` (resp. the environment called).
The valid arguments are the following:

- `colors` (default: `ergo-colors.bootstrap`) — colors of theme (refer to **Color Palettes** table for valid arguments)
- `styles` (default: `ergo-styles.tab1`) — style of theme (refer to **Styles** table for valid arguments)
- `breakable` (default: `false`) — whether the environments are breakable across page boundaries
- `inline-qed` (default: `false`) — whether the Q.E.D square is inline or right aligned in proof environments (only affects _solution_ type environments)
- `prob-nums` (default: `true`) — whether problem environments have a numbering system (only affects `problem`)


```typ
#import "@preview/ergo:0.2.0": *

// global example
#show: ergo-init.with(
    colors:     ergo-colors.lime,
    styles:     ergo-styles.sidebar2,
    breakable:  true,
    inline-qed: true,
    prob-nums:  false,
)

// local example (takes precedence over global)
#prob(
    colors:     ergo-colors.bootstrap,
    styles:     ergo-colors.tab1,
    breakable:  false,
    inline-qed: false,
    prob-nums:  true,
)[ #lorem(5) ][ #lorem(10) ][ #lorem(10) ]
```

<table>
    <caption><strong>Color Palettes (values for <code>colors</code>)</strong></caption>
    <tr>
        <td><code>ergo-colors.bootstrap</code> (light)</td>
        <td>
            Color scheme adapted from the CSS framework <a href="https://getbootstrap.com/">Bootstrap</a>
        </td>
        <td>
            No preview available
        </td>
    </tr>
    <tr>
        <td><code>ergo-colors.bw</code> (light)</td>
        <td>
            Monochrome black and white scheme
        </td>
        <td>
            No preview available
        </td>
    </tr>
    <tr>
        <td><code>ergo-colors.equilibrium-gray-light</code> (light)</td>
        <td>
            From the Equilibrium Gray Light <code>vim</code> color scheme by Carlo Abelli
        </td>
        <td>
            <a href="src/color/equilibrium-gray-light.json">
                <img src="gallery/scheme-previews/light/equilibrium-gray-light.svg" width="500px">
            </a>
        </td>
    </tr>
    <tr>
        <td><code>ergo-colors.penumbra-light</code> (light)</td>
        <td>
            From the Penumbra Light <code>vim</code> color scheme by Zachary Weiss
        </td>
        <td>
            <a href="src/color/penumbra-light.json">
                <img src="gallery/scheme-previews/light/penumbra-light.svg" width="500px">
            </a>
        </td>
    </tr>
    <tr>
        <td><code>ergo-colors.primer-light</code> (light)</td>
        <td>
            From the Primer Light <code>vim</code> color scheme by Jimmy Lin
        </td>
        <td>
            <a href="src/color/primer-light.json">
                <img src="gallery/scheme-previews/light/primer-light.svg" width="500px">
            </a>
        </td>
    </tr>
    <tr>
        <td><code>ergo-colors.measured-light</code> (light)</td>
        <td>
            From the Measured Light <code>vim</code> color scheme by Measured
        </td>
        <td>
            <a href="src/color/measured-light.json">
                <img src="gallery/scheme-previews/light/measured-light.svg" width="500px">
            </a>
        </td>
    </tr>
    <tr>
        <td><code>ergo-colors.terracotta</code> (light)</td>
        <td>
            From the Terracotta <code>vim</code> color scheme by Alexander Rossell Hayes
        </td>
        <td>
            <a href="src/color/terracotta.json">
                <img src="gallery/scheme-previews/light/terracotta.svg" width="500px">
            </a>
        </td>
    </tr>
    <tr>
        <td><code>ergo-colors.dracula</code> (dark)</td>
        <td>
            Adapted from <a href="https://draculatheme.com/">dracula</a>
        </td>
        <td>
            <a href="src/color/dracula.json">
                <img src="gallery/scheme-previews/dark/dracula.svg" width="500px">
            </a>
        </td>
    </tr>
    <tr>
        <td><code>ergo-colors.gruvbox-dark-medium</code> (dark)</td>
        <td>
            Adapted from the dark version of the famous <code>vim</code> color scheme <a href="https://github.com/morhetz/gruvbox">gruvbox</a>
        </td>
        <td>
            <a href="src/color/gruvbox-dark-medium.json">
                <img src="gallery/scheme-previews/dark/gruvbox-dark-medium.svg" width="500px">
            </a>
        </td>
    </tr>
    <tr>
        <td><code>ergo-colors.eighties</code> (dark)</td>
        <td>
            From the Eighties <code>vim</code> color scheme by Chris Kempson
        </td>
        <td>
            <a href="src/color/eighties.json">
                <img src="gallery/scheme-previews/dark/eighties.svg" width="500px">
            </a>
        </td>
    </tr>
    <tr>
        <td><code>ergo-colors.lime</code> (dark)</td>
        <td>
            From the Lime <code>vim</code> color scheme by limelier
        </td>
        <td>
            <a href="src/color/lime.json">
                <img src="gallery/scheme-previews/dark/lime.svg" width="500px">
            </a>
        </td>
    </tr>
    <tr>
        <td><code>ergo-colors.woodland</code> (dark)</td>
        <td>
            From the Woodland <code>vim</code> color scheme by Jay Cornwall
        </td>
        <td>
            <a href="src/color/woodland.json">
                <img src="gallery/scheme-previews/dark/woodland.svg" width="500px">
            </a>
        </td>
    </tr>
</table>

<table>
    <caption><strong>Styles (values for <code>styles</code>)</strong></caption>
    <tr>
        <td><code>tab1</code></td>
        <td>Default style, rounded</td>
    </tr>
    <tr>
        <td><code>sidebar1</code></td>
        <td>Less padding, not rounded</td>
    </tr>
    <tr>
        <td><code>tab2</code></td>
        <td>Same as tab1, but with sidebar style proofs in a separate block</td>
    </tr>
    <tr>
        <td><code>sidebar2</code></td>
        <td>Same as sidebar1, but with sidebar style proofs in a separate block</td>
    </tr>
    <tr>
        <td><code>basic</code></td>
        <td>Keeps it simple - the classic look of a math textbook</td>
    </tr>
    <tr>
        <td><code>classic</code></td>
        <td>Original style, rounded</td>
    </tr>
</table>

This function should be called before any content is rendered to enforce consistency of the document content.

#### Custom Color Schemes

You can also define your own color scheme.
To do this, define a Typst `dictionary` with the valid fields and pass it in to the `ergo-init` function.
One way to do this is to define your scheme with `json`:

```typ
#import "@preview/ergo:0.2.0": *

#let my-custom-colors = json("my-custom-colors.json")
#show: ergo-init.with(colors: my-custom-colors)
```

Refer to existing color schemes in `src/color/` for information on valid fields.
We support RGB and RGBA in hex format (i.e. `"#ffffff"` or `"#ffffffff"`).
Note that you can use our Python project to automatically generate ergo themes from arbitrary Base 16 color schemes like those found on [Tinted Gallery](https://tinted-theming.github.io/tinted-gallery/).

If you want to define your own environments, you must add information for how to color it.
This is done through the `id` positional argument in `ergo-solution` and `ergo-statement`.
The `id` is used to match the value in the `json` file.
If you want to add your own `id`, you will have to format it in the following way:

```json
{
  ...,
  "custom-proof": {
    "type": "proof",
    "bgcolor1": "#ffffff",
    "bgcolor2": "#bbbbbb",
    "strokecolor1": "#000000",
    "strokecolor2": "#000000"
  },
  "custom-statement": {
    "type": "statement",
    "bgcolor": "#bbbbbb",
    "strokecolor": "#000000"
  },
  ...
}
```

Note the `type` is important here, as it determines which color values you will have to supply for this package to view your dictionary as a valid color scheme.
If you want examples, check out `tests/custom.json`.

#### Custom Styles

Although more complicated, we do support custom styles.
```typ
#import "@preview/ergo:0.2.0": *

#show: ergo-init.with(styles: my-custom-styles)
```

You must pass in a dictionary with **only** the keys `solution` and `statement`.
Their values should be functions with the following structure (return value should be content):

```typ
#let custom-solution(
  title,
  statement,
  proof-statement,
  colors,
  ..argv
) = { ... }

#let custom-statement(
  title,
  statement,
  colors,
  ..argv
) = { ... }

#let custom-styles = (
  "solution": custom-solution,
  "statement": custom-statement,
)
```

Refer to `src/style/` for examples in our presets.

#### Extras

There are a few extra functions and macros that may be of interest:

- `correction(body)` — Content with red text, useful for correcting a previous assignment
- `bookmark(title, info)` — Add additional information with small box. Particularly useful for recording dates and times
- `equation-box(equation)` (`eqbox(equation)`) — Box an equation
- `ergo-title-selector` — A selector controlling the style of the blocks

## Local Installation (MacOS / Linux)

1. Clone this repository locally on your machine.
2. Run `setup.sh` from the **root of the project directory**.
  This script symlinks the project directory to the Typst local packages directory.
  Refer to the [Typst Packages](https://github.com/typst/packages) repository for more information.

```console
$ git clone https://github.com/EsotericSquishyy/ergo
$ cd ergo
$ chmod +x common/scripts/setup.sh
$ ./common/scripts/setup.sh
```

### Testing

Test whether the installation worked by running the following commands in an empty directory:

```console
$ cat <<EOF > test.typ
#import "@preview/ergo:0.2.0": *
#show: ergo-init
#defn[#lorem(5)][#lorem(50)]
EOF

$ typst compile test.typ
```

The installation is successful if the file compiled without errors and `test.pdf` looks like this:
<img src="gallery/test-output.svg" width="100%">
