// blockst — Complete Manual
// Built with the manifesto HTML template.

#import "/manual/template/utils.typ": template, info, warning, example
#import "/lib.typ": scratch, set-blockst, scratch-run, set-scratch-run, blockst
#import "/libs/scratch/monitors.typ": list-monitor, variable-monitor

#set document(title: "blockst — Scratch Blocks in Typst")

#show: template

= Introduction <introduction>

== About blockst <about>

*blockst* renders Scratch-style programming blocks directly in Typst documents. It is designed for worksheets, tutorials, teaching material, and visual programming explanations — anything where Scratch-like block syntax needs to appear in print or online documentation.

The current renderer uses a text-to-WASM pipeline: Typst passes Scratch text to a bundled WASM plugin, the plugin parses and renders SVG, and Typst embeds the SVG output in the document.

#info(title: "Core Design")[
  - Fully text-based: write Scratch blocks as plain text, get rendered blocks.
  - _26 languages_ supported via built-in WASM locale data.
  - _Localized_ block rendering follows official Scratch translations.
  - _Turtle graphics_ execution engine for demonstrating program flow visually.
  - _SB3 import_ helpers for reading real Scratch project files.
]

#warning(title: "Breaking Change since 0.2.0")[
  The old pre-0.2.0 native-Typst renderer syntax is *removed*. From 0.2.0 onward, blockst uses only the text-to-WASM pipeline. Documents that still rely on the previous syntax must be migrated.
]

== Quick start <quick-start>

```typst
#import "@preview/blockst:0.2.1": blockst, scratch, raw-scratch, sb3

#scratch("
when green flag clicked
move (10) steps
turn cw (15) degrees
")
```

#image("/examples/example-quickstart.svg")

== Package information <package-info>

- *Version:* 0.2.1
- *License:* MIT
- *Repository:* #link("https://github.com/Loewe1000/blockst")[github.com/Loewe1000/blockst]
- *Compiler requirement:* Typst 0.13.1+
- *Font requirement:* Designed for Helvetica Neue (Scratch look). On Linux/Windows install a compatible font (e.g. Nimbus Sans) or override via #link("#set-blockst")[set-blockst].

= Core Rendering API <core-api>

== scratch() — Render Scratch Blocks <scratch>

The primary function for rendering Scratch blocks. It parses Scratch-like text and produces visual blocks.

#example(
  `#scratch("when green flag clicked\nmove (10) steps")`,
  context scratch("when green flag clicked\nmove (10) steps"),
)

=== Signature <scratch-sig>

```typst
#scratch(
  text,
  language: "en",
  theme: auto,
  scale: auto,
  line-numbers: auto,
  line-number-start: auto,
  line-number-gutter: auto,
  inset-scale: auto,
)
```

=== Parameters <scratch-params>

#table(
  columns: (auto, auto, auto),
  align: left + top,
  table.header([*Name*], [*Default*], [*Description*]),
  [`text`], [`—` (required)], [Scratch block text. Supports blocks, reporters, booleans, inputs, dropdowns, and nested control structures.],
  [`language`], [`"en"`], [Locale for block text. See #link("#languages")[Languages] for available options.],
  [`theme`], [`auto`], [Visual theme: `"normal"`, `"high-contrast"`, `"print"`, or `auto` (global default).],
  [`scale`], [`auto`], [Overall size multiplier (e.g. `80%`, `0.8`, `50%`).],
  [`line-numbers`], [`auto`], [Show line numbers (`true` or `false`).],
  [`line-number-start`], [`auto`], [Starting line number (integer, default `1`).],
  [`line-number-gutter`], [`auto`], [Width of line number gutter (pt, default `24`).],
  [`inset-scale`], [`auto`], [Proportional block geometry scaling. `100%` = default, `60%` = thin blocks, `125%` = thick blocks. Does not affect text size.],
)

=== Supported block syntax <scratch-syntax>

