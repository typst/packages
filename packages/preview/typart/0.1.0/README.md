# typart

SmartArt-style diagrams for Typst: card-table, process, gantt, pyramid, hierarchy, steps, venn, timeline, cycle, tree, matrix, and more.

## Installation

```typst
#import "@preview/typart:0.1.0": *
```

## Widgets

### card-table
A card-style table with rounded cells, coloured header, and alternating row fills.

```typst
#card-table(
  ("Study", "Approach", "Dataset"),
  (
    ("Guo et al.",  "Propose two...", "Homemade"),
    ("Gurunathan",  "Exhaustive...", "PUT Vein"),
    ("Zhang et al.", "ML-based",     "InHouse"),
  ),
)
```

![Screenshot of the card-table widget showing a styled data table with headers and rows](images/card-table.png)

### gantt
A Gantt chart with task bars, progress indicator, grid lines, and a "today" marker.

```typst
#gantt(
  (
    ("Planning",     0, 12, 100),
    ("Development",  6, 30, 60),
    ("Testing",     24, 40, 30),
    ("Papers",       0, 48, 20, false),
  ),
  span: 48, grid-step: 12,
  periods: ("Year 1", "Year 2", "Year 3", "Year 4"),
  today: 20,
)
```

![Screenshot of the gantt chart widget with task bars, progress indicators, and a today marker](images/gantt.png)

### process
A heartbeat-ring process diagram with icon badges and connector arms. Requires [Font Awesome 7 Free](https://fontawesome.com).

```typst
#process(
  (
    ("\u{f02d}", "1. Review methods"),
    ("\u{f51e}", "2. Data collection"),
    ("\u{f83e}", "3. Signal analysis"),
  ),
)
```

![Screenshot of the process diagram widget showing a heartbeat ring with connected icon badges](images/process.png)

### pyramid
A pyramid or funnel diagram (use `flip: true` for a funnel).

```typst
#pyramid(([Vision], [Strategy], [Tactics]))
```

![Screenshot of the pyramid widget showing stacked triangular levels](images/pyramid.png)

### hierarchy
A root node with a row of children beneath it.

```typst
#hierarchy([CEO], (([Eng], rgb("#a7dd9b")), [Sales], [HR]))
```

![Screenshot of the hierarchy widget showing a root node with child nodes beneath](images/hierarchy.png)

### steps
A vertical numbered list of steps.

```typst
#steps(([Plan], [Execute], [Review], ([Deploy], rgb("#e64553"))))
```

![Screenshot of the steps widget showing vertical numbered step blocks](images/steps.png)

### venn
A 2- or 3-circle Venn diagram.

```typst
#venn((([Behavior], rgb("#aab4f7")), [Signal], [Security]))
```

![Screenshot of the venn diagram widget showing three overlapping circles](images/venn.png)

### hlist
A horizontal row of equally sized coloured blocks.

```typst
#hlist(([Plan], [Execute], ([Review], rgb("#e64553"))))
```

![Screenshot of the hlist widget showing equally sized coloured blocks in a row](images/hlist.png)

### chevron
A sequence of right-pointing chevron arrows.

```typst
#chevron(([Phase 1], [Phase 2], [Phase 3], [Phase 4]))
```

![Screenshot of the chevron widget showing sequential right-pointing arrow blocks](images/chevron.png)

### cycle
Nodes arranged on a ring connected by curved arrows.

```typst
#cycle(([Plan], [Do], [Check], ([Act], rgb("#e64553"))))
```

![Screenshot of the cycle widget showing nodes arranged on a ring with curved arrows](images/cycle.png)

### target
Concentric rings (bullseye).

```typst
#target(([Vision], [Mission], [Goal]))
```

![Screenshot of the target widget showing concentric rings in a bullseye pattern](images/target.png)

### matrix
A 2x2 matrix with optional axis labels.

```typst
#matrix(([TL], [TR], [BL], [BR]),
  x-axis: ("Low", "High"),
  y-axis: ("High", "Low"))
```

![Screenshot of the matrix widget showing a 2x2 grid with axis labels](images/matrix.png)

### snake
A bending process that wraps into multiple rows.

```typst
#snake(([Step 1], [Step 2], [Step 3], [Step 4], [Step 5], [Step 6]))
```

![Screenshot of the snake widget showing a bending process that wraps into rows](images/snake.png)

### stairs
An ascending stair-step process.

```typst
#stairs(([Plan], [Develop], ([Launch], rgb("#e64553"))))
```

![Screenshot of the stairs widget showing an ascending stair-step process](images/stairs.png)

### gears
Up to 3 interlocking cogwheels.

```typst
#gears(([Research], [Development], [Production]))
```

![Screenshot of the gears widget showing interlocking cogwheels](images/gears.png)

### timeline
A horizontal timeline with alternating labels.

```typst
#timeline((("2024", [Start]), ("2025", [Pilot]), ("2026", [Launch])))
```

![Screenshot of the timeline widget showing milestones along a horizontal line](images/timeline.png)

### tree
A multi-level tree hierarchy.

```typst
#tree(([CEO], (([Eng], ([Web], [Mobile])), [Sales])))
```

![Screenshot of the tree widget showing a multi-level hierarchy chart](images/tree.png)

### arrows
Converging or diverging arrows around a central core.

```typst
// converging
#arrows(([Idea 1], [Idea 2], [Idea 3]), core: [Core])

// diverging
#arrows(([Branch 1], [Branch 2]), diverge: true)
```

![Screenshot of converging arrows widget showing arrows pointing inward to a central core](images/arrows-converging.png)
![Screenshot of diverging arrows widget showing arrows pointing outward from a central core](images/arrows-diverging.png)

### opposing
Two block arrows facing each other.

```typst
#opposing(([Pros], [Cons]))
```

![Screenshot of the opposing widget showing two block arrows facing each other](images/opposing.png)

### equation
An A + B = C equation-style diagram.

```typst
#equation(([Input 1], [Input 2], [Output]))
```

![Screenshot of the equation widget showing an A plus B equals C diagram](images/equation.png)

### kpi
Stat cards displaying a large value and a caption.

```typst
#kpi((("< 1%", [Target EER]),
      ("99%", [Accuracy], rgb("#40a02b")),
      ("500+", [Users])))
```

![Screenshot of the kpi widget showing stat cards with big values and captions](images/kpi.png)

### pill-steps
A central hub with connected pill-shaped step rows. Requires [Font Awesome 7 Free](https://fontawesome.com) for icons.

```typst
#pill-steps(
  (
    ([Research], [Gather requirements],
      text(font: "Font Awesome 7 Free", size: 26pt)[\u{f0eb}]),
    ([Develop],  [Build the solution],
      text(font: "Font Awesome 7 Free", size: 26pt)[\u{f0ae}], rgb("#74c7ec")),
  ),
  title: [PROJECT STEPS],
)
```

![Screenshot of the pill-steps widget showing a central hub with connected pill-shaped step rows](images/pill-steps.png)