The text parser supports the full Scratch 3 block vocabulary in all 26 locales. Key syntax patterns:

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  table.header([*Pattern*], [*Example*], [*Description*]),
  [Stack block], [`move (10) steps`], [Standard command block],
  [Hat block], [`when green flag clicked`], [Event trigger],
  [Reporter], [`(x position)`], [Value reporter (round ends)],
  [Boolean], [`<mouse down?>`], [Predicate (pointy ends)],
  [Input: number], [`(10)`], [Numeric input field],
  [Input: string], [`[hello]`], [String input field],
  [Input: dropdown], [`[random position v]`], [Dropdown selector],
  [C-block], [`repeat (4)\n...\nend`], [Block with body],
  [C-block + else], [`if <...> then\n...\nelse\n...\nend`], [Conditional with else],
  [Line labels], [`move (10) steps #step`], [Named label (see #link("#labels")[Labels])],
  [Category prefix], [`@motion free text`], [Force category color (see #link("#category-prefix")[category])],
  [Category prefix (render)], [`#text("@category")` + text], [Matches real block when text fits],
)

== set-blockst() — Global Defaults <set-blockst>

Sets global rendering options for all subsequent `scratch()` and SB3 render calls.

```typst
#set-blockst(
  theme: none,
  scale: none,
  stroke-width: none,
  font: none,
  line-numbers: none,
  line-number-start: none,
  line-number-gutter: none,
  inset-scale: none,
)
```

All parameters are optional. Only provided values override the current defaults.

=== Themes <themes>

#table(
  columns: (auto, auto),
  align: left + top,
  table.header([*Theme*], [*Description*]),
  [`"normal"`], [Default — full color Scratch style.],
  [`"high-contrast"`], [Lighter, high-contrast variant for accessibility.],
  [`"print"`], [Black-and-white optimized for print.],
)

```typst
#set-blockst(theme: "print", scale: 70%)
#scratch("when green flag clicked\nmove (10) steps")
```

=== Fonts <fonts>

```typst
#set-blockst(font: "Nimbus Sans")
```

The default font is Helvetica Neue. On systems without it, set an alternative.

=== Line numbers <line-numbers>

```typst
#set-blockst(line-numbers: true, line-number-start: 1, line-number-gutter: 24)
```

#image("/examples/example-labels.svg")

=== Inset scale <inset-scale>

Controls the visual thickness/slimness of blocks without changing text size.

```typst
#set-blockst(inset-scale: 60%)   // compact blocks
#set-blockst(inset-scale: 125%)  // generous blocks
```

== blockst() — Group Override Container <blockst>

Optional wrapper for grouped blocks that differ from global settings.

```typst
#blockst(
  theme: auto,
  scale: auto,
  line-numbers: auto,
  line-number-start: auto,
  line-number-gutter: auto,
  inset-scale: auto,
  spacing: 1.5em,
  body,
)
```

All parameters match `scratch()` but apply only within the body. Use when a specific group of blocks needs different scaling or theme.

```typst
#blockst(theme: "high-contrast")[
  #scratch("when green flag clicked\nmove (10) steps")
]
```

= Languages <languages>

blockst supports *26 languages* via built-in WASM locale data. Set via `scratch(..., language: "de")` or `set-blockst(...)`.

#table(
  columns: (auto, auto, auto, auto),
  align: (left, left, left, left),
  table.header([*Code*], [*Language*], [*Code*], [*Language*]),
  [`"en"`], [English], [`"de"`], [German],
  [`"fr"`], [French], [`"es"`], [Spanish],
  [`"it"`], [Italian], [`"nl"`], [Dutch],
  [`"pt"`], [Portuguese], [`"pl"`], [Polish],
  [`"ru"`], [Russian], [`"ja"`], [Japanese],
  [`"ca"`], [Catalan], [`"cs"`], [Czech],
  [`"cy"`], [Welsh], [`"el"`], [Greek],
  [`"fa"`], [Persian], [`"gd"`], [Scottish Gaelic],
  [`"he"`], [Hebrew], [`"hi"`], [Hindi],
  [`"hr"`], [Croatian], [`"hu"`], [Hungarian],
  [`"id"`], [Indonesian], [`"nb"`], [Norwegian (Bokmål)],
  [`"ro"`], [Romanian], [`"sl"`], [Slovenian],
  [`"tr"`], [Turkish], [], [],
)

```typst
#set-blockst(scale: 67.5%)
#scratch("
Wenn die grüne Flagge angeklickt
wiederhole (4) mal
  gehe (30) er Schritt
  drehe dich nach rechts um (90) Grad
end
", language: "de")
```

#image("/examples/example-de.svg")

Block text must match the chosen locale's vocabulary — the parser matches against official Scratch translations.

= Labels and Line Numbers <labels>

blockst provides a label system for creating line-aware worksheets. Lines ending with `#label-name` are tagged and can be referenced later.

== scratch-labels() — Extract Labels <scratch-labels>

Parses Scratch text and returns a dictionary mapping label names to line numbers.

```typst
#let labels = scratch-labels("
repeat (4) #loop
  move (20) steps #step
  turn cw (90) degrees
end
")
// labels = ("loop": 1, "step": 2)
```

== blockst-labels() — Query Labels <blockst-labels>

Queries globally collected labels from all rendered `scratch()` calls.

```typst
#blockst-labels("loop")   // → line number or "NaN"
#blockst-labels()         // → full label → line dictionary
```

== blockst-register-labels() — Pre-register Labels <blockst-register-labels>

Register labels globally without rendering blocks. Useful when labels are needed before the first block output.

```typst
#blockst-register-labels("
repeat (4) #loop
  move (20) steps #step
end
")
```

#image("/examples/example-labels.svg")

= `@category` — Quick Color Defaults <category-prefix>

Use `@category` prefix to force a block's category color, even without matching full localized syntax.

```typst
@motion         // → default motion block
@motion free text  // → unrecognized block in motion color
```

Available categories:

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  table.header([*Token*], [*Normalized*], [*Default Block*]),
  [`@motion`], [motion], [`move (10) steps`],
  [`@looks`], [looks], [`say [Hello!]`],
  [`@sound`], [sound], [`play sound [pop v]`],
  [`@events`], [events], [`when green flag clicked`],
  [`@control`], [control], [`repeat (10)`],
  [`@sensing`], [sensing], [`ask [What's your name?] and wait`],
  [`@operators`], [operators], [`(() + ())`],
  [`@variable`], [variables], [`set [var v] to (0)`],
  [`@list`], [lists], [`add (thing) to [list v]`],
  [`@pen`], [pen], [`clear`],
  [`@event`], [events], [(alias for `events`)],
  [`@operator`], [operators], [(alias for `operators`)],
) |

When `@category` is followed by text that matches a known block in that category, the actual block is rendered:

```typst
@list add (12) to [my list v]    // → DATA_ADDTOLIST
@variable change [score v] by (1) // → DATA_CHANGEVARIABLEBY
```

If the text does not match any known block, the fallback is an `unrecognized` block in the forced category color.

= Parsing API <parsing>

== scratch-parse() — Parse to AST <scratch-parse>

Parses Scratch text to an abstract syntax tree for programmatic use.

```typst
#scratch-parse(
  text,              // Scratch block text
  language: "en",    // locale for parsing
)
```

Returns a nested structure representing blocks, inputs, and bodies.

= Markdown Code Blocks with raw-scratch <raw-scratch>

The `raw-scratch()` show rule converts scratch code fences into rendered blocks automatically.

```typst
#show: raw-scratch(language: "en")   // locale for block text
```

Then use scratch code fences in your document:

```scratch
when green flag clicked
repeat (4)
  move (30) steps
  turn cw (90) degrees
end
```

#image("/examples/example-raw-scratch.svg")

Optionally pass language: raw-scratch(language: "de") in the show rule.

= Theme and Styling Examples <theme-examples>

```typst
#let script = "when green flag clicked
go to (random position v)
turn cw (30) degrees"

#blockst(inset-scale: 50%)[#scratch(script)]

#v(5mm)

#blockst(theme: "high-contrast")[#scratch(script)]

#v(5mm)

#blockst(theme: "print")[#scratch(script)]
```

#image("/examples/example-theme.svg")

= Turtle Graphics / Executable Scratch <turtle-graphics>

blockst includes an execution engine that runs Scratch programs visually — ideal for demonstrating program flow and pen drawing.

== scratch-run Module <scratch-run>

Import via the `scratch-run` module:

```typst
#import "@preview/blockst:0.2.1": scratch-run, set-scratch-run

#scratch-run.stage("...", scale: 2)
#scratch-run.grid("...", grid: true)
```

=== scratch-run.stage() — Stage Canvas <stage>

Renders pen drawing on a stage canvas, like the Scratch stage.

```typst
#scratch-run.stage(
  program,
  language: "en",      // locale for block text
  size: auto,          // (width, height) in pixels (default 480×360)
  scale: auto,         // drawing scale multiplier
  start: auto,         // (x: 0, y: 0, angle: 90)
  pen: auto,           // (down: false, color: ..., size: ...)
  background: auto,    // background color (e.g. white, black)
  cursor: auto,        // show/hide turtle cursor (default: true)
  border: auto,        // show/hide stage border (default: true)
)
```

=== scratch-run.grid() — Coordinate Grid <grid>

Renders the drawing on a Cartesian coordinate grid with optional axes and grid lines.

```typst
#scratch-run.grid(
  program,
  language: "en",      // locale for block text
  x: auto,             // view bounds (tuple, e.g. (-10, 10))
  y: auto,             // view bounds (tuple)
  step: auto,          // grid step size
  scale: auto,         // drawing scale multiplier
  start: auto,         // (x: 0, y: 0, angle: 90)
  pen: auto,           // (down: false, color: ..., size: ...)
  background: auto,    // background color
  axes: auto,          // show axis lines (default: false)
  grid: auto,          // show grid lines (default: false)
  grid-style: auto,    // grid line stroke (default: 0.5pt + gray)
  cursor: auto,        // show/hide turtle cursor (default: true)
  fit: auto,           // auto-fit view to drawing bounds
)
```

=== set-scratch-run() — Run Global Defaults <set-scratch-run>

```typst
#set-scratch-run(
  scale: none,         // default scale for all runs
  start: none,         // (x: 0, y: 0, angle: 90)
  pen: none,           // (down: false, color: ..., size: ...)
  background: none,    // default background color
  cursor: none,        // show/hide turtle cursor (default: true)
  stage: none,         // (size: (480, 360), border: true)
  grid: none,          // (visible: false, axes: false, step: auto, style: auto)
)
```

=== Supported Execution Commands <exec-commands>

#table(
  columns: (auto, auto),
  align: left + top,
  table.header([*Category*], [*Commands*]),
  [Motion], [`move`, `turn-right`, `turn-left`, `set-direction`, `go-to`, `set-x`, `set-y`, `change-x`, `change-y`],
  [Pen], [`pen-down`, `pen-up`, `set-pen-color`, `set-pen-size`, `change-pen-size`, `erase-all`, `stamp`, `set-pen-param`, `change-pen-param`],
  [Variables], [`set-variable`, `change-variable`, `variable`],
  [Operators], [`plus`, `minus`, `multiply`, `divide`, `modulo`, `random`, `round`, `greater`, `less`, `equals`, `op-and`, `op-or`, `op-not`],
  [Control], [`repeat`, `repeat-until`, `if-then`, `if-else`, `wait`],
  [Looks], [`say`, `think`],
  [Shapes], [`square`, `triangle`, `circle`, `star`, `spiral`],
  [German], [`gehe`, `drehe-rechts`, `drehe-links`, `setze-richtung`, `gehe-zu`, `stift-ein`, `stift-aus`, `setze-stiftfarbe-auf`, `setze-stiftdicke`, `setze-variable`, `aendere-variable`, `groesser`, `kleiner`, `gleich`, `und`, `oder`, `nicht`, `mal`, `geteilt`, `zufallszahl`],
)

=== Complete Example <exec-example>

#image("/examples/example-executable.svg")

```typst
#let square-program = "
go to x: (-45) y: (45)
pen down
set pen [color v] to (0)
set pen size to (45)
repeat (4)
  move (90) steps
  turn cw (90) degrees
  change pen [color v] by (25)
end"

#set-scratch-run(
  stage: (size: (300, 240)),
  start: (x: 0, y: 0, angle: 90),
)

#grid(
  columns: (auto, auto),
  gutter: 6mm,
  [#scratch(square-program)],
  [#scratch-run.stage(square-program, scale: 2)],
)
```

= SB3 Import API <sb3>

blockst can read real Scratch 3 project files (`.sb3`) and extract scripts, variables, lists, images, and screen previews.

== Basic Workflow <sb3-workflow>

```typst
#let project = read("my-project.sb3", encoding: none)

#sb3.render-sb3-scripts(project, language: "en", target: "Sprite1")
```

The `.sb3` file must be read as raw bytes (`encoding: none`).

== render-sb3-scripts() <sb3-scripts>

```typst
#sb3.render-sb3-scripts(
  sb3-bytes,                   // raw .sb3 file bytes (read with encoding: none)
  script-number: auto,         // global script index (1-based)
  target-script-number: auto,  // script index within selected target
  target: auto,                // filter by target name ("Stage", sprite name, or auto for all)
  sb3-plugin: auto,            // WASM plugin path (auto = bundled plugin)
  language: "en",              // locale for block text
  show-headers: auto,          // show target name header
  header-gap: 1.5mm,           // spacing between target name and scripts
  script-gap: 3mm,             // spacing between individual scripts
)
```

#image("/examples/example-sb3-import.svg")

== render-sb3-variables() <sb3-variables>

```typst
#sb3.render-sb3-variables(
  sb3-bytes,                   // raw .sb3 file bytes
  target: auto,                // filter by target name
  target-variable-name: auto,  // filter by variable name
  target-variable-number: auto,// variable index within target (1-based)
  sb3-plugin: auto,            // WASM plugin path
  language: "en",              // locale for display text
  show-target-headers: auto,   // show target name header
  target-gap: 2mm,             // spacing between targets
  item-gap: 0.8mm,             // spacing between variable items
)
```

== render-sb3-lists() <sb3-lists>

```typst
#sb3.render-sb3-lists(
  sb3-bytes,                   // raw .sb3 file bytes
  target: auto,                // filter by target name
  target-list-name: auto,      // filter by list name
  target-list-number: auto,    // list index within target (1-based)
  sb3-plugin: auto,            // WASM plugin path
  language: "en",              // locale for display text
  show-target-headers: auto,   // show target name header
  target-gap: 2mm,             // spacing between targets
  item-gap: 0.8mm,             // spacing between list items
)
```

== Standalone Monitors <monitors>

=== list-monitor() <list-monitor>

```typst
#list-monitor(
  name: "List",      // display name shown in header
  items: (),         // array of values to display
  width: 5.2cm,      // monitor width
  height: auto,      // auto-grows to fit content
  length-label: auto,// show length indicator (e.g. "length: 3")
)
```

=== variable-monitor() <variable-monitor>

```typst
#variable-monitor(
  name: "Variable",  // display name shown in header
  value: 0,          // current value to display
)
```

#image("/examples/example-monitors.svg")

== screen-preview() <sb3-screen>

```typst
#sb3.sb3-screen-preview(
  sb3-bytes,           // raw .sb3 file bytes
  width: 480,          // stage rendering width in pixels
  height: 360,         // stage rendering height in pixels
  unit: 1,             // size multiplier (2 = double size)
  background: none,    // override background color
  show-border: true,   // show stage border
  show-backdrop: true, // show costume/backdrop image
  monitor-scale: 1.5,  // scale factor for variable/list overlays
  language: auto,      // locale for monitor text
)
```

Renders a static Scratch stage preview with sprites, backdrop, and monitors.

== Image Helpers <sb3-images>

```typst
// List all image assets in the project
#sb3.sb3-image-assets-catalog(sb3-bytes, target: auto)

// Render a single image asset
#sb3.sb3-image(
  sb3-bytes,          // raw .sb3 file bytes
  target: auto,       // filter by sprite/stage name
  image-number: auto, // global image index (1-based)
  target-image-number: auto, // image index within target (1-based)
  image-name: auto,   // filter by image name (e.g. "costume1")
  width: auto,        // output width (auto = original size)
  height: auto,       // output height
)
```

== Catalog Helpers <sb3-catalogs>

```typst
// Grouped script metadata (targets, scripts, blocks count)
#sb3.sb3-scripts-catalog(sb3-bytes)

// Target states (variables, lists, and sprite properties)
#sb3.sb3-state-catalog(sb3-bytes)

// Convert a specific SB3 script to Scratch text
#sb3.sb3-bytes-to-scratch-text(
  sb3-bytes,          // raw .sb3 file bytes
  script-number: auto,// global script index (1-based)
  language: "en",     // locale for output text
)
```

= Catalog <catalog>

The catalog shows every block in each Scratch 3 category, rendered live.

#let _catalog-table(blocks) = table(
  columns: (auto, auto),
  align: (left, left),
  table.header([*Block*], [*Code*]),
  ..blocks.map(block => (table.cell[#scratch(block)], table.cell[#raw(block)])).flatten(),
)

== Motion <cat-motion>

#_catalog-table("move (10) steps
turn cw (15) degrees
turn ccw (15) degrees
point in direction (90)
point towards [mouse-pointer v]
go to x: (0) y: (0)
go to [mouse-pointer v]
glide (1) secs to x: (0) y: (0)
glide (1) secs to [mouse-pointer v]
change x by (10)
set x to (0)
change y by (10)
set y to (0)
if on edge, bounce
set rotation style [left-right v]
(x position)
(y position)
(direction)".split("\n"))

== Looks <cat-looks>

#_catalog-table("say [Hello!] for (2) seconds
say [Hello!]
think [Hmm...] for (2) seconds
think [Hmm...]
show
hide
switch costume to [costume1 v]
next costume
switch backdrop to [backdrop1 v]
next backdrop
change [color v] effect by (25)
set [color v] effect to (0)
clear graphic effects
change size by (10)
set size to (100) %
go to [front v] layer
go [forward v] (1) layers
(costume [number v])
(backdrop [number v])
(size)".split("\n"))

== Sound <cat-sound>

#_catalog-table("play sound [pop v] until done
start sound [pop v]
stop all sounds
change [pitch v] effect by (10)
set [pitch v] effect to (100)
clear sound effects
change volume by (-10)
set volume to (100) %
(volume)".split("\n"))

== Pen <cat-pen>

#_catalog-table("erase all
stamp
pen down
pen up
set pen color to [#ff0000]
change pen color by (10)
set pen color to (50)
change pen shade by (10)
set pen shade to (50)
change pen size by (1)
set pen size to (1)".split("\n"))

== Variables <cat-variables>

#_catalog-table("set [my variable v] to (0)
change [my variable v] by (1)
show variable [my variable v]
hide variable [my variable v]
(my variable)".split("\n"))

== Lists <cat-lists>

#_catalog-table("add [thing] to [my list v]
delete (1) of [my list v]
delete all of [my list v]
insert [thing] at (1) of [my list v]
replace item (1) of [my list v] with [thing]
(item (1) of [my list v])
(item # of [thing] in [my list v])
(length of [my list v])
<[my list v] contains [thing]?>
show list [my list v]
hide list [my list v]".split("\n"))

== Events <cat-events>

#_catalog-table("when green flag clicked
when [space v] key pressed
when this sprite clicked
when backdrop switches to [backdrop1 v]
when [loudness v] > (10)
when I receive [message1 v]
broadcast [message1 v]
broadcast [message1 v] and wait".split("\n"))

== Control <cat-control>

#_catalog-table("wait (1) seconds
repeat (10)
end
forever
end
if <> then
end
if <> then
else
end
wait until <>
repeat until <>
end
stop [all v]
when I start as a clone
create clone of [myself v]
delete this clone".split("\n"))

== Sensing <cat-sensing>

#_catalog-table("<touching [mouse-pointer v]?>
<touching color [#ff0000]?>
<color [#ff0000] is touching [#00ff00]?>
(distance to [mouse-pointer v])
ask [What's your name?] and wait
(answer)
<key [space v] pressed?>
<mouse down?>
(mouse x)
(mouse y)
(loudness)
(timer)
reset timer
([x position v] of [Sprite1 v])
(current [year v])
(days since 2000)
(username)".split("\n"))

== Operators <cat-operators>

#_catalog-table("(() + ())
(() - ())
(() * ())
(() / ())
(pick random (1) to (10))
<() > ()>
<() < ()>
<() = ()>
<> and <>
<> or <>
not <>
(join [apple] [banana])
(letter (1) of [apple])
(length of [apple])
([apple] contains [a]?)
(() mod ())
(round ())
([sqrt v] of (9))".split("\n"))

= Contributing <contributing>

Contributions are welcome: bug reports, missing blocks, parser improvements, rendering polish, docs, and new localizations.

- *Repository:* #link("https://github.com/Loewe1000/blockst")[github.com/Loewe1000/blockst]
- *License:* MIT